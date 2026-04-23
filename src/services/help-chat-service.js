import { logger } from "../logger.js";
import { getLastUserMessageText, ragSearchGlobal } from "./rag-context.js";

const geminiApiKey = process.env.GEMINI_API_KEY;
const geminiModel = process.env.GEMINI_MODEL || "gemini-2.5-flash";
const geminiApiBaseUrl = "https://generativelanguage.googleapis.com/v1beta";
const mistralApiKey = process.env.MISTRAL_API_KEY;
const mistralModel = process.env.MISTRAL_MODEL || "mistral-small-latest";
const mistralApiBaseUrl = "https://api.mistral.ai/v1";
const openRouterApiKey = process.env.OPENROUTER_API_KEY;
const openRouterModel = process.env.OPENROUTER_MODEL || "openai/gpt-4o-mini";
const openRouterApiBaseUrl = "https://openrouter.ai/api/v1";

function normalizeProvider(provider) {
  const normalized = String(provider || "").trim().toLowerCase();
  if (["gemini", "mistral", "openrouter"].includes(normalized)) return normalized;
  return "gemini";
}

function normalizeOpenAiChatHistory(history) {
  return history
    .filter((m) => m && typeof m.content === "string")
    .map((m) => ({ role: m.role, content: m.content }));
}

function extractOpenAiText(message) {
  return message?.content ?? "";
}

function normalizeGeminiChatHistory(history) {
  // Gemini uses role: user|model. We'll map assistant -> model.
  return history
    .filter((m) => m && typeof m.content === "string")
    .filter((m) => m.role === "user" || m.role === "assistant")
    .map((m) => ({
      role: m.role === "assistant" ? "model" : "user",
      parts: [{ text: m.content }]
    }));
}

function extractGeminiText(content) {
  const parts = content?.parts ?? content?.content?.parts ?? [];
  const text = parts.map((p) => p.text).filter(Boolean).join("");
  return text || "";
}

function buildRagBlock(rows) {
  if (!Array.isArray(rows) || rows.length === 0) return "";

  const lines = rows.map((row, idx) => {
    const meta = row.metadata ?? {};
    const title = meta.title || meta.path || meta.section || row.source_id || `doc_${row.id}`;
    const section = meta.section ? ` • ${meta.section}` : "";
    const preview = String(row.content || "").slice(0, 1600);
    return `[${idx + 1}] ${title}${section}\n${preview}`;
  });

  return ["Retrieved documentation chunks (use as the ONLY source of truth):", ...lines].join(
    "\n\n"
  );
}

function citationsFromRows(rows) {
  if (!Array.isArray(rows)) return [];
  return rows.map((row) => {
    const meta = row.metadata ?? {};
    return {
      id: String(row.source_id || row.id || ""),
      title: String(meta.title || meta.path || meta.section || row.source_id || row.document_type || ""),
      section: meta.section ? String(meta.section) : undefined
    };
  });
}

function buildHelpSystemPrompt({ ragBlock, appVersion, maxWords, screen }) {
  const versionTag = appVersion ? `[${appVersion}]` : "[APP_VERSION]";
  const screenLine = screen ? `\nCurrent screen: ${screen}\n` : "\n";

  return [
    `You are a product assistant for the mobile app described ONLY in the retrieved documentation chunks and in the ${versionTag} release notes. Your job is to help users use the app: navigation, features, and troubleshooting, using only that evidence.`,
    screenLine.trim(),
    "Rules:",
    "- Answer using the retrieved context. If the context is insufficient, say you don't have that in the in-app help and suggest what the user can try (e.g. check Settings) without inventing features.",
    "- Do not invent UI labels, screen names, settings paths, or server/API behavior. If uncertain, state the uncertainty and ask one clarifying question.",
    "- Prefer short, scannable answers: bullets for steps, bold for key actions (Open → Tap →).",
    "- If the user asks for financial advice, say you can only explain how to use the app, not how to invest or budget.",
    "- Never ask for or store secrets (passwords, tokens, full card numbers, PINs).",
    "- If the user reports a bug, capture: what they tapped, what they expected, what happened, and app version, and suggest checking network/sync status only if the docs support it.",
    "- Cite your sources: after each major claim, add [source: <chunk_id or section title>].",
    `- Keep answers under ${maxWords} words unless the user asks for a detailed walkthrough.`,
    "",
    ragBlock
  ]
    .filter(Boolean)
    .join("\n");
}

