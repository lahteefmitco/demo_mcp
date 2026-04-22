-- Migration Script: Add Google Authentication Support
-- Run this directly in your Neon SQL console

-- 1. Make the password_hash column nullable
-- (This allows users to sign up via Google without a password)
ALTER TABLE users ALTER COLUMN password_hash DROP NOT NULL;

-- 2. Add the google_id column and ensure it is unique
-- (This stores the unique identifier provided by Google)
ALTER TABLE users ADD COLUMN IF NOT EXISTS google_id TEXT UNIQUE;

-- Note: The UNIQUE constraint automatically creates an index on google_id,
-- so no separate CREATE INDEX statement is necessary.
