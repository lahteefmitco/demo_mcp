import { ChatMistralAI, MistralAIEmbeddings } from "@langchain/mistralai";

export function createMistralProvider() {
  const apiKey = process.env.MISTRAL_API_KEY;
  const chatModel = process.env.MISTRAL_MODEL || "mistral-small-latest";
  const embeddingModel = process.env.MISTRAL_EMBEDDING_MODEL || "mistral-embed";

  return {
    name: "mistral",
    modelName: chatModel,
    supportsEmbeddings: Boolean(apiKey),
    createChatModel(options = {}) {
      if (!apiKey) {
        throw new Error("MISTRAL_API_KEY is required to use Mistral.");
      }

      return new ChatMistralAI({
        apiKey,
        model: chatModel,
        temperature: options.temperature ?? 0.2,
        maxRetries: options.maxRetries ?? 2
      });
    },
    createEmbeddingsModel() {
      if (!apiKey) {
        throw new Error("MISTRAL_API_KEY is required to use Mistral embeddings.");
      }

      return new MistralAIEmbeddings({
        apiKey,
        model: embeddingModel
      });
    }
  };
}
