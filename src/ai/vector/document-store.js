import { QueryTypes, query } from "../../db.js";
import { getAiConfig } from "../config.js";
import { getEmbeddingProvider } from "../llm/provider-factory.js";
import { buildDocumentKey, toPgVectorLiteral } from "./pgvector-utils.js";

export async function embedText(text, providerName) {
  const provider = getEmbeddingProvider(providerName);
  const model = provider.createEmbeddingsModel();
  const [vector] = await model.embedDocuments([text]);

  return {
    providerName: provider.name,
    modelName: provider.modelName,
    vector
  };
}

export async function upsertDocument({
  userId,
  sourceType,
  sourceId,
  content,
  metadata = {},
  providerName,
  modelName,
  vector
}) {
  const documentKey = buildDocumentKey(sourceType, sourceId);

  await query(
    `
      INSERT INTO ai_documents (
        user_id,
        document_key,
        document_type,
        source_id,
        content,
        metadata,
        embedding_provider,
        embedding_model,
        embedding
      )
      VALUES ($1, $2, $3, $4, $5, $6::jsonb, $7, $8, $9::vector)
      ON CONFLICT (user_id, document_key)
      DO UPDATE SET
        content = EXCLUDED.content,
        metadata = EXCLUDED.metadata,
        embedding_provider = EXCLUDED.embedding_provider,
        embedding_model = EXCLUDED.embedding_model,
        embedding = EXCLUDED.embedding,
        updated_at = NOW()
    `,
    [
      userId,
      documentKey,
      sourceType,
      sourceId,
      content,
      JSON.stringify(metadata),
      providerName,
      modelName,
      toPgVectorLiteral(vector)
    ]
  );
}

export async function deleteDocument({ userId, sourceType, sourceId }) {
  await query(
    `
      DELETE FROM ai_documents
      WHERE user_id = $1
        AND document_key = $2
    `,
    [userId, buildDocumentKey(sourceType, sourceId)]
  );
}

export async function similaritySearch({
  userId,
  queryText,
  topK = getAiConfig().semanticSearchTopK,
  documentTypes = []
}) {
  const { providerName, modelName, vector } = await embedText(queryText);
  const values = [userId, toPgVectorLiteral(vector)];
  const conditions = ["user_id = $1"];

  if (Array.isArray(documentTypes) && documentTypes.length > 0) {
    const placeholders = documentTypes.map((documentType) => {
      values.push(documentType);
      return `$${values.length}`;
    });
    conditions.push(`document_type IN (${placeholders.join(", ")})`);
  }

  values.push(topK);

  const rows = await query(
    `
      SELECT
        id,
        document_key,
        document_type,
        source_id,
        content,
        metadata,
        embedding_provider,
        embedding_model,
        created_at,
        updated_at,
        1 - (embedding <=> $2::vector) AS similarity
      FROM ai_documents
      WHERE ${conditions.join(" AND ")}
      ORDER BY embedding <=> $2::vector
      LIMIT $${values.length}
    `,
    values,
    { type: QueryTypes.SELECT }
  );

  return {
    queryEmbedding: {
      providerName,
      modelName
    },
    matches: rows.map((row) => ({
      id: row.id,
      documentKey: row.document_key,
      documentType: row.document_type,
      sourceId: row.source_id,
      content: row.content,
      metadata: row.metadata || {},
      similarity: Number(row.similarity),
      createdAt: row.created_at,
      updatedAt: row.updated_at
    }))
  };
}
