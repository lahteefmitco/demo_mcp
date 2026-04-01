import fs from "node:fs/promises";
import path from "node:path";
import { fileURLToPath } from "node:url";
import { closeDatabase, query } from "../db.js";

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

async function main() {
  const schemaPath = path.join(__dirname, "..", "schema.sql");
  const schemaSql = await fs.readFile(schemaPath, "utf8");
  await query(schemaSql);
  console.log("Database schema initialized.");
}

main()
  .catch((error) => {
    console.error("Failed to initialize database schema.");
    console.error(error);
    process.exitCode = 1;
  })
  .finally(async () => {
    await closeDatabase();
  });