export async function runHelpChat(history, user, { appVersion = "", maxWords = 220, screen = "" } = {}) {
  const provider = normalizeProvider(process.env.HELP_CHAT_PROVIDER || "gemini");
  const userText = getLastUserMessageText(history);

  let rows = [];
  try {
    rows = await ragSearchGlobal(userText, Number(process.env.HELP_RAG_TOP_K || 8));
  } catch (error) {
    logger.warn("Help RAG search failed; continuing without context.", { message: error?.message });
    rows = [];
  }

  const ragBlock = buildRagBlock(rows);
  const citations = citationsFromRows(rows);
  const systemPrompt = buildHelpSystemPrompt({ ragBlock, appVersion, maxWords, screen });

  if (provider === "gemini") {
    if (!geminiApiKey) throw new Error("GEMINI_API_KEY is required to use Gemini help chat.");
    const contents = normalizeGeminiChatHistory(history);

    const response = await fetch(`${geminiApiBaseUrl}/models/${geminiModel}:generateContent`, {
      method: "POST",
      headers: {
        "x-goog-api-key": geminiApiKey,
        "Content-Type": "application/json"
      },
      body: JSON.stringify({
        system_instruction: { parts: [{ text: systemPrompt }] },
        contents,
        generationConfig: { temperature: 0.2 }
      })
    });

    if (!response.ok) {
      const errorText = await response.text();
      throw new Error(`Gemini API error ${response.status}: ${errorText}`);
    }

    const data = await response.json();
    const assistantMessage = data.candidates?.[0]?.content;
    const reply = extractGeminiText(assistantMessage);
    return { reply, citations };
  }

  // OpenAI-compatible providers (Mistral/OpenRouter)
  let apiKey;
  let model;
  let apiBaseUrl;
  let extraHeaders = {};

  if (provider === "mistral") {
    if (!mistralApiKey) throw new Error("MISTRAL_API_KEY is required to use Mistral help chat.");
    apiKey = mistralApiKey;
    model = mistralModel;
    apiBaseUrl = mistralApiBaseUrl;
  } else {
    if (!openRouterApiKey) throw new Error("OPENROUTER_API_KEY is required to use OpenRouter help chat.");
    apiKey = openRouterApiKey;
    model = openRouterModel;
    apiBaseUrl = openRouterApiBaseUrl;
    extraHeaders = {
      "HTTP-Referer": process.env.OPENROUTER_HTTP_REFERER || "http://localhost:3000",
      "X-Title": process.env.OPENROUTER_APP_TITLE || "Personal Finance Mobile"
    };
  }

  const messages = [{ role: "system", content: systemPrompt }, ...normalizeOpenAiChatHistory(history)];

  const resp = await fetch(`${apiBaseUrl}/chat/completions`, {
    method: "POST",
    headers: {
      Authorization: `Bearer ${apiKey}`,
      "Content-Type": "application/json",
      ...extraHeaders
    },
    body: JSON.stringify({
      model,
      messages,
      temperature: 0.2
    })
  });

  if (!resp.ok) {
    const errorText = await resp.text();
    throw new Error(`${provider} API error ${resp.status}: ${errorText}`);
  }

  const data = await resp.json();
  const assistantMessage = data.choices?.[0]?.message;
  const reply = extractOpenAiText(assistantMessage);
  return { reply, citations };
}

