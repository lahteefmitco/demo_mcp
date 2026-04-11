import { closeDatabase, query } from "../db.js";
import { getAiConfig } from "../ai/config.js";

async function main() {
  const { embeddingDimensions } = getAiConfig();

  await query("CREATE EXTENSION IF NOT EXISTS pgcrypto");
  await query("CREATE EXTENSION IF NOT EXISTS vector");

  await query(
    `
      CREATE TABLE IF NOT EXISTS ai_documents (
        id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
        user_id INT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
        document_key TEXT NOT NULL,
        document_type TEXT NOT NULL CHECK (
          document_type IN ('expense', 'income', 'category', 'account', 'budget', 'transfer', 'query_memory')
        ),
        source_id TEXT NOT NULL,
        content TEXT NOT NULL,
        metadata JSONB NOT NULL DEFAULT '{}'::jsonb,
        embedding_provider TEXT NOT NULL,
        embedding_model TEXT NOT NULL,
        embedding VECTOR(${embeddingDimensions}) NOT NULL,
        created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
        updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
        UNIQUE (user_id, document_key)
      )
    `
  );

  await query(
    `
      CREATE INDEX IF NOT EXISTS idx_ai_documents_user_type
      ON ai_documents (user_id, document_type, updated_at DESC)
    `
  );
  await query(
    `
      CREATE INDEX IF NOT EXISTS idx_ai_documents_metadata_gin
      ON ai_documents USING GIN (metadata)
    `
  );

  try {
    await query(
      `
        CREATE INDEX IF NOT EXISTS idx_ai_documents_embedding_hnsw
        ON ai_documents
        USING hnsw (embedding vector_cosine_ops)
      `
    );
  } catch (error) {
    console.warn("HNSW index creation failed, falling back to IVFFLAT:", error.message);
    await query(
      `
        CREATE INDEX IF NOT EXISTS idx_ai_documents_embedding_ivfflat
        ON ai_documents
        USING ivfflat (embedding vector_cosine_ops)
        WITH (lists = 100)
      `
    );
  }

  await query("ANALYZE ai_documents");
  console.log(`AI schema is ready with vector(${embeddingDimensions}).`);
}

main()
  .catch((error) => {
    console.error("Failed to migrate AI schema.");
    console.error(error);
    process.exitCode = 1;
  })
  .finally(async () => {
    await closeDatabase();
  });
