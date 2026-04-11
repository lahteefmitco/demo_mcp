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
import {
  deleteFinanceDocument,
  syncFinanceDocument
} from "../ai/vector/finance-document-sync.js";

export const financeMcpTools = [
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
];

export function getFinanceMcpToolDefinitions() {
  return financeMcpTools.map((tool) => ({
    name: tool.name,
    description: tool.description,
    inputSchema: structuredClone(tool.inputSchema)
  }));
}

export async function executeFinanceMcpTool({ userId, name, args = {} }) {
  let result;

  if (name === "finance_dashboard") {
    result = await getFinanceDashboard(userId, args.month);
  } else if (name === "period_summary") {
    result = await getPeriodSummary(userId, args.month);
  } else if (name === "list_categories") {
    result = await listCategories(userId, args);
  } else if (name === "create_category") {
    result = await createCategory(userId, args);
  } else if (name === "update_category") {
    result = await updateCategory(userId, args.id, args);
  } else if (name === "delete_category") {
    result = { deleted: await deleteCategory(userId, args.id) };
  } else if (name === "list_expenses") {
    result = await listExpenses(userId, args);
  } else if (name === "daily_expenses") {
    result = await getDailyExpensesSummary(userId, args.days || 7);
  } else if (name === "weekly_expenses") {
    result = await getWeeklyExpensesSummary(userId, args.weeks || 4);
  } else if (name === "monthly_expenses") {
    result = await getMonthlyExpensesSummary(userId, args.months || 6);
  } else if (name === "create_expense") {
    result = await createExpense(userId, args);
  } else if (name === "update_expense") {
    result = await updateExpense(userId, args.id, args);
  } else if (name === "delete_expense") {
    result = { deleted: await deleteExpense(userId, args.id) };
  } else if (name === "list_incomes") {
    result = await listIncomes(userId, args);
  } else if (name === "create_income") {
    result = await createIncome(userId, args);
  } else if (name === "update_income") {
    result = await updateIncome(userId, args.id, args);
  } else if (name === "delete_income") {
    result = { deleted: await deleteIncome(userId, args.id) };
  } else if (name === "list_budgets") {
    result = await listBudgets(userId, args);
  } else if (name === "create_budget") {
    result = await createBudget(userId, args);
  } else if (name === "update_budget") {
    result = await updateBudget(userId, args.id, args);
  } else if (name === "delete_budget") {
    result = { deleted: await deleteBudget(userId, args.id) };
  } else if (name === "list_accounts") {
    result = await listAccounts(userId, args);
  } else if (name === "create_account") {
    result = await createAccount(userId, args);
  } else if (name === "update_account") {
    result = await updateAccount(userId, args.id, args);
  } else if (name === "delete_account") {
    result = { result: await deleteAccount(userId, args.id) };
  } else if (name === "account_summary") {
    result = await getAccountSummary(userId, args.id);
  } else if (name === "transfer_between_accounts") {
    result = await transferBetweenAccounts(userId, args);
  } else if (name === "list_transfers") {
    result = await listTransfers(userId, args);
  } else if (name === "get_chart_data") {
    result = await getChartData(userId, args);
  } else {
    throw new Error(`Unknown tool: ${name}`);
  }

  await maybeSyncVectorDocuments(userId, name, args, result);

  return result;
}

async function maybeSyncVectorDocuments(userId, toolName, args, result) {
  try {
    if (toolName === "create_expense" || toolName === "update_expense") {
      if (result?.id) {
        await syncFinanceDocument({ userId, sourceType: "expense", sourceId: result.id });
      }
      return;
    }

    if (toolName === "delete_expense") {
      await deleteFinanceDocument({ userId, sourceType: "expense", sourceId: args.id });
      return;
    }

    if (toolName === "create_income" || toolName === "update_income") {
      if (result?.id) {
        await syncFinanceDocument({ userId, sourceType: "income", sourceId: result.id });
      }
      return;
    }

    if (toolName === "delete_income") {
      await deleteFinanceDocument({ userId, sourceType: "income", sourceId: args.id });
      return;
    }

    if (toolName === "create_category" || toolName === "update_category") {
      if (result?.id) {
        await syncFinanceDocument({ userId, sourceType: "category", sourceId: result.id });
      }
      return;
    }

    if (toolName === "delete_category") {
      await deleteFinanceDocument({ userId, sourceType: "category", sourceId: args.id });
      return;
    }

  } catch (error) {
    console.warn("Vector sync skipped:", error.message);
  }
}
