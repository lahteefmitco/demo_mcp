-- Migration: Add UUID columns to all tables
-- This migration adds uuid columns to enable offline sync with local database

-- 1. Add uuid to categories table
ALTER TABLE categories ADD COLUMN IF NOT EXISTS uuid UUID NOT NULL DEFAULT gen_random_uuid();

-- 2. Add uuid to accounts table
ALTER TABLE accounts ADD COLUMN IF NOT EXISTS uuid UUID NOT NULL DEFAULT gen_random_uuid();

-- 3. Add uuid to expenses table
ALTER TABLE expenses ADD COLUMN IF NOT EXISTS uuid UUID NOT NULL DEFAULT gen_random_uuid();

-- 4. Add uuid to incomes table
ALTER TABLE incomes ADD COLUMN IF NOT EXISTS uuid UUID NOT NULL DEFAULT gen_random_uuid();

-- 5. Add uuid to budgets table
ALTER TABLE budgets ADD COLUMN IF NOT EXISTS uuid UUID NOT NULL DEFAULT gen_random_uuid();

-- 6. Add uuid to transfers table
ALTER TABLE transfers ADD COLUMN IF NOT EXISTS uuid UUID NOT NULL DEFAULT gen_random_uuid();

-- 7. Add unique constraint on uuid for each table (after ensuring uniqueness)
ALTER TABLE categories ADD CONSTRAINT unique_categories_uuid UNIQUE (uuid);
ALTER TABLE accounts ADD CONSTRAINT unique_accounts_uuid UNIQUE (uuid);
ALTER TABLE expenses ADD CONSTRAINT unique_expenses_uuid UNIQUE (uuid);
ALTER TABLE incomes ADD CONSTRAINT unique_incomes_uuid UNIQUE (uuid);
ALTER TABLE budgets ADD CONSTRAINT unique_budgets_uuid UNIQUE (uuid);
ALTER TABLE transfers ADD CONSTRAINT unique_transfers_uuid UNIQUE (uuid);

-- 8. Add index on uuid for faster lookups
CREATE INDEX IF NOT EXISTS idx_categories_uuid ON categories (uuid);
CREATE INDEX IF NOT EXISTS idx_accounts_uuid ON accounts (uuid);
CREATE INDEX IF NOT EXISTS idx_expenses_uuid ON expenses (uuid);
CREATE INDEX IF NOT EXISTS idx_incomes_uuid ON incomes (uuid);
CREATE INDEX IF NOT EXISTS idx_budgets_uuid ON budgets (uuid);
CREATE INDEX IF NOT EXISTS idx_transfers_uuid ON transfers (uuid);