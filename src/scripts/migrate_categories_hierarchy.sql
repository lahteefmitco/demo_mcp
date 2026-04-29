-- ============================================
-- Neon Database Migration: Hierarchical Categories
-- Includes: Parent-Child relationships, Levels, Kind Compatibility
-- Idempotent: Safe to run multiple times
-- ============================================

-- 1. Add parent_id column if not exists
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'categories' AND column_name = 'parent_id'
  ) THEN
    ALTER TABLE categories ADD COLUMN parent_id INT;
  END IF;
END $$;

-- 2. Add level column if not exists (default 0 for existing rows)
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'categories' AND column_name = 'level'
  ) THEN
    ALTER TABLE categories ADD COLUMN level INT NOT NULL DEFAULT 0;
  END IF;
END $$;

-- 3. Add composite foreign key for parent_id (if not exists)
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.table_constraints
    WHERE constraint_name = 'categories_parent_id_fkey'
  ) THEN
    ALTER TABLE categories
    ADD CONSTRAINT categories_parent_id_fkey
    FOREIGN KEY (parent_id, user_id) REFERENCES categories(id, user_id) ON DELETE RESTRICT;
  END IF;
END $$;

-- 4. Update Unique Constraint (Drop old, Add new)
DO $$
BEGIN
  -- Drop old unique constraint if it exists
  IF EXISTS (
    SELECT 1 FROM information_schema.table_constraints
    WHERE table_name = 'categories' AND constraint_name = 'categories_user_id_name_key'
  ) THEN
    ALTER TABLE categories DROP CONSTRAINT categories_user_id_name_key;
  END IF;

  -- Add new unique constraint if not exists
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.table_constraints
    WHERE table_name = 'categories' AND constraint_name = 'categories_user_id_parent_id_name_key'
  ) THEN
    ALTER TABLE categories ADD CONSTRAINT categories_user_id_parent_id_name_key
    UNIQUE (user_id, parent_id, name);
  END IF;
END $$;

-- 5. Create Function: Auto-set level based on parent
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

-- 6. Create Function: Prevent circular references
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

-- 7. Create Function: Kind Compatibility Check
-- Ensures parent and child kinds are compatible
CREATE OR REPLACE FUNCTION check_category_kind_compatibility()
RETURNS TRIGGER AS $$
DECLARE
  parent_kind TEXT;
BEGIN
  IF NEW.parent_id IS NULL THEN
    RETURN NEW;
  END IF;

  SELECT kind INTO parent_kind FROM categories WHERE id = NEW.parent_id AND user_id = NEW.user_id;

  IF parent_kind IS NULL THEN
    RAISE EXCEPTION 'Parent category not found';
  END IF;

  -- 'both' kind can have any parent
  IF NEW.kind = 'both' THEN
    RETURN NEW;
  END IF;

  -- Any child can have 'both' parent
  IF parent_kind = 'both' THEN
    RETURN NEW;
  END IF;

  -- Kind must match
  IF NEW.kind != parent_kind THEN
    RAISE EXCEPTION 'Child category kind (%) must match parent kind (%) or be both', NEW.kind, parent_kind;
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- 8. Create Triggers (Drop first to allow updates)
DROP TRIGGER IF EXISTS trigger_categories_level ON categories;
CREATE TRIGGER trigger_categories_level
BEFORE INSERT OR UPDATE OF parent_id ON categories
FOR EACH ROW
EXECUTE FUNCTION set_category_level();

DROP TRIGGER IF EXISTS trigger_categories_circular_reference ON categories;
CREATE TRIGGER trigger_categories_circular_reference
BEFORE INSERT OR UPDATE OF parent_id ON categories
FOR EACH ROW
EXECUTE FUNCTION check_category_circular_reference();

DROP TRIGGER IF EXISTS trigger_categories_kind_compatibility ON categories;
CREATE TRIGGER trigger_categories_kind_compatibility
BEFORE INSERT OR UPDATE OF kind, parent_id ON categories
FOR EACH ROW
EXECUTE FUNCTION check_category_kind_compatibility();

-- 9. Create Indexes (if not exists)
CREATE INDEX IF NOT EXISTS idx_categories_parent_id ON categories (parent_id);
CREATE INDEX IF NOT EXISTS idx_categories_level ON categories (level);

-- 10. Backfill level for existing rows (safe to run multiple times)
UPDATE categories SET level = 0 WHERE parent_id IS NULL AND level != 0;
