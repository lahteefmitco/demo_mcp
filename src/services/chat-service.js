import {
  createBudget,
  createCategory,
  createExpense,
  createIncome,
  deleteExpense,
  getFinanceDashboard,
  getPeriodSummary,
  listBudgets,
  listCategories,
  listExpenses,
  listIncomes,
  updateExpense
} from "./finance-service.js";
import { formatProjectDate } from "../utils/date-utils.js";

const geminiApiKey = process.env.GEMINI_API_KEY;
const geminiModel = process.env.GEMINI_MODEL || "gemini-2.5-flash";
const geminiApiBaseUrl = "https://generativelanguage.googleapis.com/v1beta";
const mistralApiKey = process.env.MISTRAL_API_KEY;
const mistralModel = process.env.MISTRAL_MODEL || "mistral-small-latest";
const mistralApiBaseUrl = "https://api.mistral.ai/v1";
const openRouterApiKey = process.env.OPENROUTER_API_KEY;
const openRouterModel = process.env.OPENROUTER_MODEL || "openai/gpt-4o-mini";
const openRouterApiBaseUrl = "https://openrouter.ai/api/v1";

const toolDefinitions = [
  {
    type: "function",
    function: {
      name: "finance_dashboard",
      description: "Get finance dashboard data including expenses, incomes, budgets, and categories for a month.",
      parameters: {
        type: "object",
        required: ["month"],
        properties: {
          month: { type: "string", description: "Month in YYYY-MM format." }
        }
      }
    }
  },
  {
    type: "function",
    function: {
      name: "period_summary",
      description: "Get monthly totals for expenses, incomes, and balance.",
      parameters: {
        type: "object",
        required: ["month"],
        properties: {
          month: { type: "string", description: "Month in YYYY-MM format." }
        }
      }
    }
  },
  {
    type: "function",
    function: {
      name: "list_categories",
      description: "List categories, optionally filtered by expense or income kind.",
      parameters: {
        type: "object",
        properties: {
          kind: { type: "string", description: "expense, income, or both" }
        }
      }
    }
  },
  {
    type: "function",
    function: {
      name: "create_category",
      description: "Create a category.",
      parameters: {
        type: "object",
        required: ["name"],
        properties: {
          name: { type: "string" },
          kind: { type: "string" },
          color: { type: "string" },
          icon: { type: "string" }
        }
      }
    }
  },
  {
    type: "function",
    function: {
      name: "list_expenses",
      description: "List expenses with optional filters.",
      parameters: {
        type: "object",
        properties: {
          categoryId: { type: "number" },
          from: { type: "string" },
          to: { type: "string" },
          limit: { type: "number" }
        }
      }
    }
  },
  {
    type: "function",
    function: {
      name: "create_expense",
      description: "Create a new expense.",
      parameters: {
        type: "object",
        required: ["title", "amount", "categoryId", "spentOn"],
        properties: {
          title: { type: "string" },
          amount: { type: "number" },
          categoryId: { type: "number" },
          spentOn: { type: "string" },
          notes: { type: "string" }
        }
      }
    }
  },
  {
    type: "function",
    function: {
      name: "update_expense",
      description: "Update an existing expense.",
      parameters: {
        type: "object",
        required: ["id", "title", "amount", "categoryId", "spentOn"],
        properties: {
          id: { type: "number" },
          title: { type: "string" },
          amount: { type: "number" },
          categoryId: { type: "number" },
          spentOn: { type: "string" },
          notes: { type: "string" }
        }
      }
    }
  },
  {
    type: "function",
    function: {
      name: "delete_expense",
      description: "Delete an expense.",
      parameters: {
        type: "object",
        required: ["id"],
        properties: {
          id: { type: "number" }
        }
      }
    }
  },
  {
    type: "function",
    function: {
      name: "list_incomes",
      description: "List incomes with optional filters.",
      parameters: {
        type: "object",
        properties: {
          categoryId: { type: "number" },
          from: { type: "string" },
          to: { type: "string" },
          limit: { type: "number" }
        }
      }
    }
  },
  {
    type: "function",
    function: {
      name: "create_income",
      description: "Create a new income record.",
      parameters: {
        type: "object",
        required: ["title", "amount", "categoryId", "receivedOn"],
        properties: {
          title: { type: "string" },
          amount: { type: "number" },
          categoryId: { type: "number" },
          receivedOn: { type: "string" },
          notes: { type: "string" }
        }
      }
    }
  },
  {
    type: "function",
    function: {
      name: "update_income",
      description: "Update an existing income.",
      parameters: {
        type: "object",
        required: ["id", "title", "amount", "categoryId", "receivedOn"],
        properties: {
          id: { type: "number" },
          title: { type: "string" },
          amount: { type: "number" },
          categoryId: { type: "number" },
          receivedOn: { type: "string" },
          notes: { type: "string" }
        }
      }
    }
  },
  {
    type: "function",
    function: {
      name: "delete_income",
      description: "Delete an income.",
      parameters: {
        type: "object",
        required: ["id"],
        properties: {
          id: { type: "number" }
        }
      }
    }
  },
  {
    type: "function",
    function: {
      name: "list_budgets",
      description: "List budgets for daily, weekly, monthly, or yearly periods.",
      parameters: {
        type: "object",
        properties: {
          period: { type: "string" },
          categoryId: { type: "number" }
        }
      }
    }
  },
  {
    type: "function",
    function: {
      name: "create_budget",
      description: "Create a budget for a time period and optional category.",
      parameters: {
        type: "object",
        required: ["name", "amount", "period", "startDate"],
        properties: {
          name: { type: "string" },
          amount: { type: "number" },
          period: { type: "string" },
          startDate: { type: "string" },
          categoryId: { type: "number" },
          notes: { type: "string" }
        }
      }
    }
  }
];

