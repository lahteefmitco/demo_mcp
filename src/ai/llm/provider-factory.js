import { getAiConfig, normalizeProviderName } from "../config.js";
import { createGenericEmbeddingProvider } from "./providers/generic.provider.js";
import { createGeminiProvider } from "./providers/gemini.provider.js";
import { createMistralProvider } from "./providers/mistral.provider.js";
import { createOpenRouterProvider } from "./providers/openrouter.provider.js";

export function getLLMProvider(providerName) {
  const normalized = normalizeProviderName(providerName || getAiConfig().defaultProvider);

  if (normalized === "gemini") {
    return createGeminiProvider();
  }

  if (normalized === "mistral") {
    return createMistralProvider();
  }

  if (normalized === "openrouter") {
    return createOpenRouterProvider();
  }

  throw new Error("Generic provider does not implement chat.");
}

export function getEmbeddingProvider(providerName) {
  const config = getAiConfig();
  const normalized = normalizeProviderName(providerName || config.embeddingProvider);

  if (normalized === "gemini") {
    return createGeminiProvider();
  }

  if (normalized === "mistral") {
    return createMistralProvider();
  }

  if (normalized === "openrouter") {
    return createOpenRouterProvider();
  }

  return createGenericEmbeddingProvider({
    baseURL: config.genericEmbeddingBaseUrl,
    apiKey: config.genericEmbeddingApiKey,
    modelName: config.genericEmbeddingModel
  });
}
