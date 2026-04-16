-- pgvector + RAG storage (run after core schema / users table exists)
CREATE EXTENSION IF NOT EXISTS vector;

CREATE TABLE IF NOT EXISTS ai_documents (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id INT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  document_key TEXT NOT NULL,
  document_type TEXT NOT NULL,
  source_id TEXT,
  content TEXT NOT NULL,
  embedding vector(1024) NOT NULL,
  embedding_provider TEXT NOT NULL,
  embedding_model TEXT NOT NULL,
  metadata JSONB NOT NULL DEFAULT '{}'::jsonb,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE (user_id, document_key)
);

CREATE INDEX IF NOT EXISTS idx_ai_documents_user_id ON ai_documents (user_id);
CREATE INDEX IF NOT EXISTS idx_ai_documents_document_type ON ai_documents (user_id, document_type);

-- Cosine distance; requires sufficient rows for HNSW to be useful (safe on empty table)
CREATE INDEX IF NOT EXISTS idx_ai_documents_embedding_hnsw ON ai_documents
  USING hnsw (embedding vector_cosine_ops);

DROP TRIGGER IF EXISTS trigger_ai_documents_updated_at ON ai_documents;
CREATE TRIGGER trigger_ai_documents_updated_at
BEFORE UPDATE ON ai_documents
FOR EACH ROW
EXECUTE FUNCTION set_updated_at();
