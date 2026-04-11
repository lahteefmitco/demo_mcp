import { ChatGoogleGenerativeAI, GoogleGenerativeAIEmbeddings } from "@langchain/google-genai";

export function createGeminiProvider() {
  const apiKey = process.env.GEMINI_API_KEY;
  const chatModel = process.env.GEMINI_MODEL || "gemini-2.5-flash";
  const embeddingModel = process.env.GEMINI_EMBEDDING_MODEL || "text-embedding-004";

  return {
    name: "gemini",
    modelName: chatModel,
    supportsEmbeddings: Boolean(apiKey),
    createChatModel(options = {}) {
      if (!apiKey) {
        throw new Error("GEMINI_API_KEY is required to use Gemini.");
      }

      return new ChatGoogleGenerativeAI({
        apiKey,
        model: chatModel,
        temperature: options.temperature ?? 0.2,
        maxRetries: options.maxRetries ?? 2
      });
    },
    createEmbeddingsModel() {
      if (!apiKey) {
        throw new Error("GEMINI_API_KEY is required to use Gemini embeddings.");
      }

      return new GoogleGenerativeAIEmbeddings({
        apiKey,
        model: embeddingModel
      });
    }
  };
}
