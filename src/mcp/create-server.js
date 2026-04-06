import { Server } from "@modelcontextprotocol/sdk/server/index.js";
import {
  CallToolRequestSchema,
  ListToolsRequestSchema
} from "@modelcontextprotocol/sdk/types.js";
import {
  createBudget,
  createCategory,
  createAccount,
  createExpense,
  createIncome,
  deleteBudget,
  deleteCategory,
  deleteAccount,
  deleteIncome,
  deleteExpense,
  getAccountSummary,
  getChartData,
  getDailyExpensesSummary,
  getFinanceDashboard,
  getMonthlyExpensesSummary,
  getPeriodSummary,
  getWeeklyExpensesSummary,
  listAccounts,
  listBudgets,
  listCategories,
  listExpenses,
  listIncomes,
  listTransfers,
  transferBetweenAccounts,
  updateBudget,
  updateCategory,
  updateAccount,
  updateExpense,
  updateIncome
} from "../services/finance-service.js";

export function createExpenseManagerServer({ user }) {
  const userId = user.id;
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
        name: "update_category",
        description: "Update an existing category.",
        inputSchema: {
          type: "object",
          required: ["id", "name", "kind", "color", "icon"],
          properties: {
            id: { type: "number" },
            name: { type: "string" },
            kind: { type: "string" },
            color: { type: "string" },
            icon: { type: "string" }
          }
        }
      },
      {
        name: "delete_category",
        description: "Delete a category.",
        inputSchema: {
          type: "object",
          required: ["id"],
          properties: {
            id: { type: "number" }
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
            accountId: { type: "number" },
            from: { type: "string" },
            to: { type: "string" },
            limit: { type: "number" }
          }
        }
      },
      {
        name: "daily_expenses",
        description: "Get daily expenses summary for the last N days.",
        inputSchema: {
          type: "object",
          properties: {
            days: { type: "number", description: "Number of days (1-30, default 7)" }
          }
        }
      },
      {
        name: "weekly_expenses",
        description: "Get weekly expenses summary for the last N weeks.",
        inputSchema: {
          type: "object",
          properties: {
            weeks: { type: "number", description: "Number of weeks (1-12, default 4)" }
          }
        }
      },
      {
        name: "monthly_expenses",
        description: "Get monthly expenses summary for the last N months.",
        inputSchema: {
          type: "object",
          properties: {
            months: { type: "number", description: "Number of months (1-12, default 6)" }
          }
        }
      },
      {
        name: "create_expense",
        description: "Create a new expense record.",
        inputSchema: {
          type: "object",
          required: ["title", "amount", "categoryId", "accountId", "spentOn"],
          properties: {
            title: { type: "string" },
            amount: { type: "number" },
            categoryId: { type: "number" },
            accountId: { type: "number" },
            spentOn: { type: "string" },
            notes: { type: "string" }
          }
        }
      },
      {
        name: "update_expense",
        description: "Update an existing expense record.",
        inputSchema: {
          type: "object",
          required: ["id", "title", "amount", "categoryId", "accountId", "spentOn"],
          properties: {
            id: { type: "number" },
            title: { type: "string" },
            amount: { type: "number" },
            categoryId: { type: "number" },
            accountId: { type: "number" },
            spentOn: { type: "string" },
            notes: { type: "string" }
          }
        }
      },
      {
        name: "delete_expense",
        description: "Delete an expense record.",
        inputSchema: {
          type: "object",
          required: ["id"],
          properties: {
            id: { type: "number" }
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
            accountId: { type: "number" },
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
          required: ["title", "amount", "categoryId", "accountId", "receivedOn"],
          properties: {
            title: { type: "string" },
            amount: { type: "number" },
            categoryId: { type: "number" },
            accountId: { type: "number" },
            receivedOn: { type: "string" },
            notes: { type: "string" }
          }
        }
      },
      {
        name: "update_income",
        description: "Update an existing income record.",
        inputSchema: {
          type: "object",
          required: ["id", "title", "amount", "categoryId", "accountId", "receivedOn"],
          properties: {
            id: { type: "number" },
            title: { type: "string" },
            amount: { type: "number" },
            categoryId: { type: "number" },
            accountId: { type: "number" },
            receivedOn: { type: "string" },
            notes: { type: "string" }
          }
        }
      },
      {
        name: "delete_income",
        description: "Delete an income record.",
        inputSchema: {
          type: "object",
          required: ["id"],
          properties: {
            id: { type: "number" }
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
      },
      {
        name: "update_budget",
        description: "Update an existing budget.",
        inputSchema: {
          type: "object",
          required: ["id", "name", "amount", "period", "startDate"],
          properties: {
            id: { type: "number" },
            name: { type: "string" },
            amount: { type: "number" },
            period: { type: "string" },
            startDate: { type: "string" },
            categoryId: { type: "number" },
            notes: { type: "string" }
          }
        }
      },
      {
        name: "delete_budget",
        description: "Delete a budget.",
        inputSchema: {
          type: "object",
          required: ["id"],
          properties: {
            id: { type: "number" }
          }
        }
      },
      {
        name: "list_accounts",
        description: "List accounts with optional filters.",
        inputSchema: {
          type: "object",
          properties: {
            type: { type: "string", description: "cash, bank, credit_card, or investments" },
            isActive: { type: "boolean" }
          }
        }
      },
      {
        name: "create_account",
        description: "Create a new account.",
        inputSchema: {
          type: "object",
          required: ["name"],
          properties: {
            name: { type: "string" },
            type: { type: "string" },
            initialBalance: { type: "number" },
            color: { type: "string" },
            icon: { type: "string" },
            notes: { type: "string" }
          }
        }
      },
      {
        name: "update_account",
        description: "Update an existing account.",
        inputSchema: {
          type: "object",
          required: ["id"],
          properties: {
            id: { type: "number" },
            name: { type: "string" },
            type: { type: "string" },
            color: { type: "string" },
            icon: { type: "string" },
            notes: { type: "string" },
            isActive: { type: "boolean" }
          }
        }
      },
      {
        name: "delete_account",
        description: "Delete an account. If account has transactions, it will be deactivated instead.",
        inputSchema: {
          type: "object",
          required: ["id"],
          properties: {
            id: { type: "number" }
          }
        }
      },
      {
        name: "account_summary",
        description: "Get summary for an account including total income, expenses, and balance.",
        inputSchema: {
          type: "object",
          required: ["id"],
          properties: {
            id: { type: "number" }
          }
        }
      },
      {
        name: "transfer_between_accounts",
        description: "Transfer money between two accounts.",
        inputSchema: {
          type: "object",
          required: ["fromAccountId", "toAccountId", "amount"],
          properties: {
            fromAccountId: { type: "number" },
            toAccountId: { type: "number" },
            amount: { type: "number" },
            notes: { type: "string" }
          }
        }
      },
      {
        name: "list_transfers",
        description: "List transfer records with optional filters.",
        inputSchema: {
          type: "object",
          properties: {
            accountId: { type: "number" },
            from: { type: "string" },
            to: { type: "string" },
            limit: { type: "number" }
          }
        }
      },
      {
        name: "get_chart_data",
        description: "Get chart data for visualization. Returns data for bar, line, or pie charts.",
        inputSchema: {
          type: "object",
          properties: {
            type: { 
              type: "string", 
              description: "Chart type: bar, line, or pie" 
            },
            period: { 
              type: "string", 
              description: "Time period: today, daily, weekly, monthly, category" 
            },
            accountId: { type: "number" }
          }
        }
      }
    ]
  }));

  server.setRequestHandler(CallToolRequestSchema, async (request) => {
    const { name, arguments: args = {} } = request.params;

    if (name === "finance_dashboard") {
      return jsonText(await getFinanceDashboard(userId, args.month));
    }

    if (name === "period_summary") {
      return jsonText(await getPeriodSummary(userId, args.month));
    }

    if (name === "list_categories") {
      return jsonText(await listCategories(userId, args));
    }

    if (name === "create_category") {
      return jsonText(await createCategory(userId, args));
    }

    if (name === "update_category") {
      return jsonText(await updateCategory(userId, args.id, args));
    }

    if (name === "delete_category") {
      return jsonText({ deleted: await deleteCategory(userId, args.id) });
    }

    if (name === "list_expenses") {
      return jsonText(await listExpenses(userId, args));
    }

    if (name === "daily_expenses") {
      return jsonText(await getDailyExpensesSummary(userId, args.days || 7));
    }

    if (name === "weekly_expenses") {
      return jsonText(await getWeeklyExpensesSummary(userId, args.weeks || 4));
    }

    if (name === "monthly_expenses") {
      return jsonText(await getMonthlyExpensesSummary(userId, args.months || 6));
    }

    if (name === "create_expense") {
      return jsonText(await createExpense(userId, args));
    }

    if (name === "update_expense") {
      return jsonText(await updateExpense(userId, args.id, args));
    }

    if (name === "delete_expense") {
      return jsonText({ deleted: await deleteExpense(userId, args.id) });
    }

    if (name === "list_incomes") {
      return jsonText(await listIncomes(userId, args));
    }

    if (name === "create_income") {
      return jsonText(await createIncome(userId, args));
    }

    if (name === "update_income") {
      return jsonText(await updateIncome(userId, args.id, args));
    }

    if (name === "delete_income") {
      return jsonText({ deleted: await deleteIncome(userId, args.id) });
    }

    if (name === "list_budgets") {
      return jsonText(await listBudgets(userId, args));
    }

    if (name === "create_budget") {
      return jsonText(await createBudget(userId, args));
    }

    if (name === "update_budget") {
      return jsonText(await updateBudget(userId, args.id, args));
    }

    if (name === "delete_budget") {
      return jsonText({ deleted: await deleteBudget(userId, args.id) });
    }

    if (name === "list_accounts") {
      return jsonText(await listAccounts(userId, args));
    }

    if (name === "create_account") {
      return jsonText(await createAccount(userId, args));
    }

    if (name === "update_account") {
      return jsonText(await updateAccount(userId, args.id, args));
    }

    if (name === "delete_account") {
      const result = await deleteAccount(userId, args.id);
      return jsonText({ result });
    }

    if (name === "account_summary") {
      return jsonText(await getAccountSummary(userId, args.id));
    }

    if (name === "transfer_between_accounts") {
      return jsonText(await transferBetweenAccounts(userId, args));
    }

    if (name === "list_transfers") {
      return jsonText(await listTransfers(userId, args));
    }

    if (name === "get_chart_data") {
      return jsonText(await getChartData(userId, args));
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
