import { AIMessage, HumanMessage, createAgent } from "langchain";
import { getAiConfig } from "../config.js";
import { getLLMProvider } from "../llm/provider-factory.js";
import { searchConversationMemory, storeConversationMemory } from "../memory/conversation-memory.js";
import { createFinanceLangChainTools } from "./mcp-langchain-tools.js";

export async function runFinanceAgent({ history, providerName, user }) {
  validateChatHistory(history);

  const config = getAiConfig();
  const provider = getLLMProvider(providerName || config.defaultProvider);
  const model = provider.createChatModel({ temperature: 0.2 });
  const tools = createFinanceLangChainTools({ user });
  const lastUserMessage = [...history].reverse().find((message) => message.role === "user");
  const memoryContext = lastUserMessage
    ? await searchConversationMemory({
        userId: user.id,
        queryText: lastUserMessage.content,
        topK: config.memoryTopK
      })
    : { matches: [] };

  const agent = createAgent({
    llm: model,
    tools,
    prompt: buildSystemInstruction(memoryContext.matches)
  });

  const messages = toLangChainMessages(
    history.slice(Math.max(0, history.length - config.shortTermMessageLimit))
  );
  const result = await agent.invoke({
    messages
  }, {
    recursionLimit: config.agentMaxIterations
  });
  const reply = extractAgentReply(result.messages);

  await storeConversationMemory({
    userId: user.id,
    queryText: lastUserMessage?.content || "",
    replyText: reply,
    providerName: provider.name,
    modelName: provider.modelName
  }).catch((error) => {
    console.warn("Conversation memory write skipped:", error.message);
  });

  return {
    reply,
    provider: provider.name,
    model: provider.modelName,
    usage: null
  };
}

function buildSystemInstruction(memoryMatches) {
  const now = new Date();
  const today = now.toISOString().slice(0, 10);
  const currentMonth = today.slice(0, 7);
  const memoryBlock = memoryMatches.length
    ? memoryMatches
        .map((item, index) => `Memory ${index + 1}:\n${item.content}`)
        .join("\n\n")
    : "No relevant long-term memory was found.";

  return [
    "You are an AI-powered personal finance assistant.",
    "The finance tool layer is exposed through MCP-backed tools. Always use tools for real data access or write operations.",
    "Use semantic_finance_search for fuzzy matching, past notes, or concept-based retrieval.",
    "Use financial_insights for questions about overspending, unusual expenses, trends, or month-over-month comparisons.",
    "Keep answers concise, practical, and grounded in tool results.",
    `Today's date is ${today}. The current month is ${currentMonth}.`,
    "When the user uses relative dates, resolve them against today's date.",
    "Use YYYY-MM for month filters and ISO dates for exact dates when calling tools.",
    `Relevant long-term memory:\n${memoryBlock}`
  ].join("\n");
}

function toLangChainMessages(history) {
  return history.map((message) =>
    message.role === "assistant"
      ? new AIMessage(message.content)
      : new HumanMessage(message.content)
  );
}

function extractAgentReply(messages) {
  const lastAiMessage = [...messages]
    .reverse()
    .find((message) => message instanceof AIMessage || message.getType?.() === "ai");

  if (!lastAiMessage) {
    throw new Error("The agent returned no assistant reply.");
  }

  if (typeof lastAiMessage.content === "string") {
    return lastAiMessage.content;
  }

  if (Array.isArray(lastAiMessage.content)) {
    return lastAiMessage.content
      .filter((part) => typeof part?.text === "string")
      .map((part) => part.text)
      .join("")
      .trim();
  }

  return String(lastAiMessage.content ?? "").trim();
}

function validateChatHistory(history) {
  if (!Array.isArray(history) || history.length === 0) {
    throw new Error("messages must be a non-empty array");
  }

  for (const message of history) {
    if (!["user", "assistant"].includes(message.role)) {
      throw new Error("message role must be either user or assistant");
    }

    if (typeof message.content !== "string") {
      throw new Error("message content must be a string");
    }
  }
}
