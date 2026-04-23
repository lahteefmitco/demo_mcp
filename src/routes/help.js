import express from "express";
import { runHelpChat } from "../services/help-chat-service.js";
import { indexGlobalHelpDoc } from "../services/help-doc-index-service.js";
import { logger } from "../logger.js";

const router = express.Router();

router.post("/chat", async (req, res, next) => {
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

// Index or update the single global help document (admin-like action; still requires auth).
router.post("/index", async (req, res, next) => {
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

