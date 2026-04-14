import crypto from "node:crypto";
import { getAiConfig } from "../config.js";
import { embedText, similaritySearch, upsertDocument } from "../vector/document-store.js";

export async function storeConversationMemory({
  userId,
  queryText,
  replyText,
  providerName,
  modelName
}) {
  const sourceId = crypto.randomUUID();
  const content = [
    `User query: ${queryText}`,
    `Assistant reply: ${replyText}`
  ].join("\n");
  const embedding = await embedText(content, getAiConfig().embeddingProvider);

  await upsertDocument({
    userId,
    sourceType: "query_memory",
    sourceId,
    content,
    metadata: {
      sourceType: "query_memory",
      providerName,
      modelName
    },
    providerName: embedding.providerName,
    modelName: embedding.modelName,
    vector: embedding.vector
  });
}

export async function searchConversationMemory({ userId, queryText, topK }) {
  return similaritySearch({
    userId,
    queryText,
    topK: topK || getAiConfig().memoryTopK,
    documentTypes: ["query_memory"]
  });
}
