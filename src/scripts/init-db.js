import fs from "node:fs/promises";
import path from "node:path";
import { fileURLToPath } from "node:url";
import { logger } from "../logger.js";
import { closeDatabase, query } from "../db.js";

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

async function main() {
  const schemaPath = path.join(__dirname, "..", "schema.sql");
  const schemaSql = await fs.readFile(schemaPath, "utf8");
  await query(schemaSql);
  logger.info("Database schema initialized.");
}

main()
  .catch((error) => {
    logger.error("Failed to initialize database schema.", {
      message: error?.message,
      stack: error?.stack
    });
    process.exitCode = 1;
  })
  .finally(async () => {
    await closeDatabase();
  });
