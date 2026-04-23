import express from "express";
import { runHelpChat } from "../services/help-chat-service.js";
import { indexGlobalHelpDoc } from "../services/help-doc-index-service.js";
import { logger } from "../logger.js";
import { requireAuth } from "../middleware/auth-middleware.js";

const router = express.Router();

router.post("/chat", requireAuth, async (req, res, next) => {
  try {
    const { appVersion, messages, maxWords, screen } = req.body ?? {};

    if (!Array.isArray(messages)) {
      return res.status(400).json({ error: "messages must be an array" });
    }

    const normalized = messages
      .filter((m) => m && typeof m === "object")
      .map((m) => ({ role: String(m.role || ""), content: String(m.content || "") }))
      .filter((m) => m.role && m.content);

    if (normalized.length === 0) {
      return res.status(400).json({ error: "messages must include at least one message" });
    }

    const result = await runHelpChat(normalized, req.user, {
      appVersion: typeof appVersion === "string" ? appVersion : "",
      maxWords: Number(maxWords) || 220,
      screen: typeof screen === "string" ? screen : ""
    });

    res.json(result);
  } catch (error) {
    logger.error("Help chat HTTP failed.", { message: error?.message, userId: req.user?.id });
    next(error);
  }
});

function requireHelpIndexKey(req, _res, next) {
  const expected = String(process.env.HELP_INDEX_KEY || "1234").trim();
  const provided = String(req.headers["x-help-index-key"] || "").trim();
  if (!expected) {
    return next();
  }
  if (provided && provided === expected) {
    return next();
  }
  const error = new Error("Help index key required");
  error.statusCode = 401;
  return next(error);
}

// Index or update the single global help document using a simple key header.
// Header: x-help-index-key: 1234 (or set HELP_INDEX_KEY env var)
router.post("/index", requireHelpIndexKey, async (req, res, next) => {
  try {
    const { documentKey, title, content, sourceId } = req.body ?? {};
    const result = await indexGlobalHelpDoc({
      documentKey,
      title,
      content,
      sourceId
    });
    res.json({ ok: true, ...result });
  } catch (error) {
    logger.error("Help doc index HTTP failed.", { message: error?.message, userId: req.user?.id });
    next(error);
  }
});

export default router;

