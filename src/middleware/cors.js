const DEFAULT_ALLOWED_METHODS = "GET,POST,PUT,PATCH,DELETE,OPTIONS";
const DEFAULT_ALLOWED_HEADERS = "Authorization,Content-Type";

function parseOriginList(raw) {
  if (typeof raw !== "string" || raw.trim() === "") {
    return [];
  }

  return raw
    .split(",")
    .map((s) => s.trim())
    .filter(Boolean);
}

function isAllowedOrigin(origin, allowList) {
  if (!origin) return false;
  return allowList.includes(origin);
}

/**
 * Allowlist CORS middleware for browser clients.
 *
 * Env:
 * - CORS_ORIGINS: comma-separated list of allowed origins
 * - CORS_ALLOW_ALL: when "true", reflect any Origin (dev only)
 */
export function corsMiddleware() {
  const allowAll = String(process.env.CORS_ALLOW_ALL || "").toLowerCase() === "true";
  const allowedOrigins = parseOriginList(process.env.CORS_ORIGINS);

  return function cors(req, res, next) {
    const origin = req.headers.origin;
    if (!origin) {
      return next();
    }

    if (allowAll) {
      res.setHeader("Access-Control-Allow-Origin", origin);
      res.setHeader("Vary", "Origin");
    } else if (isAllowedOrigin(origin, allowedOrigins)) {
      res.setHeader("Access-Control-Allow-Origin", origin);
      res.setHeader("Vary", "Origin");
    } else {
      return next();
    }

    res.setHeader("Access-Control-Allow-Methods", DEFAULT_ALLOWED_METHODS);
    res.setHeader("Access-Control-Allow-Headers", DEFAULT_ALLOWED_HEADERS);
    res.setHeader("Access-Control-Max-Age", "600");

    return next();
  };
}

