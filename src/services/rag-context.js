import { logger } from "../logger.js";
import { mistralEmbedTexts } from "./mistral-embeddings.js";
import { RAG_EMBEDDING_DIMENSION, searchSimilarDocuments, searchSimilarGlobalDocuments } from "./rag-service.js";

let missingKeyLogged = false;

export function getLastUserMessageText(history) {
  if (!Array.isArray(history)) {
    return "";
  }

  for (let i = history.length - 1; i >= 0; i -= 1) {
    const m = history[i];
    if (m?.role === "user" && typeof m.content === "string") {
      return m.content.trim();
    }
  }

  return "";
}

/**
 * Returns a block to prepend to the system prompt (may be empty).
 * @param {number} userId
 * @param {string} userMessageText
 */
export async function buildRagContextBlock(userId, userMessageText) {
  if (!process.env.MISTRAL_API_KEY) {
    if (!missingKeyLogged) {
      logger.warn("RAG skipped: MISTRAL_API_KEY is not set.");
      missingKeyLogged = true;
    }
    return "";
  }

  const trimmed = (userMessageText || "").trim();
  if (trimmed.length < 2) {
    return "";
  }

  let embeddings;
  try {
    embeddings = await mistralEmbedTexts([trimmed]);
  } catch (error) {
    logger.warn("RAG embedding request failed.", { message: error?.message });
    return "";
  }

  const embedding = embeddings[0];
  if (!embedding || embedding.length !== RAG_EMBEDDING_DIMENSION) {
    logger.warn("RAG skipped: invalid embedding dimensions.");
    return "";
  }

  const topK = Math.min(24, Math.max(1, Number(process.env.RAG_TOP_K || 6)));

  let rows;
  try {
    rows = await searchSimilarDocuments(userId, embedding, topK);
  } catch (error) {
    logger.warn("RAG search failed.", { message: error?.message });
    return "";
  }

  if (!Array.isArray(rows) || rows.length === 0) {
    return "";
  }

  const lines = rows.map((row, idx) => {
    const preview = (row.content || "").slice(0, 1600);
    const src = row.source_id ? ` source_id=${row.source_id}` : "";
    return `[${idx + 1}] (${row.document_type || "doc"}${src})\n${preview}`;
  });

  return [
    "Retrieved context from the user's knowledge base (may be incomplete; use tools for authoritative numbers):",
    ...lines
  ].join("\n\n");
}

export async function ragSearchForUser(userId, queryText, limit = 8) {
  if (!process.env.MISTRAL_API_KEY) {
    throw new Error("MISTRAL_API_KEY is required for rag_search.");
  }

  const trimmed = (queryText || "").trim();
  if (!trimmed) {
    return [];
  }

  const cap = Math.min(24, Math.max(1, Number(limit) || 8));
  const [embedding] = await mistralEmbedTexts([trimmed]);

  if (!embedding || embedding.length !== RAG_EMBEDDING_DIMENSION) {
    throw new Error("Embedding generation failed.");
  }

  return searchSimilarDocuments(userId, embedding, cap);
}

export async function ragSearchGlobal(queryText, limit = 8) {
  if (!process.env.MISTRAL_API_KEY) {
    throw new Error("MISTRAL_API_KEY is required for rag_search.");
  }

  const trimmed = (queryText || "").trim();
  if (!trimmed) {
    return [];
  }

  const cap = Math.min(24, Math.max(1, Number(limit) || 8));
  const [embedding] = await mistralEmbedTexts([trimmed]);

  if (!embedding || embedding.length !== RAG_EMBEDDING_DIMENSION) {
    throw new Error("Embedding generation failed.");
  }

  return searchSimilarGlobalDocuments(embedding, cap);
}
