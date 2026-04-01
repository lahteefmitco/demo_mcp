import {
  createBudget,
  createCategory,
  createExpense,
  createIncome,
  getFinanceDashboard,
  getPeriodSummary,
  listBudgets,
  listCategories,
  listExpenses,
  listIncomes
} from "./finance-service.js";

const openRouterApiKey = process.env.OPENROUTER_API_KEY;
const openRouterModel = process.env.OPENROUTER_MODEL || "stepfun/step-3.5-flash:free";

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

export async function runExpenseChat(history) {
  if (!openRouterApiKey) {
    throw new Error("OPENROUTER_API_KEY is required to use chat.");
  }

  let messages = normalizeChatHistory(history);

  for (let attempt = 0; attempt < 6; attempt += 1) {
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
              "You are a helpful personal finance assistant. You help the user manage categories, expenses, incomes, and budgets for daily, weekly, monthly, and yearly periods. Keep answers concise and practical. Use tools whenever real data or write actions are needed."
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
  if (name === "finance_dashboard") {
    return getFinanceDashboard(input.month);
  }

  if (name === "period_summary") {
    return getPeriodSummary(input.month);
  }

  if (name === "list_categories") {
    return listCategories(input);
  }

  if (name === "create_category") {
    return createCategory(input);
  }

  if (name === "list_expenses") {
    return listExpenses(input);
  }

  if (name === "create_expense") {
    return createExpense(input);
  }

  if (name === "list_incomes") {
    return listIncomes(input);
  }

  if (name === "create_income") {
    return createIncome(input);
  }

  if (name === "list_budgets") {
    return listBudgets(input);
  }

  if (name === "create_budget") {
    return createBudget(input);
  }

  throw new Error(`Unknown tool: ${name}`);
}
