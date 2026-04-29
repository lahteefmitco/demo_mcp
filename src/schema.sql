DROP TRIGGER IF EXISTS trigger_users_updated_at ON users;
DROP TRIGGER IF EXISTS trigger_categories_updated_at ON categories;
DROP TRIGGER IF EXISTS trigger_expenses_updated_at ON expenses;
DROP TRIGGER IF EXISTS trigger_incomes_updated_at ON incomes;
DROP TRIGGER IF EXISTS trigger_budgets_updated_at ON budgets;
DROP TRIGGER IF EXISTS trigger_categories_level ON categories;
DROP TRIGGER IF EXISTS trigger_categories_circular_reference ON categories;
DROP FUNCTION IF EXISTS set_updated_at();
DROP FUNCTION IF EXISTS set_category_level();
DROP FUNCTION IF EXISTS check_category_circular_reference();

CREATE TABLE IF NOT EXISTS users (
  id SERIAL PRIMARY KEY,
  name TEXT NOT NULL,
  email TEXT NOT NULL UNIQUE,
  password_hash TEXT,
  google_id TEXT UNIQUE,
  is_verified BOOLEAN NOT NULL DEFAULT false,
  pending_email TEXT,
  email_verified_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS auth_tokens (
  id SERIAL PRIMARY KEY,
  user_id INT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  token_hash TEXT NOT NULL UNIQUE,
  token_type TEXT NOT NULL CHECK (token_type IN ('verify_email', 'password_reset', 'change_email', 'delete_account')),
  email TEXT,
  expires_at TIMESTAMPTZ NOT NULL,
  consumed_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS categories (
  id SERIAL PRIMARY KEY,
  user_id INT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  parent_id INT,
  name TEXT NOT NULL,
  kind TEXT NOT NULL DEFAULT 'expense' CHECK (kind IN ('expense', 'income', 'both')),
  color TEXT NOT NULL DEFAULT '#0E7490',
  icon TEXT NOT NULL DEFAULT 'tag',
  level INT NOT NULL DEFAULT 0,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE (id, user_id),
  UNIQUE (user_id, parent_id, name),
  FOREIGN KEY (parent_id, user_id) REFERENCES categories(id, user_id) ON DELETE RESTRICT
);

CREATE TABLE IF NOT EXISTS expenses (
  id SERIAL PRIMARY KEY,
  user_id INT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  amount NUMERIC(12, 2) NOT NULL CHECK (amount >= 0),
  category_id INT NOT NULL,
  spent_on DATE NOT NULL,
  notes TEXT DEFAULT '',
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  FOREIGN KEY (category_id, user_id) REFERENCES categories(id, user_id) ON DELETE RESTRICT
);

CREATE TABLE IF NOT EXISTS incomes (
  id SERIAL PRIMARY KEY,
  user_id INT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  amount NUMERIC(12, 2) NOT NULL CHECK (amount >= 0),
  category_id INT NOT NULL,
  received_on DATE NOT NULL,
  notes TEXT DEFAULT '',
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  FOREIGN KEY (category_id, user_id) REFERENCES categories(id, user_id) ON DELETE RESTRICT
);

CREATE TABLE IF NOT EXISTS budgets (
  id SERIAL PRIMARY KEY,
  user_id INT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  category_id INT REFERENCES categories(id) ON DELETE SET NULL,
  period TEXT NOT NULL CHECK (period IN ('daily', 'weekly', 'monthly', 'yearly')),
  amount NUMERIC(12, 2) NOT NULL CHECK (amount >= 0),
  start_date DATE NOT NULL,
  notes TEXT DEFAULT '',
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_users_email ON users (email);
CREATE INDEX IF NOT EXISTS idx_auth_tokens_user_type ON auth_tokens (user_id, token_type);
CREATE INDEX IF NOT EXISTS idx_auth_tokens_expires_at ON auth_tokens (expires_at);
CREATE INDEX IF NOT EXISTS idx_categories_user_kind ON categories (user_id, kind);
CREATE INDEX IF NOT EXISTS idx_categories_parent_id ON categories (parent_id);
CREATE INDEX IF NOT EXISTS idx_categories_level ON categories (level);
CREATE INDEX IF NOT EXISTS idx_expenses_user_spent_on ON expenses (user_id, spent_on DESC);
CREATE INDEX IF NOT EXISTS idx_expenses_user_category_id ON expenses (user_id, category_id);
CREATE INDEX IF NOT EXISTS idx_incomes_user_received_on ON incomes (user_id, received_on DESC);
CREATE INDEX IF NOT EXISTS idx_incomes_user_category_id ON incomes (user_id, category_id);
CREATE INDEX IF NOT EXISTS idx_budgets_user_period ON budgets (user_id, period);
CREATE INDEX IF NOT EXISTS idx_budgets_user_start_date ON budgets (user_id, start_date DESC);

CREATE OR REPLACE FUNCTION set_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION set_category_level()
RETURNS TRIGGER AS $$
DECLARE
  parent_level INT;
BEGIN
  IF NEW.parent_id IS NULL THEN
    NEW.level = 0;
  ELSE
    SELECT level INTO parent_level FROM categories WHERE id = NEW.parent_id AND user_id = NEW.user_id;
    IF parent_level IS NULL THEN
      RAISE EXCEPTION 'Parent category not found for user';
    END IF;
    NEW.level = parent_level + 1;
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION check_category_circular_reference()
RETURNS TRIGGER AS $$
DECLARE
  current_id INT;
  visited_ids INT[];
BEGIN
  IF NEW.parent_id IS NULL THEN
    RETURN NEW;
  END IF;

  current_id = NEW.parent_id;
  visited_ids = ARRAY[NEW.id];

  WHILE current_id IS NOT NULL LOOP
    IF current_id = ANY(visited_ids) THEN
      RAISE EXCEPTION 'Circular reference detected in category hierarchy';
    END IF;
    visited_ids = visited_ids || current_id;
    SELECT parent_id INTO current_id FROM categories WHERE id = current_id AND user_id = NEW.user_id;
  END LOOP;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_users_updated_at
BEFORE UPDATE ON users
FOR EACH ROW
EXECUTE FUNCTION set_updated_at();

CREATE TRIGGER trigger_categories_updated_at
BEFORE UPDATE ON categories
FOR EACH ROW
EXECUTE FUNCTION set_updated_at();

CREATE TRIGGER trigger_categories_level
BEFORE INSERT OR UPDATE OF parent_id ON categories
FOR EACH ROW
EXECUTE FUNCTION set_category_level();

CREATE TRIGGER trigger_categories_circular_reference
BEFORE INSERT OR UPDATE OF parent_id ON categories
FOR EACH ROW
EXECUTE FUNCTION check_category_circular_reference();

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
