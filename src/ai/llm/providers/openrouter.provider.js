import { ChatOpenAI, OpenAIEmbeddings } from "@langchain/openai";

export function createOpenRouterProvider() {
  const apiKey = process.env.OPENROUTER_API_KEY;
  const chatModel = process.env.OPENROUTER_MODEL || "openai/gpt-4o-mini";
  const embeddingModel = process.env.OPENROUTER_EMBEDDING_MODEL;
  const baseURL = process.env.OPENROUTER_BASE_URL || "https://openrouter.ai/api/v1";
  const defaultHeaders = {
    "HTTP-Referer": process.env.OPENROUTER_HTTP_REFERER || "http://localhost:3000",
    "X-Title": process.env.OPENROUTER_APP_TITLE || "Personal Finance Assistant"
  };

  return {
    name: "openrouter",
    modelName: chatModel,
    supportsEmbeddings: Boolean(apiKey && embeddingModel),
    createChatModel(options = {}) {
      if (!apiKey) {
        throw new Error("OPENROUTER_API_KEY is required to use OpenRouter.");
      }

      return new ChatOpenAI({
        apiKey,
        model: chatModel,
        temperature: options.temperature ?? 0.2,
        configuration: {
          baseURL,
          defaultHeaders
        },
        maxRetries: options.maxRetries ?? 2
      });
    },
    createEmbeddingsModel() {
      if (!apiKey || !embeddingModel) {
        throw new Error(
          "OPENROUTER_API_KEY and OPENROUTER_EMBEDDING_MODEL are required to use OpenRouter embeddings."
        );
      }

      return new OpenAIEmbeddings({
        apiKey,
        model: embeddingModel,
        configuration: {
          baseURL,
          defaultHeaders
        }
      });
    }
  };
}
