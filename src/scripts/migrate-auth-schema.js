import crypto from "node:crypto";
import dotenv from "dotenv";
import { QueryTypes, closeDatabase, query, sequelize } from "../db.js";

dotenv.config({ quiet: true });

const legacyUserName = process.env.LEGACY_USER_NAME || "Legacy User";
const legacyUserEmail = process.env.LEGACY_USER_EMAIL || "legacy@example.com";
const legacyUserPassword = process.env.LEGACY_USER_PASSWORD || "change-me-123456";

function hashPassword(password, salt = crypto.randomBytes(16).toString("hex")) {
  const hash = crypto.scryptSync(password, salt, 64).toString("hex");
  return `${salt}:${hash}`;
}

async function tableHasColumn(transaction, tableName, columnName) {
  const rows = await sequelize.query(
    `
      SELECT 1
      FROM information_schema.columns
      WHERE table_schema = 'public'
        AND table_name = $1
        AND column_name = $2
      LIMIT 1
    `,
    {
      bind: [tableName, columnName],
      type: QueryTypes.SELECT,
      transaction
    }
  );

  return rows.length > 0;
}

async function constraintExists(transaction, tableName, constraintName) {
  const rows = await sequelize.query(
    `
      SELECT 1
      FROM information_schema.table_constraints
      WHERE table_schema = 'public'
        AND table_name = $1
        AND constraint_name = $2
      LIMIT 1
    `,
    {
      bind: [tableName, constraintName],
      type: QueryTypes.SELECT,
      transaction
    }
  );

  return rows.length > 0;
}

async function triggerExists(transaction, tableName, triggerName) {
  const rows = await sequelize.query(
    `
      SELECT 1
      FROM information_schema.triggers
      WHERE event_object_schema = 'public'
        AND event_object_table = $1
        AND trigger_name = $2
      LIMIT 1
    `,
    {
      bind: [tableName, triggerName],
      type: QueryTypes.SELECT,
      transaction
    }
  );

  return rows.length > 0;
}

async function indexExists(transaction, indexName) {
  const rows = await sequelize.query(
    `
      SELECT 1
      FROM pg_indexes
      WHERE schemaname = 'public'
        AND indexname = $1
      LIMIT 1
    `,
    {
      bind: [indexName],
      type: QueryTypes.SELECT,
      transaction
    }
  );

  return rows.length > 0;
}

async function ensureColumn(transaction, tableName, columnName, definition) {
  if (await tableHasColumn(transaction, tableName, columnName)) {
    return;
  }

  await sequelize.query(
    `
      ALTER TABLE ${tableName}
      ADD COLUMN ${columnName} ${definition}
    `,
    { transaction }
  );
}

async function ensureLegacyUser(transaction) {
  const existingUsers = await sequelize.query(
    `
      SELECT id, email
      FROM users
      ORDER BY id ASC
    `,
    {
      type: QueryTypes.SELECT,
      transaction
    }
  );

  const matchingUser = existingUsers.find((user) => user.email === legacyUserEmail.toLowerCase());
  if (matchingUser) {
    return matchingUser.id;
  }

  const insertedUsers = await query(
    `
      INSERT INTO users (name, email, password_hash)
      VALUES ($1, $2, $3)
      RETURNING id
    `,
    [legacyUserName, legacyUserEmail.toLowerCase(), hashPassword(legacyUserPassword)],
    { transaction }
  );

  return insertedUsers[0].id;
}

async function ensureUsersTable(transaction) {
  await sequelize.query(
    `
      CREATE TABLE IF NOT EXISTS users (
        id SERIAL PRIMARY KEY,
        name TEXT NOT NULL,
        email TEXT NOT NULL UNIQUE,
        password_hash TEXT NOT NULL,
        is_verified BOOLEAN NOT NULL DEFAULT false,
        pending_email TEXT,
        email_verified_at TIMESTAMPTZ,
        created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
        updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
      )
    `,
    { transaction }
  );

  await ensureColumn(transaction, "users", "is_verified", "BOOLEAN NOT NULL DEFAULT false");
  await ensureColumn(transaction, "users", "pending_email", "TEXT");
  await ensureColumn(transaction, "users", "email_verified_at", "TIMESTAMPTZ");
}

