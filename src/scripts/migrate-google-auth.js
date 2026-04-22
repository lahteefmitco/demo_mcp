import { logger } from "../logger.js";
import { closeDatabase, query } from "../db.js";

async function main() {
  logger.info("Starting Google Auth schema migration...");

  // Make password_hash nullable
  await query(`
    ALTER TABLE users
    ALTER COLUMN password_hash DROP NOT NULL;
  `);
  logger.info("Made password_hash nullable.");

  // Add google_id column if it doesn't exist
  await query(`
    ALTER TABLE users
    ADD COLUMN IF NOT EXISTS google_id TEXT UNIQUE;
  `);
  logger.info("Added google_id column.");

  // Add a unique constraint or index if necessary (UNIQUE already creates an index)
  
  logger.info("Google Auth schema migration completed successfully.");
}

main()
  .catch((error) => {
    logger.error("Failed to apply Google Auth schema migration.", {
      message: error?.message,
      stack: error?.stack
    });
    process.exitCode = 1;
  })
  .finally(async () => {
    await closeDatabase();
  });
