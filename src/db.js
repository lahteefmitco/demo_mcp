import dotenv from "dotenv";
import { QueryTypes, Sequelize } from "sequelize";

dotenv.config({ quiet: true, override: false });

function normalizeDatabaseUrl(raw) {
  if (!raw) {
    return "";
  }
  let s = String(raw).trim();
  // Docker --env-file and some editors keep wrapping quotes; URL() rejects them.
  if (
    (s.startsWith('"') && s.endsWith('"')) ||
    (s.startsWith("'") && s.endsWith("'"))
  ) {
    s = s.slice(1, -1);
  }
  return s;
}

const databaseUrlString = normalizeDatabaseUrl(process.env.DATABASE_URL);

if (!databaseUrlString) {
  throw new Error("DATABASE_URL is required. Copy .env.example to .env and update it.");
}

const databaseUrl = new URL(databaseUrlString);
const isLocalHost = ["localhost", "127.0.0.1"].includes(databaseUrl.hostname);
const requiresSsl = databaseUrl.searchParams.get("sslmode") === "require" || !isLocalHost;

export const sequelize = new Sequelize(databaseUrlString, {
  dialect: "postgres",
  logging: false,
  dialectOptions: requiresSsl
    ? {
        ssl: {
          require: true,
          rejectUnauthorized: false
        }
      }
    : undefined
});

export { QueryTypes };

export async function query(text, bind = [], options = {}) {
  const queryOptions = bind.length
    ? {
        bind,
        ...options
      }
    : {
        ...options
      };

  if (options.type) {
    return sequelize.query(text, queryOptions);
  }

  const [results] = await sequelize.query(text, queryOptions);

  return results;
}

export async function closeDatabase() {
  await sequelize.close();
}