async function ensureAuthTokensTable(transaction) {
  await sequelize.query(
    `
      CREATE TABLE IF NOT EXISTS auth_tokens (
        id SERIAL PRIMARY KEY,
        user_id INT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
        token_hash TEXT NOT NULL UNIQUE,
        token_type TEXT NOT NULL CHECK (token_type IN ('verify_email', 'password_reset', 'change_email', 'delete_account')),
        email TEXT,
        expires_at TIMESTAMPTZ NOT NULL,
        consumed_at TIMESTAMPTZ,
        created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
      )
    `,
    { transaction }
  );

  if (await constraintExists(transaction, "auth_tokens", "auth_tokens_token_type_check")) {
    await sequelize.query(
      `ALTER TABLE auth_tokens DROP CONSTRAINT auth_tokens_token_type_check`,
      { transaction }
    );
  }

  await sequelize.query(
    `
      ALTER TABLE auth_tokens
      ADD CONSTRAINT auth_tokens_token_type_check
      CHECK (token_type IN ('verify_email', 'password_reset', 'change_email', 'delete_account'))
    `,
    { transaction }
  );
}

async function ensureUpdatedAtFunctionAndTrigger(transaction) {
  await sequelize.query(
    `
      CREATE OR REPLACE FUNCTION set_updated_at()
      RETURNS TRIGGER AS $$
      BEGIN
        NEW.updated_at = NOW();
        RETURN NEW;
      END;
      $$ LANGUAGE plpgsql
    `,
    { transaction }
  );

  if (!(await triggerExists(transaction, "users", "trigger_users_updated_at"))) {
    await sequelize.query(
      `
        CREATE TRIGGER trigger_users_updated_at
        BEFORE UPDATE ON users
        FOR EACH ROW
        EXECUTE FUNCTION set_updated_at()
      `,
      { transaction }
    );
  }
}

async function addUserColumnAndBackfill(transaction, tableName) {
  if (!(await tableHasColumn(transaction, tableName, "user_id"))) {
    await sequelize.query(
      `
        ALTER TABLE ${tableName}
        ADD COLUMN user_id INT
      `,
      { transaction }
    );
  }
}

