import { Server } from "@modelcontextprotocol/sdk/server/index.js";
import {
  CallToolRequestSchema,
  ListToolsRequestSchema
} from "@modelcontextprotocol/sdk/types.js";
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
} from "../services/finance-service.js";

export function createExpenseManagerServer() {
  const server = new Server(
    {
      name: "personal-finance-mcp",
      version: "2.0.0"
    },
    {
      capabilities: {
        tools: {}
      }
    }
  );

  server.setRequestHandler(ListToolsRequestSchema, async () => ({
    tools: [
      {
        name: "finance_dashboard",
        description: "Get finance dashboard data including expenses, incomes, budgets, and categories for a month.",
        inputSchema: {
          type: "object",
          required: ["month"],
          properties: {
            month: { type: "string", description: "Month in YYYY-MM format." }
          }
        }
      },
      {
        name: "period_summary",
        description: "Get totals for income, expenses, and balance for a month.",
        inputSchema: {
          type: "object",
          required: ["month"],
          properties: {
            month: { type: "string", description: "Month in YYYY-MM format." }
          }
        }
      },
      {
        name: "list_categories",
        description: "List finance categories, optionally filtered by kind.",
        inputSchema: {
          type: "object",
          properties: {
            kind: { type: "string", description: "expense, income, or both" }
          }
        }
      },
      {
        name: "create_category",
        description: "Create a category for expenses, incomes, or both.",
        inputSchema: {
          type: "object",
          required: ["name"],
          properties: {
            name: { type: "string" },
            kind: { type: "string" },
            color: { type: "string" },
            icon: { type: "string" }
          }
        }
      },
      {
        name: "list_expenses",
        description: "List expense records with optional filters.",
        inputSchema: {
          type: "object",
          properties: {
            categoryId: { type: "number" },
            from: { type: "string" },
            to: { type: "string" },
            limit: { type: "number" }
          }
        }
      },
      {
        name: "create_expense",
        description: "Create a new expense record.",
        inputSchema: {
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
      },
      {
        name: "list_incomes",
        description: "List income records with optional filters.",
        inputSchema: {
          type: "object",
          properties: {
            categoryId: { type: "number" },
            from: { type: "string" },
            to: { type: "string" },
            limit: { type: "number" }
          }
        }
      },
      {
        name: "create_income",
        description: "Create a new income record.",
        inputSchema: {
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
      },
      {
        name: "list_budgets",
        description: "List budgets for daily, weekly, monthly, or yearly periods.",
        inputSchema: {
          type: "object",
          properties: {
            period: { type: "string" },
            categoryId: { type: "number" }
          }
        }
      },
      {
        name: "create_budget",
        description: "Create a budget for a period and optional category.",
        inputSchema: {
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
    ]
  }));

  server.setRequestHandler(CallToolRequestSchema, async (request) => {
    const { name, arguments: args = {} } = request.params;

    if (name === "finance_dashboard") {
      return jsonText(await getFinanceDashboard(args.month));
    }

    if (name === "period_summary") {
      return jsonText(await getPeriodSummary(args.month));
    }

    if (name === "list_categories") {
      return jsonText(await listCategories(args));
    }

    if (name === "create_category") {
      return jsonText(await createCategory(args));
    }

    if (name === "list_expenses") {
      return jsonText(await listExpenses(args));
    }

    if (name === "create_expense") {
      return jsonText(await createExpense(args));
    }

    if (name === "list_incomes") {
      return jsonText(await listIncomes(args));
    }

    if (name === "create_income") {
      return jsonText(await createIncome(args));
    }

    if (name === "list_budgets") {
      return jsonText(await listBudgets(args));
    }

    if (name === "create_budget") {
      return jsonText(await createBudget(args));
    }

    throw new Error(`Unknown tool: ${name}`);
  });

  return server;
}

function jsonText(value) {
  return {
    content: [
      {
        type: "text",
        text: JSON.stringify(value, null, 2)
      }
    ]
  };
}
