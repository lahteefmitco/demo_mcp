import dotenv from "dotenv";
import { QueryTypes, Sequelize } from "sequelize";

dotenv.config({ quiet: true });

if (!process.env.DATABASE_URL) {
  throw new Error("DATABASE_URL is required. Copy .env.example to .env and update it.");
}

const databaseUrl = new URL(process.env.DATABASE_URL);
const isLocalHost = ["localhost", "127.0.0.1"].includes(databaseUrl.hostname);
const requiresSsl = databaseUrl.searchParams.get("sslmode") === "require" || !isLocalHost;

export const sequelize = new Sequelize(process.env.DATABASE_URL, {
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
