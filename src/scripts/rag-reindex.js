import dotenv from "dotenv";
import { logger } from "../logger.js";
import { closeDatabase } from "../db.js";
import { truncateAndReindexAllUsers } from "../services/rag-backfill-service.js";

dotenv.config({ quiet: true });

async function main() {
  const confirm = String(process.env.RAG_REINDEX_CONFIRM || "").toLowerCase();
  if (confirm !== "yes" && confirm !== "true" && confirm !== "1") {
    logger.error(
      "Refusing to run: set RAG_REINDEX_CONFIRM=yes to truncate ai_documents and rebuild from all finance rows."
    );
    process.exitCode = 1;
    return;
  }

  const summary = await truncateAndReindexAllUsers();
  logger.info("rag:reindex finished.", summary);
}

main()
  .catch((error) => {
    logger.error("rag:reindex failed.", { message: error?.message, stack: error?.stack });
    process.exitCode = 1;
  })
  .finally(async () => {
    await closeDatabase();
  });
