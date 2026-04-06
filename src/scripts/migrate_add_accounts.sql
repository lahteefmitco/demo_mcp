-- Migration: Add Account module
-- This migration adds the accounts table and links it to expenses/incomes
-- without altering existing data

-- 1. Create accounts table
CREATE TABLE IF NOT EXISTS accounts (
  id SERIAL PRIMARY KEY,
  user_id INT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  type TEXT NOT NULL DEFAULT 'cash' CHECK (type IN ('cash', 'bank', 'credit_card', 'investments')),
  initial_balance NUMERIC(12, 2) NOT NULL DEFAULT 0,
  color TEXT NOT NULL DEFAULT '#0E7490',
  icon TEXT NOT NULL DEFAULT 'account_balance_wallet',
  notes TEXT DEFAULT '',
  is_active BOOLEAN NOT NULL DEFAULT true,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE (id, user_id),
  UNIQUE (user_id, name)
);

-- 2. Add account_id column to expenses (nullable initially for migration)
ALTER TABLE expenses ADD COLUMN IF NOT EXISTS account_id INT REFERENCES accounts(id) ON DELETE SET NULL;

-- 3. Add account_id column to incomes (nullable initially for migration)
ALTER TABLE incomes ADD COLUMN IF NOT EXISTS account_id INT REFERENCES accounts(id) ON DELETE SET NULL;

-- 4. Create indexes for account lookups
CREATE INDEX IF NOT EXISTS idx_accounts_user_id ON accounts (user_id);
CREATE INDEX IF NOT EXISTS idx_accounts_user_type ON accounts (user_id, type);
CREATE INDEX IF NOT EXISTS idx_expenses_account_id ON expenses (account_id);
CREATE INDEX IF NOT EXISTS idx_incomes_account_id ON incomes (account_id);

-- 5. Create trigger for accounts updated_at
CREATE OR REPLACE FUNCTION set_accounts_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trigger_accounts_updated_at ON accounts;
CREATE TRIGGER trigger_accounts_updated_at
BEFORE UPDATE ON accounts
FOR EACH ROW
EXECUTE FUNCTION set_accounts_updated_at();

-- 6. Create transfers table for tracking transfers between accounts
CREATE TABLE IF NOT EXISTS transfers (
  id SERIAL PRIMARY KEY,
  user_id INT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  from_account_id INT NOT NULL REFERENCES accounts(id) ON DELETE RESTRICT,
  to_account_id INT NOT NULL REFERENCES accounts(id) ON DELETE RESTRICT,
  amount NUMERIC(12, 2) NOT NULL CHECK (amount > 0),
  notes TEXT DEFAULT '',
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  CHECK (from_account_id != to_account_id)
);

CREATE INDEX IF NOT EXISTS idx_transfers_user_id ON transfers (user_id);
CREATE INDEX IF NOT EXISTS idx_transfers_from_account ON transfers (from_account_id);
CREATE INDEX IF NOT EXISTS idx_transfers_to_account ON transfers (to_account_id);
CREATE INDEX IF NOT EXISTS idx_transfers_created_at ON transfers (created_at DESC);
