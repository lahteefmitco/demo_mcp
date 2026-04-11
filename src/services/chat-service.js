import { normalizeProviderName } from "../ai/config.js";
import { runFinanceAgent } from "../ai/agent/finance-agent.js";

export async function runExpenseChat(history, provider = "gemini", user) {
  const providerName = normalizeProviderName(provider);

  if (providerName === "generic") {
    throw new Error("provider must be one of gemini, mistral, or openrouter for chat.");
  }

  return runFinanceAgent({
    history,
    providerName,
    user
  });
}
