import { OAuth2Client } from "google-auth-library";

function collectAudiences() {
  const raw = [
    process.env.GOOGLE_WEB_CLIENT_ID,
    process.env.GOOGLE_IOS_CLIENT_ID,
    process.env.GOOGLE_ANDROID_CLIENT_ID
  ];

  const out = [];
  for (const entry of raw) {
    if (typeof entry !== "string" || !entry.trim()) {
      continue;
    }

    for (const part of entry.split(",")) {
      const id = part.trim();
      if (id) {
        out.push(id);
      }
    }
  }

  return [...new Set(out)];
}

/**
 * Verifies a Google Sign-In ID token and returns stable identity fields.
 * @param {string} idToken
 * @returns {Promise<{ sub: string, email: string, name: string }>}
 */
export async function verifyGoogleSignInIdToken(idToken) {
  const audiences = collectAudiences();
  if (!audiences.length) {
    const err = new Error(
      "Google Sign-In is not configured. Set GOOGLE_WEB_CLIENT_ID and/or GOOGLE_IOS_CLIENT_ID and/or GOOGLE_ANDROID_CLIENT_ID."
    );
    err.statusCode = 503;
    throw err;
  }

  const client = new OAuth2Client();
  let ticket;

  try {
    ticket = await client.verifyIdToken({
      idToken,
      audience: audiences
    });
  } catch {
    const err = new Error("Invalid Google ID token");
    err.statusCode = 401;
    throw err;
  }

  const payload = ticket.getPayload();
  if (!payload?.sub || typeof payload.email !== "string" || !payload.email) {
    const err = new Error("Invalid Google token payload");
    err.statusCode = 401;
    throw err;
  }

  if (!payload.email_verified) {
    const err = new Error("Google email is not verified");
    err.statusCode = 403;
    throw err;
  }

  const iss = payload.iss;
  if (iss !== "https://accounts.google.com" && iss !== "accounts.google.com") {
    const err = new Error("Invalid token issuer");
    err.statusCode = 401;
    throw err;
  }

  const email = payload.email.trim().toLowerCase();
  const name =
    typeof payload.name === "string" && payload.name.trim().length >= 2
      ? payload.name.trim()
      : email.split("@")[0] || "User";

  return {
    sub: payload.sub,
    email,
    name
  };
}
