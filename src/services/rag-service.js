import { query } from "../db.js";

export const RAG_EMBEDDING_DIMENSION = Number(process.env.MISTRAL_EMBEDDING_DIM || 1024);

export function formatVectorForPg(embedding) {
  return `[${embedding.map(Number).join(",")}]`;
}

export async function truncateAiDocuments() {
  await query("TRUNCATE TABLE ai_documents");
}

export async function deleteAiDocumentsForUser(userId) {
  await query("DELETE FROM ai_documents WHERE user_id = $1", [userId]);
}

/**
 * @param {object} row
 * @param {number} row.userId
 * @param {string} row.documentKey
 * @param {string} row.documentType
 * @param {string | null} [row.sourceId]
 * @param {string} row.content
 * @param {number[]} row.embedding
 * @param {string} row.embeddingProvider
 * @param {string} row.embeddingModel
 * @param {object} [row.metadata]
 */
export async function upsertAiDocument(row) {
  const { embedding } = row;
  if (!Array.isArray(embedding) || embedding.length !== RAG_EMBEDDING_DIMENSION) {
    throw new Error(
      `Embedding dimension ${embedding?.length ?? 0} does not match expected ${RAG_EMBEDDING_DIMENSION}`
    );
  }

  const vec = formatVectorForPg(embedding);
  const meta = JSON.stringify(row.metadata ?? {});

  await query(
    `
      INSERT INTO ai_documents (
        user_id, document_key, document_type, source_id, content,
        embedding, embedding_provider, embedding_model, metadata
      )
      VALUES ($1, $2, $3, $4, $5, $6::vector, $7, $8, $9::jsonb)
      ON CONFLICT (user_id, document_key) DO UPDATE SET
        content = EXCLUDED.content,
        embedding = EXCLUDED.embedding,
        document_type = EXCLUDED.document_type,
        source_id = EXCLUDED.source_id,
        embedding_provider = EXCLUDED.embedding_provider,
        embedding_model = EXCLUDED.embedding_model,
        metadata = EXCLUDED.metadata,
        updated_at = NOW()
    `,
    [
      row.userId,
      row.documentKey,
      row.documentType,
      row.sourceId ?? null,
      row.content,
      vec,
      row.embeddingProvider,
      row.embeddingModel,
      meta
    ]
  );
}

/**
 * @param {number} userId
 * @param {number[]} embedding
 * @param {number} limit
 */
export async function searchSimilarDocuments(userId, embedding, limit = 6) {
  if (!Array.isArray(embedding) || embedding.length !== RAG_EMBEDDING_DIMENSION) {
    throw new Error(
      `Query embedding dimension ${embedding?.length ?? 0} does not match expected ${RAG_EMBEDDING_DIMENSION}`
    );
  }

  const vec = formatVectorForPg(embedding);
  const cap = Math.min(Math.max(Number(limit) || 6, 1), 24);

  return query(
    `
      SELECT id, content, document_type, source_id, metadata,
             embedding <=> $2::vector AS distance
      FROM ai_documents
      WHERE user_id = $1
      ORDER BY embedding <=> $2::vector
      LIMIT $3
    `,
    [userId, vec, cap]
  );
}
