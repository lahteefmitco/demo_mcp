import { OpenAIEmbeddings } from "@langchain/openai";

export function createGenericEmbeddingProvider({ baseURL, apiKey, modelName }) {
  return {
    name: "generic",
    modelName,
    supportsEmbeddings: Boolean(baseURL && apiKey && modelName),
    createChatModel() {
      throw new Error("Generic provider only supports embeddings.");
    },
    createEmbeddingsModel() {
      if (!baseURL || !apiKey || !modelName) {
        throw new Error(
          "GENERIC_EMBEDDING_BASE_URL, GENERIC_EMBEDDING_API_KEY, and GENERIC_EMBEDDING_MODEL are required."
        );
      }

      return new OpenAIEmbeddings({
        apiKey,
        model: modelName,
        configuration: {
          baseURL
        }
      });
    }
  };
}
