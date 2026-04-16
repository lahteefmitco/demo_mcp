import express from "express";
import { reindexUser } from "../services/rag-backfill-service.js";
import { logger } from "../logger.js";

const router = express.Router();

router.post("/reindex", async (req, res, next) => {
  try {
    const result = await reindexUser(req.user.id);
    res.json({ ok: true, ...result });
  } catch (error) {
    logger.error("RAG reindex HTTP failed.", { message: error?.message, userId: req.user?.id });
    next(error);
  }
});

export default router;
