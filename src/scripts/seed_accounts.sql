-- Seed script: Create default account for existing users
-- Run this after migrate_add_accounts.sql

-- Create default "General Account" for each user that doesn't have one
INSERT INTO accounts (user_id, name, type, initial_balance, color, icon, notes)
SELECT 
  u.id,
  'General Account',
  'cash',
  0,
  '#10B981',
  'account_balance_wallet',
  'Default account for all transactions'
FROM users u
WHERE NOT EXISTS (
  SELECT 1 FROM accounts a WHERE a.user_id = u.id AND a.name = 'General Account'
);

-- Update existing expenses to use "General Account" if they have no account_id
UPDATE expenses e
SET account_id = (
  SELECT a.id FROM accounts a 
  WHERE a.user_id = e.user_id AND a.name = 'General Account'
  LIMIT 1
)
WHERE e.account_id IS NULL;

-- Update existing incomes to use "General Account" if they have no account_id
UPDATE incomes i
SET account_id = (
  SELECT a.id FROM accounts a 
  WHERE a.user_id = i.user_id AND a.name = 'General Account'
  LIMIT 1
)
WHERE i.account_id IS NULL;

-- Make account_id NOT NULL (all records now have an account)
ALTER TABLE expenses ALTER COLUMN account_id SET NOT NULL;
ALTER TABLE incomes ALTER COLUMN account_id SET NOT NULL;
