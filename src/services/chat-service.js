import {
  createExpense,
  getMobileBootstrap,
  getMonthlySummary,
  listCategories,
  listExpenses
} from "./expense-service.js";

const openRouterApiKey = process.env.OPENROUTER_API_KEY;
const openRouterModel = process.env.OPENROUTER_MODEL || "stepfun/step-3.5-flash:free";

const toolDefinitions = [
  {
    type: "function",
    function: {
      name: "list_expenses",
      description: "List expense records. Use filters when the user asks for category, date range, or recent expenses.",
      parameters: {
        type: "object",
        properties: {
          category: { type: "string", description: "Optional category filter." },
          from: { type: "string", description: "Optional start date in YYYY-MM-DD format." },
          to: { type: "string", description: "Optional end date in YYYY-MM-DD format." },
          limit: { type: "number", description: "Optional maximum number of results." }
        }
      }
    }
  },
  {
    type: "function",
    function: {
      name: "create_expense",
      description: "Create a new expense from the provided details.",
      parameters: {
        type: "object",
        required: ["title", "amount", "category", "spentOn"],
        properties: {
          title: { type: "string" },
          amount: { type: "number" },
          category: { type: "string" },
          spentOn: { type: "string", description: "Date in YYYY-MM-DD format." },
          notes: { type: "string" }
        }
      }
    }
  },
  {
    type: "function",
    function: {
      name: "monthly_summary",
      description: "Get a monthly expense summary grouped by category.",
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
      description: "List the currently used expense categories.",
      parameters: {
        type: "object",
        properties: {}
      }
    }
  },
  {
    type: "function",
    function: {
      name: "dashboard_snapshot",
      description: "Get dashboard data for a month including summary, categories, and recent expenses.",
      parameters: {
        type: "object",
        required: ["month"],
        properties: {
          month: { type: "string", description: "Month in YYYY-MM format." }
        }
      }
    }
  }
];

export async function runExpenseChat(history) {
  if (!openRouterApiKey) {
    throw new Error("OPENROUTER_API_KEY is required to use chat.");
  }

  let messages = normalizeChatHistory(history);

  for (let attempt = 0; attempt < 5; attempt += 1) {
    const response = await fetch("https://openrouter.ai/api/v1/chat/completions", {
      method: "POST",
      headers: {
        Authorization: `Bearer ${openRouterApiKey}`,
        "Content-Type": "application/json"
      },
      body: JSON.stringify({
        model: openRouterModel,
        messages: [
          {
            role: "system",
            content:
              "You are a helpful personal expense assistant. Answer clearly and briefly. Use tools whenever you need current expense data or when the user asks you to create an expense."
          },
          ...messages
        ],
        tools: toolDefinitions,
        tool_choice: "auto",
        temperature: 0.2
      })
    });

    if (!response.ok) {
      const errorText = await response.text();
      throw new Error(`OpenRouter API error ${response.status}: ${errorText}`);
    }

    const data = await response.json();
    const choice = data.choices?.[0];
    const assistantMessage = choice?.message;

    if (!assistantMessage) {
      throw new Error("OpenRouter returned no assistant message.");
    }

    messages = [
      ...messages,
      {
        role: "assistant",
        content: assistantMessage.content || "",
        tool_calls: assistantMessage.tool_calls
      }
    ];

    const toolCalls = assistantMessage.tool_calls || [];
    if (!toolCalls.length) {
      return {
        reply: assistantMessage.content || "",
        model: data.model ?? openRouterModel,
        usage: data.usage ?? null
      };
    }

    for (const toolCall of toolCalls) {
      let parsedArguments = {};

      try {
        parsedArguments = JSON.parse(toolCall.function.arguments || "{}");
      } catch {
        parsedArguments = {};
      }

      try {
        const result = await executeTool(toolCall.function.name, parsedArguments);
        messages = [
          ...messages,
          {
            role: "tool",
            tool_call_id: toolCall.id,
            content: JSON.stringify(result)
          }
        ];
      } catch (error) {
        messages = [
          ...messages,
          {
            role: "tool",
            tool_call_id: toolCall.id,
            content: JSON.stringify({ error: error.message })
          }
        ];
      }
    }
  }

  throw new Error("The OpenRouter tool loop did not finish in time.");
}

function normalizeChatHistory(history) {
  if (!Array.isArray(history) || history.length === 0) {
    throw new Error("messages must be a non-empty array");
  }

  return history.map((message) => {
    if (!["user", "assistant"].includes(message.role)) {
      throw new Error("message role must be either user or assistant");
    }

    if (typeof message.content !== "string") {
      throw new Error("message content must be a string");
    }

    return {
      role: message.role,
      content: message.content
    };
  });
}

async function executeTool(name, input) {
  if (name === "list_expenses") {
    return listExpenses(input);
  }

  if (name === "create_expense") {
    return createExpense({
      title: input.title,
      amount: input.amount,
      category: input.category,
      spentOn: input.spentOn,
      notes: input.notes ?? ""
    });
  }

  if (name === "monthly_summary") {
    return getMonthlySummary(input.month);
  }

  if (name === "list_categories") {
    return listCategories();
  }

  if (name === "dashboard_snapshot") {
    return getMobileBootstrap(input.month);
  }

  throw new Error(`Unknown tool: ${name}`);
}
