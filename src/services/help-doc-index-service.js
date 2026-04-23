import { logger } from "../logger.js";
import { mistralEmbedTexts } from "./mistral-embeddings.js";
import { upsertGlobalAiDocument, RAG_EMBEDDING_DIMENSION } from "./rag-service.js";

const EMBEDDING_PROVIDER = "mistral";
const EMBEDDING_MODEL = process.env.MISTRAL_EMBEDDING_MODEL || "mistral-embed";

function splitIntoChunks(text, { maxChars = 1200, overlap = 120 } = {}) {
  const cleaned = String(text || "").replace(/\r\n/g, "\n").trim();
  if (!cleaned) return [];

  const chunks = [];
  let i = 0;

  while (i < cleaned.length) {
    const end = Math.min(cleaned.length, i + maxChars);
    const slice = cleaned.slice(i, end);
    chunks.push(slice.trim());
    if (end >= cleaned.length) break;
    i = Math.max(0, end - overlap);
  }

  return chunks.filter(Boolean);
}

/**
 * Index a single global help document into ai_global_documents.
 * @param {object} opts
 * @param {string} opts.documentKey
 * @param {string} opts.title
 * @param {string} opts.content
 * @param {string} [opts.sourceId]
 * @param {string} [opts.documentType]
 */
export async function indexGlobalHelpDoc({
  documentKey,
  title,
  content,
  sourceId = "global-help",
  documentType = "app_help"
}) {
  if (!process.env.MISTRAL_API_KEY) {
    throw new Error("MISTRAL_API_KEY is required to index help docs.");
  }

  const key = String(documentKey || "").trim();
  if (!key) throw new Error("documentKey is required.");

  const text = String(content || "").trim();
  if (!text) throw new Error("content is required.");

  const chunks = splitIntoChunks(text);
  if (chunks.length === 0) throw new Error("No chunks produced.");

  logger.info("Indexing global help doc", { documentKey: key, chunks: chunks.length });

  // Embed in batches for efficiency.
  const batchSize = 16;
  let stored = 0;

  for (let i = 0; i < chunks.length; i += batchSize) {
    const batch = chunks.slice(i, i + batchSize);
    const embeddings = await mistralEmbedTexts(batch);

    for (let j = 0; j < batch.length; j += 1) {
      const embedding = embeddings[j];
      if (!embedding || embedding.length !== RAG_EMBEDDING_DIMENSION) {
        throw new Error("Embedding generation failed.");
      }

      const chunkKey = `${key}#${String(i + j + 1).padStart(4, "0")}`;
      await upsertGlobalAiDocument({
        documentKey: chunkKey,
        documentType,
        sourceId,
        content: batch[j],
        embedding,
        embeddingProvider: EMBEDDING_PROVIDER,
        embeddingModel: EMBEDDING_MODEL,
        metadata: {
          title: title || key,
          section: `Chunk ${i + j + 1}/${chunks.length}`,
          documentKey: key
        }
      });
      stored += 1;
    }
  }

  return { documentKey: key, chunks: chunks.length, stored };
}

