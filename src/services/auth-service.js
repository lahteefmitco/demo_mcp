import crypto from "node:crypto";
import { QueryTypes, query } from "../db.js";
import { ensureDefaultCategoriesForUser } from "./finance-service.js";

const authSecret = process.env.AUTH_SECRET || "dev-only-change-me";
const tokenLifetimeSeconds = 60 * 60 * 24 * 30;

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

function normalizeUser(row) {
  return {
    id: row.id,
    name: row.name,
    email: row.email,
    createdAt: row.created_at,
    updatedAt: row.updated_at
  };
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
      SELECT id, name, email, created_at, updated_at
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
      SELECT id, name, email, password_hash, created_at, updated_at
      FROM users
      WHERE email = $1
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
      INSERT INTO users (name, email, password_hash)
      VALUES ($1, $2, $3)
      RETURNING id, name, email, created_at, updated_at
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
    return null;
  }

  return normalizeUser(row);
}

export function createAuthResponse(user) {
  return {
    token: createAuthToken(user),
    user
  };
}
