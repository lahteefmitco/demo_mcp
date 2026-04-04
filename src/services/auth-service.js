import crypto from "node:crypto";
import { QueryTypes, query } from "../db.js";
import { ensureDefaultCategoriesForUser } from "./finance-service.js";

const authSecret = process.env.AUTH_SECRET || "dev-only-change-me";
const tokenLifetimeSeconds = 60 * 60 * 24 * 30;
const verificationTokenLifetimeHours = 24;
const passwordResetTokenLifetimeMinutes = 30;
const accountDeletionTokenLifetimeHours = 24;

function toBase64Url(value) {
  return Buffer.from(value).toString("base64url");
}

function fromBase64Url(value) {
  return Buffer.from(value, "base64url").toString("utf8");
}

function signTokenParts(header, payload) {
  return crypto
    .createHmac("sha256", authSecret)
    .update(`${header}.${payload}`)
    .digest("base64url");
}

function hashPassword(password, salt = crypto.randomBytes(16).toString("hex")) {
  const hash = crypto.scryptSync(password, salt, 64).toString("hex");
  return `${salt}:${hash}`;
}

function verifyPassword(password, passwordHash) {
  const [salt, expectedHash] = String(passwordHash).split(":");

  if (!salt || !expectedHash) {
    return false;
  }

  const actualHash = crypto.scryptSync(password, salt, 64).toString("hex");
  return crypto.timingSafeEqual(
    Buffer.from(actualHash, "hex"),
    Buffer.from(expectedHash, "hex")
  );
}

function hashOpaqueToken(token) {
  return crypto.createHash("sha256").update(token).digest("hex");
}

function createOpaqueToken() {
  return crypto.randomBytes(32).toString("hex");
}

function normalizeUser(row) {
  return {
    id: row.id,
    name: row.name,
    email: row.email,
    isVerified: Boolean(row.is_verified),
    pendingEmail: row.pending_email ?? null,
    emailVerifiedAt: row.email_verified_at,
    createdAt: row.created_at,
    updatedAt: row.updated_at
  };
}

function verificationExpiredAt() {
  return new Date(Date.now() + verificationTokenLifetimeHours * 60 * 60 * 1000);
}

function passwordResetExpiredAt() {
  return new Date(Date.now() + passwordResetTokenLifetimeMinutes * 60 * 1000);
}

function accountDeletionExpiredAt() {
  return new Date(Date.now() + accountDeletionTokenLifetimeHours * 60 * 60 * 1000);
}

export function createAuthToken(user) {
  const issuedAt = Math.floor(Date.now() / 1000);
  const header = toBase64Url(JSON.stringify({ alg: "HS256", typ: "JWT" }));
  const payload = toBase64Url(
    JSON.stringify({
      sub: user.id,
      email: user.email,
      iat: issuedAt,
      exp: issuedAt + tokenLifetimeSeconds
    })
  );

  const signature = signTokenParts(header, payload);
  return `${header}.${payload}.${signature}`;
}

export function verifyAuthToken(token) {
  const [header, payload, signature] = String(token).split(".");

  if (!header || !payload || !signature) {
    throw new Error("Invalid token format");
  }

  const expectedSignature = signTokenParts(header, payload);
  if (signature.length !== expectedSignature.length) {
    throw new Error("Invalid token signature");
  }

  if (
    !crypto.timingSafeEqual(
      Buffer.from(signature, "utf8"),
      Buffer.from(expectedSignature, "utf8")
    )
  ) {
    throw new Error("Invalid token signature");
  }

  const decoded = JSON.parse(fromBase64Url(payload));
  if (!decoded.sub || !decoded.exp || decoded.exp < Math.floor(Date.now() / 1000)) {
    throw new Error("Token expired");
  }

  return decoded;
}

export async function getUserById(id) {
  const rows = await query(
    `
      SELECT id, name, email, is_verified, pending_email, email_verified_at, created_at, updated_at
      FROM users
      WHERE id = $1
    `,
    [id],
    { type: QueryTypes.SELECT }
  );

  return rows[0] ? normalizeUser(rows[0]) : null;
}

export async function getUserByEmail(email) {
  const rows = await query(
    `
      SELECT
        id,
        name,
        email,
        password_hash,
        is_verified,
        pending_email,
        email_verified_at,
        created_at,
        updated_at
      FROM users
      WHERE email = $1
    `,
    [email.toLowerCase()],
    { type: QueryTypes.SELECT }
  );

  return rows[0] ?? null;
}

export async function findUserByPendingEmail(email) {
  const rows = await query(
    `
      SELECT id
      FROM users
      WHERE pending_email = $1
    `,
    [email.toLowerCase()],
    { type: QueryTypes.SELECT }
  );

  return rows[0] ?? null;
}

