DROP TRIGGER IF EXISTS trigger_categories_updated_at ON categories;
DROP TRIGGER IF EXISTS trigger_expenses_updated_at ON expenses;
DROP TRIGGER IF EXISTS trigger_incomes_updated_at ON incomes;
DROP TRIGGER IF EXISTS trigger_budgets_updated_at ON budgets;
DROP FUNCTION IF EXISTS set_updated_at();

DROP TABLE IF EXISTS budgets;
DROP TABLE IF EXISTS incomes;
DROP TABLE IF EXISTS expenses;
DROP TABLE IF EXISTS categories;

CREATE TABLE categories (
  id SERIAL PRIMARY KEY,
  name TEXT NOT NULL UNIQUE,
  kind TEXT NOT NULL DEFAULT 'expense' CHECK (kind IN ('expense', 'income', 'both')),
  color TEXT NOT NULL DEFAULT '#0E7490',
  icon TEXT NOT NULL DEFAULT 'tag',
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE expenses (
  id SERIAL PRIMARY KEY,
  title TEXT NOT NULL,
  amount NUMERIC(12, 2) NOT NULL CHECK (amount >= 0),
  category_id INT NOT NULL REFERENCES categories(id) ON DELETE RESTRICT,
  spent_on DATE NOT NULL,
  notes TEXT DEFAULT '',
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE incomes (
  id SERIAL PRIMARY KEY,
  title TEXT NOT NULL,
  amount NUMERIC(12, 2) NOT NULL CHECK (amount >= 0),
  category_id INT NOT NULL REFERENCES categories(id) ON DELETE RESTRICT,
  received_on DATE NOT NULL,
  notes TEXT DEFAULT '',
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE budgets (
  id SERIAL PRIMARY KEY,
  name TEXT NOT NULL,
  category_id INT REFERENCES categories(id) ON DELETE SET NULL,
  period TEXT NOT NULL CHECK (period IN ('daily', 'weekly', 'monthly', 'yearly')),
  amount NUMERIC(12, 2) NOT NULL CHECK (amount >= 0),
  start_date DATE NOT NULL,
  notes TEXT DEFAULT '',
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_categories_kind ON categories (kind);
CREATE INDEX idx_expenses_spent_on ON expenses (spent_on DESC);
CREATE INDEX idx_expenses_category_id ON expenses (category_id);
CREATE INDEX idx_incomes_received_on ON incomes (received_on DESC);
CREATE INDEX idx_incomes_category_id ON incomes (category_id);
CREATE INDEX idx_budgets_period ON budgets (period);
CREATE INDEX idx_budgets_start_date ON budgets (start_date DESC);

CREATE OR REPLACE FUNCTION set_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_categories_updated_at
BEFORE UPDATE ON categories
FOR EACH ROW
EXECUTE FUNCTION set_updated_at();

CREATE TRIGGER trigger_expenses_updated_at
BEFORE UPDATE ON expenses
FOR EACH ROW
EXECUTE FUNCTION set_updated_at();

CREATE TRIGGER trigger_incomes_updated_at
BEFORE UPDATE ON incomes
FOR EACH ROW
EXECUTE FUNCTION set_updated_at();

CREATE TRIGGER trigger_budgets_updated_at
BEFORE UPDATE ON budgets
FOR EACH ROW
EXECUTE FUNCTION set_updated_at();

INSERT INTO categories (name, kind, color, icon) VALUES
  ('Food', 'expense', '#EF4444', 'restaurant'),
  ('Transport', 'expense', '#3B82F6', 'directions_car'),
  ('Bills', 'expense', '#F59E0B', 'receipt_long'),
  ('Shopping', 'expense', '#8B5CF6', 'shopping_bag'),
  ('Salary', 'income', '#10B981', 'payments'),
  ('Freelance', 'income', '#14B8A6', 'work'),
  ('Savings', 'both', '#0EA5A4', 'savings')
ON CONFLICT (name) DO NOTHING;