export async function runExpenseChat(history, provider = "gemini", user) {
  const normalizedProvider = normalizeProvider(provider);

  if (normalizedProvider === "gemini") {
    return runGeminiChat(history, user);
  }

  if (normalizedProvider === "mistral") {
    if (!mistralApiKey) {
      throw new Error("MISTRAL_API_KEY is required to use Mistral chat.");
    }

    return runOpenAiCompatibleChat(history, user, {
      provider: "mistral",
      apiKey: mistralApiKey,
      model: mistralModel,
      apiBaseUrl: mistralApiBaseUrl
    });
  }

  if (!openRouterApiKey) {
    throw new Error("OPENROUTER_API_KEY is required to use OpenRouter chat.");
  }

  return runOpenAiCompatibleChat(history, user, {
    provider: "openrouter",
    apiKey: openRouterApiKey,
    model: openRouterModel,
    apiBaseUrl: openRouterApiBaseUrl,
    extraHeaders: {
      "HTTP-Referer": process.env.OPENROUTER_HTTP_REFERER || "http://localhost:3000",
      "X-Title": process.env.OPENROUTER_APP_TITLE || "Personal Finance Mobile"
    }
  });
}

async function runGeminiChat(history, user) {
  if (!geminiApiKey) {
    throw new Error("GEMINI_API_KEY is required to use Gemini chat.");
  }

  let contents = normalizeGeminiChatHistory(history);
  const systemInstruction = buildSystemInstruction();

  for (let attempt = 0; attempt < 6; attempt += 1) {
    const response = await fetch(`${geminiApiBaseUrl}/models/${geminiModel}:generateContent`, {
      method: "POST",
      headers: {
        "x-goog-api-key": geminiApiKey,
        "Content-Type": "application/json"
      },
      body: JSON.stringify({
        system_instruction: {
          parts: [{ text: systemInstruction }]
        },
        contents,
        tools: [
          {
            functionDeclarations: toolDefinitions.map((tool) => tool.function)
          }
        ],
        toolConfig: {
          functionCallingConfig: {
            mode: "AUTO"
          }
        },
        generationConfig: {
          temperature: 0.2
        }
      })
    });

    if (!response.ok) {
      const errorText = await response.text();
      throw new Error(`Gemini API error ${response.status}: ${errorText}`);
    }

    const data = await response.json();
    const assistantMessage = data.candidates?.[0]?.content;

    if (!assistantMessage) {
      throw new Error("Gemini returned no assistant message.");
    }

    contents = [...contents, assistantMessage];

    const toolCalls = extractGeminiFunctionCalls(assistantMessage);
    if (!toolCalls.length) {
      return {
        reply: extractGeminiText(assistantMessage),
        provider: "gemini",
        model: data.modelVersion ?? geminiModel,
        usage: data.usageMetadata ?? null
      };
    }

    for (const toolCall of toolCalls) {
      const parsedArguments = toolCall.args ?? {};

      try {
        const result = await executeTool(user, toolCall.name, parsedArguments);
        contents = [
          ...contents,
          {
            role: "user",
            parts: [
              {
                functionResponse: {
                  id: toolCall.id,
                  name: toolCall.name,
                  response: normalizeFunctionResponse(result)
                }
              }
            ]
          }
        ];
      } catch (error) {
        contents = [
          ...contents,
          {
            role: "user",
            parts: [
              {
                functionResponse: {
                  id: toolCall.id,
                  name: toolCall.name,
                  response: { error: error.message }
                }
              }
            ]
          }
        ];
      }
    }
  }

  throw new Error("The Gemini tool loop did not finish in time.");
}