async function main() {
  await sequelize.transaction(async (transaction) => {
    await ensureUsersTable(transaction);
    await ensureAuthTokensTable(transaction);
    await ensureUpdatedAtFunctionAndTrigger(transaction);

    await addUserColumnAndBackfill(transaction, "categories");
    await addUserColumnAndBackfill(transaction, "expenses");
    await addUserColumnAndBackfill(transaction, "incomes");
    await addUserColumnAndBackfill(transaction, "budgets");

    const legacyUserId = await ensureLegacyUser(transaction);

    await sequelize.query(
      `UPDATE categories SET user_id = $1 WHERE user_id IS NULL`,
      { bind: [legacyUserId], transaction }
    );
    await sequelize.query(
      `UPDATE expenses SET user_id = $1 WHERE user_id IS NULL`,
      { bind: [legacyUserId], transaction }
    );
    await sequelize.query(
      `UPDATE incomes SET user_id = $1 WHERE user_id IS NULL`,
      { bind: [legacyUserId], transaction }
    );
    await sequelize.query(
      `UPDATE budgets SET user_id = $1 WHERE user_id IS NULL`,
      { bind: [legacyUserId], transaction }
    );

    await sequelize.query(
      `
        UPDATE users
        SET is_verified = true,
            email_verified_at = COALESCE(email_verified_at, NOW())
        WHERE is_verified = false OR email_verified_at IS NULL
      `,
      { transaction }
    );

    await sequelize.query(
      `ALTER TABLE categories ALTER COLUMN user_id SET NOT NULL`,
      { transaction }
    );
    await sequelize.query(
      `ALTER TABLE expenses ALTER COLUMN user_id SET NOT NULL`,
      { transaction }
    );
    await sequelize.query(
      `ALTER TABLE incomes ALTER COLUMN user_id SET NOT NULL`,
      { transaction }
    );
    await sequelize.query(
      `ALTER TABLE budgets ALTER COLUMN user_id SET NOT NULL`,
      { transaction }
    );

    if (!(await constraintExists(transaction, "categories", "categories_user_id_fkey"))) {
      await sequelize.query(
        `
          ALTER TABLE categories
          ADD CONSTRAINT categories_user_id_fkey
          FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
        `,
        { transaction }
      );
    }

    if (!(await constraintExists(transaction, "expenses", "expenses_user_id_fkey"))) {
      await sequelize.query(
        `
          ALTER TABLE expenses
          ADD CONSTRAINT expenses_user_id_fkey
          FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
        `,
        { transaction }
      );
    }

    if (!(await constraintExists(transaction, "incomes", "incomes_user_id_fkey"))) {
      await sequelize.query(
        `
          ALTER TABLE incomes
          ADD CONSTRAINT incomes_user_id_fkey
          FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
        `,
        { transaction }
      );
    }

    if (!(await constraintExists(transaction, "budgets", "budgets_user_id_fkey"))) {
      await sequelize.query(
        `
          ALTER TABLE budgets
          ADD CONSTRAINT budgets_user_id_fkey
          FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
        `,
        { transaction }
      );
    }

    if (!(await constraintExists(transaction, "categories", "categories_id_user_id_key"))) {
      await sequelize.query(
        `
          ALTER TABLE categories
          ADD CONSTRAINT categories_id_user_id_key UNIQUE (id, user_id)
        `,
        { transaction }
      );
    }

    if (await constraintExists(transaction, "categories", "categories_name_key")) {
      await sequelize.query(
        `ALTER TABLE categories DROP CONSTRAINT categories_name_key`,
        { transaction }
      );
    }

    if (!(await constraintExists(transaction, "categories", "categories_user_id_name_key"))) {
      await sequelize.query(
        `
          ALTER TABLE categories
          ADD CONSTRAINT categories_user_id_name_key UNIQUE (user_id, name)
        `,
        { transaction }
      );
    }

    if (!(await constraintExists(transaction, "expenses", "expenses_category_id_user_id_fkey"))) {
      await sequelize.query(
        `
          ALTER TABLE expenses
          ADD CONSTRAINT expenses_category_id_user_id_fkey
          FOREIGN KEY (category_id, user_id)
          REFERENCES categories(id, user_id)
          ON DELETE RESTRICT
        `,
        { transaction }
      );
    }

    if (!(await constraintExists(transaction, "incomes", "incomes_category_id_user_id_fkey"))) {
      await sequelize.query(
        `
          ALTER TABLE incomes
          ADD CONSTRAINT incomes_category_id_user_id_fkey
          FOREIGN KEY (category_id, user_id)
          REFERENCES categories(id, user_id)
          ON DELETE RESTRICT
        `,
        { transaction }
      );
    }

    if (!(await indexExists(transaction, "idx_users_email"))) {
      await sequelize.query(`CREATE INDEX idx_users_email ON users (email)`, {
        transaction
      });
    }

    if (!(await indexExists(transaction, "idx_auth_tokens_user_type"))) {
      await sequelize.query(
        `CREATE INDEX idx_auth_tokens_user_type ON auth_tokens (user_id, token_type)`,
        { transaction }
      );
    }

    if (!(await indexExists(transaction, "idx_auth_tokens_expires_at"))) {
      await sequelize.query(
        `CREATE INDEX idx_auth_tokens_expires_at ON auth_tokens (expires_at)`,
        { transaction }
      );
    }

    if (!(await indexExists(transaction, "idx_categories_user_kind"))) {
      await sequelize.query(
        `CREATE INDEX idx_categories_user_kind ON categories (user_id, kind)`,
        { transaction }
      );
    }

    if (!(await indexExists(transaction, "idx_expenses_user_spent_on"))) {
      await sequelize.query(
        `CREATE INDEX idx_expenses_user_spent_on ON expenses (user_id, spent_on DESC)`,
        { transaction }
      );
    }

    if (!(await indexExists(transaction, "idx_expenses_user_category_id"))) {
      await sequelize.query(
        `CREATE INDEX idx_expenses_user_category_id ON expenses (user_id, category_id)`,
        { transaction }
      );
    }

    if (!(await indexExists(transaction, "idx_incomes_user_received_on"))) {
      await sequelize.query(
        `CREATE INDEX idx_incomes_user_received_on ON incomes (user_id, received_on DESC)`,
        { transaction }
      );
    }

    if (!(await indexExists(transaction, "idx_incomes_user_category_id"))) {
      await sequelize.query(
        `CREATE INDEX idx_incomes_user_category_id ON incomes (user_id, category_id)`,
        { transaction }
      );
    }

    if (!(await indexExists(transaction, "idx_budgets_user_period"))) {
      await sequelize.query(
        `CREATE INDEX idx_budgets_user_period ON budgets (user_id, period)`,
        { transaction }
      );
    }

    if (!(await indexExists(transaction, "idx_budgets_user_start_date"))) {
      await sequelize.query(
        `CREATE INDEX idx_budgets_user_start_date ON budgets (user_id, start_date DESC)`,
        { transaction }
      );
    }

    await query(
      `
        UPDATE users
        SET password_hash = $2
        WHERE email = $1
      `,
      [legacyUserEmail.toLowerCase(), hashPassword(legacyUserPassword)],
      { transaction }
    );

    console.log("Non-destructive auth migration completed.");
    console.log(`Legacy user email: ${legacyUserEmail.toLowerCase()}`);
    console.log(`Legacy user password: ${legacyUserPassword}`);
  });
}

main()
  .catch((error) => {
    console.error("Failed to migrate auth schema.");
    console.error(error);
    process.exitCode = 1;
  })
  .finally(async () => {
    await closeDatabase();
  });
