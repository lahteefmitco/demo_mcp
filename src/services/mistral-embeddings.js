const MISTRAL_EMBEDDINGS_URL = "https://api.mistral.ai/v1/embeddings";

/**
 * @param {string[]} texts
 * @param {{ apiKey?: string, model?: string }} [options]
 * @returns {Promise<number[][]>}
 */
export async function mistralEmbedTexts(texts, options = {}) {
  const apiKey = options.apiKey ?? process.env.MISTRAL_API_KEY;
  const model = options.model ?? process.env.MISTRAL_EMBEDDING_MODEL ?? "mistral-embed";

  if (!apiKey) {
    throw new Error("MISTRAL_API_KEY is required for Mistral embeddings.");
  }

  if (!Array.isArray(texts) || texts.length === 0) {
    return [];
  }

  const response = await fetch(MISTRAL_EMBEDDINGS_URL, {
    method: "POST",
    headers: {
      Authorization: `Bearer ${apiKey}`,
      "Content-Type": "application/json"
    },
    body: JSON.stringify({ model, input: texts })
  });

  if (!response.ok) {
    const errorText = await response.text();
    throw new Error(`Mistral embeddings error ${response.status}: ${errorText}`);
  }

  const data = await response.json();
  const items = data?.data;

  if (!Array.isArray(items)) {
    throw new Error("Mistral embeddings: unexpected response shape.");
  }

  items.sort((a, b) => a.index - b.index);
  return items.map((row) => row.embedding);
}