export async function registerUser({ name, email, password }) {
  const normalizedEmail = email.trim().toLowerCase();
  const rows = await query(
    `
      INSERT INTO users (name, email, password_hash, is_verified, pending_email, email_verified_at)
      VALUES ($1, $2, $3, false, null, null)
      RETURNING id, name, email, is_verified, pending_email, email_verified_at, created_at, updated_at
    `,
    [name.trim(), normalizedEmail, hashPassword(password)]
  );

  const user = normalizeUser(rows[0]);
  await ensureDefaultCategoriesForUser(user.id);
  return user;
}

export async function loginUser({ email, password }) {
  const row = await getUserByEmail(email);
  if (!row || !verifyPassword(password, row.password_hash)) {
    return { ok: false, reason: "INVALID_CREDENTIALS" };
  }

  if (!row.is_verified) {
    return { ok: false, reason: "EMAIL_NOT_VERIFIED", user: normalizeUser(row) };
  }

  return { ok: true, user: normalizeUser(row) };
}

export async function authenticateUserCredentials({ email, password }) {
  const row = await getUserByEmail(email);
  if (!row || !verifyPassword(password, row.password_hash)) {
    return { ok: false, reason: "INVALID_CREDENTIALS" };
  }

  return { ok: true, user: normalizeUser(row) };
}

export function createAuthResponse(user) {
  return {
    token: createAuthToken(user),
    user
  };
}

export async function createEmailVerificationToken(userId) {
  const token = createOpaqueToken();
  const tokenHash = hashOpaqueToken(token);

  await query(
    `
      DELETE FROM auth_tokens
      WHERE user_id = $1 AND token_type = 'verify_email'
    `,
    [userId]
  );

  await query(
    `
      INSERT INTO auth_tokens (user_id, token_hash, token_type, expires_at)
      VALUES ($1, $2, 'verify_email', $3)
    `,
    [userId, tokenHash, verificationExpiredAt()]
  );

  return token;
}

export async function createEmailChangeToken(userId, nextEmail) {
  const token = createOpaqueToken();
  const tokenHash = hashOpaqueToken(token);

  await query(
    `
      DELETE FROM auth_tokens
      WHERE user_id = $1 AND token_type = 'change_email'
    `,
    [userId]
  );

  await query(
    `
      UPDATE users
      SET pending_email = $2
      WHERE id = $1
    `,
    [userId, nextEmail.toLowerCase()]
  );

  await query(
    `
      INSERT INTO auth_tokens (user_id, token_hash, token_type, email, expires_at)
      VALUES ($1, $2, 'change_email', $3, $4)
    `,
    [userId, tokenHash, nextEmail.toLowerCase(), verificationExpiredAt()]
  );

  return token;
}

export async function createPasswordResetToken(userId) {
  const token = createOpaqueToken();
  const tokenHash = hashOpaqueToken(token);

  await query(
    `
      DELETE FROM auth_tokens
      WHERE user_id = $1 AND token_type = 'password_reset'
    `,
    [userId]
  );

  await query(
    `
      INSERT INTO auth_tokens (user_id, token_hash, token_type, expires_at)
      VALUES ($1, $2, 'password_reset', $3)
    `,
    [userId, tokenHash, passwordResetExpiredAt()]
  );

  return token;
}

export async function createAccountDeletionToken(userId) {
  const token = createOpaqueToken();
  const tokenHash = hashOpaqueToken(token);

  await query(
    `
      DELETE FROM auth_tokens
      WHERE user_id = $1 AND token_type = 'delete_account'
    `,
    [userId]
  );

  await query(
    `
      INSERT INTO auth_tokens (user_id, token_hash, token_type, expires_at)
      VALUES ($1, $2, 'delete_account', $3)
    `,
    [userId, tokenHash, accountDeletionExpiredAt()]
  );

  return token;
}

async function findValidToken(token, tokenTypes) {
  const rows = await query(
    `
      SELECT
        t.id,
        t.user_id,
        t.email,
        t.token_type,
        t.expires_at,
        t.consumed_at,
        u.id AS account_id,
        u.name,
        u.email AS current_email,
        u.is_verified,
        u.pending_email,
        u.email_verified_at,
        u.created_at,
        u.updated_at
      FROM auth_tokens t
      JOIN users u ON u.id = t.user_id
      WHERE t.token_hash = $1
        AND t.token_type = ANY($2)
        AND t.consumed_at IS NULL
        AND t.expires_at > NOW()
      LIMIT 1
    `,
    [hashOpaqueToken(token), tokenTypes],
    { type: QueryTypes.SELECT }
  );

  return rows[0] ?? null;
}

async function consumeToken(tokenId) {
  await query(
    `
      UPDATE auth_tokens
      SET consumed_at = NOW()
      WHERE id = $1
    `,
    [tokenId]
  );
}

