import { getUserById, verifyAuthToken } from "../services/auth-service.js";

function readBearerToken(req) {
  const header = req.headers.authorization || req.headers.Authorization;
  if (typeof header !== "string" || !header.startsWith("Bearer ")) {
    return null;
  }

  return header.slice("Bearer ".length).trim();
}

export async function authenticateRequest(req) {
  const token = readBearerToken(req);
  if (!token) {
    const error = new Error("Authentication required");
    error.statusCode = 401;
    throw error;
  }

  const payload = verifyAuthToken(token);
  const user = await getUserById(payload.sub);
  if (!user) {
    const error = new Error("User not found");
    error.statusCode = 401;
    throw error;
  }

  return user;
}

export async function requireAuth(req, _res, next) {
  try {
    req.user = await authenticateRequest(req);
    next();
  } catch (error) {
    next(error);
  }
}

export function unauthorizedJsonRpcResponse(message = "Authentication required") {
  return {
    jsonrpc: "2.0",
    error: {
      code: -32001,
      message
    },
    id: null
  };
}
