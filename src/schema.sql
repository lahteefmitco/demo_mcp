CREATE TABLE IF NOT EXISTS expenses (
  id SERIAL PRIMARY KEY,
  title TEXT NOT NULL,
  amount NUMERIC(12, 2) NOT NULL CHECK (amount >= 0),
  category TEXT NOT NULL,
  spent_on DATE NOT NULL,
  notes TEXT DEFAULT '',
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_expenses_spent_on ON expenses (spent_on DESC);
CREATE INDEX IF NOT EXISTS idx_expenses_category ON expenses (category);

CREATE OR REPLACE FUNCTION set_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trigger_expenses_updated_at ON expenses;

CREATE TRIGGER trigger_expenses_updated_at
BEFORE UPDATE ON expenses
FOR EACH ROW
EXECUTE FUNCTION set_updated_at();