export async function verifyEmailToken(token) {
  const record = await findValidToken(token, ["verify_email", "change_email"]);
  if (!record) {
    return { ok: false, reason: "INVALID_OR_EXPIRED_TOKEN" };
  }

  if (record.token_type === "verify_email") {
    await query(
      `
        UPDATE users
        SET is_verified = true,
            email_verified_at = NOW(),
            pending_email = null
        WHERE id = $1
      `,
      [record.user_id]
    );
  } else {
    await query(
      `
        UPDATE users
        SET email = $2,
            pending_email = null,
            is_verified = true,
            email_verified_at = NOW()
        WHERE id = $1
      `,
      [record.user_id, record.email]
    );
  }

  await consumeToken(record.id);
  return { ok: true, user: await getUserById(record.user_id) };
}

export async function deleteUserById(userId) {
  const rows = await query(
    `
      DELETE FROM users
      WHERE id = $1
      RETURNING id, email, is_verified
    `,
    [userId]
  );

  return rows[0] ?? null;
}

export async function requestAccountDeletionForUser(user) {
  if (!user.isVerified) {
    await deleteUserById(user.id);
    return {
      ok: true,
      deletedDirectly: true,
      user
    };
  }

  return {
    ok: true,
    deletedDirectly: false,
    user,
    token: await createAccountDeletionToken(user.id)
  };
}

export async function deleteAccountWithToken(token) {
  const record = await findValidToken(token, ["delete_account"]);
  if (!record) {
    return { ok: false, reason: "INVALID_OR_EXPIRED_TOKEN" };
  }

  const deletedUser = await deleteUserById(record.user_id);
  if (!deletedUser) {
    return { ok: false, reason: "ACCOUNT_NOT_FOUND" };
  }

  return {
    ok: true,
    email: record.current_email
  };
}

export async function resetPasswordWithToken(token, password) {
  const record = await findValidToken(token, ["password_reset"]);
  if (!record) {
    return { ok: false, reason: "INVALID_OR_EXPIRED_TOKEN" };
  }

  await query(
    `
      UPDATE users
      SET password_hash = $2
      WHERE id = $1
    `,
    [record.user_id, hashPassword(password)]
  );

  await consumeToken(record.id);
  await query(
    `
      DELETE FROM auth_tokens
      WHERE user_id = $1 AND token_type = 'password_reset' AND consumed_at IS NULL
    `,
    [record.user_id]
  );

  return { ok: true, user: await getUserById(record.user_id) };
}

export async function resendVerificationForEmail(email) {
  const row = await getUserByEmail(email);
  if (!row || row.is_verified) {
    return { ok: true, skipped: true };
  }

  return {
    ok: true,
    skipped: false,
    user: normalizeUser(row),
    token: await createEmailVerificationToken(row.id)
  };
}

export async function requestPasswordResetForEmail(email) {
  const row = await getUserByEmail(email);
  if (!row || !row.is_verified) {
    return { ok: true, skipped: true };
  }

  return {
    ok: true,
    skipped: false,
    user: normalizeUser(row),
    token: await createPasswordResetToken(row.id)
  };
}

export async function updateProfileName(userId, name) {
  const rows = await query(
    `
      UPDATE users
      SET name = $2
      WHERE id = $1
      RETURNING id, name, email, is_verified, pending_email, email_verified_at, created_at, updated_at
    `,
    [userId, name.trim()]
  );

  return rows[0] ? normalizeUser(rows[0]) : null;
}

export async function requestEmailChange(userId, nextEmail) {
  const normalizedEmail = nextEmail.trim().toLowerCase();
  const user = await getUserById(userId);

  if (!user) {
    return { ok: false, reason: "USER_NOT_FOUND" };
  }

  if (!user.isVerified) {
    return { ok: false, reason: "EMAIL_NOT_VERIFIED" };
  }

  if (user.email === normalizedEmail) {
    return { ok: false, reason: "EMAIL_UNCHANGED" };
  }

  const existing = await getUserByEmail(normalizedEmail);
  if (existing) {
    return { ok: false, reason: "EMAIL_ALREADY_IN_USE" };
  }

  const pending = await findUserByPendingEmail(normalizedEmail);
  if (pending) {
    return { ok: false, reason: "EMAIL_ALREADY_PENDING" };
  }

  return {
    ok: true,
    user,
    nextEmail: normalizedEmail,
    token: await createEmailChangeToken(userId, normalizedEmail)
  };
}

export async function getValidPasswordResetRecord(token) {
  const record = await findValidToken(token, ["password_reset"]);
  if (!record) {
    return null;
  }

  return {
    email: record.current_email,
    expiresAt: record.expires_at,
    userId: record.user_id
  };
}
