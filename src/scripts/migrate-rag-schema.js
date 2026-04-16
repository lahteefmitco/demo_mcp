import fs from "node:fs/promises";
import path from "node:path";
import { fileURLToPath } from "node:url";
import { logger } from "../logger.js";
import { closeDatabase, query } from "../db.js";

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

async function main() {
  const schemaAiPath = path.join(__dirname, "..", "schema-ai.sql");
  const schemaAiSql = await fs.readFile(schemaAiPath, "utf8");
  await query(schemaAiSql);
  logger.info("RAG schema (extension + ai_documents) applied.");
}

main()
  .catch((error) => {
    logger.error("Failed to apply RAG schema.", {
      message: error?.message,
      stack: error?.stack
    });
    process.exitCode = 1;
  })
  .finally(async () => {
    await closeDatabase();
  });
