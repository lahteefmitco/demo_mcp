function readNumber(name, fallback) {
  const value = Number(process.env[name] ?? fallback);
  return Number.isFinite(value) ? value : fallback;
}

function readBoolean(name, fallback) {
  const value = process.env[name];
  if (value == null || value === "") {
    return fallback;
  }

  return ["1", "true", "yes", "on"].includes(String(value).toLowerCase());
}

export function getAiConfig() {
  const defaultProvider = normalizeProviderName(
    process.env.AI_PROVIDER ||
      (process.env.GEMINI_API_KEY
        ? "gemini"
        : process.env.MISTRAL_API_KEY
          ? "mistral"
          : "openrouter")
  );

  return {
    defaultProvider,
    embeddingProvider: normalizeProviderName(
      process.env.EMBEDDING_PROVIDER || defaultProvider
    ),
    embeddingDimensions: readNumber("EMBEDDING_DIMENSIONS", 768),
    semanticSearchTopK: readNumber("SEMANTIC_SEARCH_TOP_K", 6),
    memoryTopK: readNumber("MEMORY_TOP_K", 3),
    shortTermMessageLimit: readNumber("SHORT_TERM_MESSAGE_LIMIT", 12),
    agentMaxIterations: readNumber("AGENT_MAX_ITERATIONS", 6),
    enableCategoryEmbeddings: readBoolean("ENABLE_CATEGORY_EMBEDDINGS", true),
    openRouterBaseUrl: process.env.OPENROUTER_BASE_URL || "https://openrouter.ai/api/v1",
    genericEmbeddingBaseUrl: process.env.GENERIC_EMBEDDING_BASE_URL,
    genericEmbeddingModel: process.env.GENERIC_EMBEDDING_MODEL,
    genericEmbeddingApiKey: process.env.GENERIC_EMBEDDING_API_KEY
  };
}

export function normalizeProviderName(providerName) {
  const normalized = String(providerName || "").trim().toLowerCase();

  if (["gemini", "mistral", "openrouter", "generic"].includes(normalized)) {
    return normalized;
  }

  throw new Error("provider must be one of gemini, mistral, openrouter, or generic");
}