async function runOpenAiCompatibleChat(
  history,
  user,
  { provider, apiKey, model, apiBaseUrl, extraHeaders = {} }
) {
  const messages = [
    { role: "system", content: buildSystemInstruction() },
    ...normalizeOpenAiChatHistory(history)
  ];

  for (let attempt = 0; attempt < 6; attempt += 1) {
    const response = await fetch(`${apiBaseUrl}/chat/completions`, {
      method: "POST",
      headers: {
        Authorization: `Bearer ${apiKey}`,
        "Content-Type": "application/json",
        ...extraHeaders
      },
      body: JSON.stringify({
        model,
        messages,
        tools: toolDefinitions,
        tool_choice: "auto",
        temperature: 0.2
      })
    });

    if (!response.ok) {
      const errorText = await response.text();
      throw new Error(`${provider} API error ${response.status}: ${errorText}`);
    }

    const data = await response.json();
    const assistantMessage = data.choices?.[0]?.message;

    if (!assistantMessage) {
      throw new Error(`${provider} returned no assistant message.`);
    }

    messages.push(assistantMessage);

    if (!assistantMessage.tool_calls?.length) {
      return {
        reply: extractOpenAiText(assistantMessage),
        provider,
        model: data.model ?? model,
        usage: data.usage ?? null
      };
    }

    for (const toolCall of assistantMessage.tool_calls) {
      let toolResponse;

      try {
        const parsedArguments = JSON.parse(toolCall.function.arguments || "{}");
        const result = await executeTool(user, toolCall.function.name, parsedArguments);
        toolResponse = normalizeFunctionResponse(result);
      } catch (error) {
        toolResponse = { error: error.message };
      }

      messages.push({
        role: "tool",
        tool_call_id: toolCall.id,
        content: JSON.stringify(toolResponse)
      });
    }
  }

  throw new Error(`The ${provider} tool loop did not finish in time.`);
}

function normalizeGeminiChatHistory(history) {
  validateChatHistory(history);

  return history.map((message) => ({
    role: message.role === "assistant" ? "model" : "user",
    parts: [{ text: message.content }]
  }));
}

function normalizeOpenAiChatHistory(history) {
  validateChatHistory(history);

  return history.map((message) => ({
    role: message.role,
    content: message.content
  }));
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

function extractGeminiFunctionCalls(message) {
  return (message.parts || [])
    .map((part) => part.functionCall)
    .filter(Boolean);
}

function extractGeminiText(message) {
  return (message.parts || [])
    .filter((part) => typeof part.text === "string")
    .map((part) => part.text)
    .join("")
    .trim();
}

function extractOpenAiText(message) {
  if (typeof message.content === "string") {
    return message.content.trim();
  }

  if (Array.isArray(message.content)) {
    return message.content
      .filter((part) => typeof part?.text === "string")
      .map((part) => part.text)
      .join("")
      .trim();
  }

  return "";
}

function buildSystemInstruction() {
  const now = new Date();
  const today = formatProjectDate(now);
  const currentMonth = `${String(now.getUTCMonth() + 1).padStart(2, "0")}-${now.getUTCFullYear()}`;

  return [
    "You are a helpful personal finance assistant.",
    "You help the user manage categories, expenses, incomes, and budgets for daily, weekly, monthly, and yearly periods.",
    "Keep answers concise and practical. Use tools whenever real data or write actions are needed.",
    `Today's date is ${today}. The current month is ${currentMonth}.`,
    "When the user says relative dates like today, yesterday, tomorrow, this week, or this month, resolve them automatically using today's date.",
    "Use dd-MM-yyyy for all full dates in conversation and tool arguments.",
    "For month-only filters in finance_dashboard and period_summary, convert the month internally to YYYY-MM."
  ].join(" ");
}

function normalizeFunctionResponse(value) {
  if (value !== null && typeof value === "object" && !Array.isArray(value)) {
    return value;
  }

  return { result: value };
}

function normalizeProvider(provider) {
  if (typeof provider !== "string" || !provider.trim()) {
    return "gemini";
  }

  const normalized = provider.trim().toLowerCase();
  if (["gemini", "mistral", "openrouter"].includes(normalized)) {
    return normalized;
  }

  throw new Error("provider must be one of gemini, mistral, or openrouter");
}

async function executeTool(user, name, input) {
  const userId = user.id;

  if (name === "finance_dashboard") {
    return getFinanceDashboard(userId, input.month);
  }

  if (name === "period_summary") {
    return getPeriodSummary(userId, input.month);
  }

  if (name === "list_categories") {
    return listCategories(userId, input);
  }

  if (name === "create_category") {
    return createCategory(userId, input);
  }

  if (name === "list_expenses") {
    return listExpenses(userId, input);
  }

  if (name === "create_expense") {
    return createExpense(userId, input);
  }

  if (name === "update_expense") {
    return updateExpense(userId, input.id, input);
  }

  if (name === "delete_expense") {
    return { deleted: await deleteExpense(userId, input.id) };
  }

  if (name === "list_incomes") {
    return listIncomes(userId, input);
  }

  if (name === "create_income") {
    return createIncome(userId, input);
  }

  if (name === "list_budgets") {
    return listBudgets(userId, input);
  }

  if (name === "create_budget") {
    return createBudget(userId, input);
  }

  throw new Error(`Unknown tool: ${name}`);
}
