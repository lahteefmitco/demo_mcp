import express from "express";
import {
  createBudget,
  createCategory,
  createAccount,
  createExpense,
  createIncome,
  deleteBudget,
  deleteCategory,
  deleteAccount,
  deleteExpense,
  deleteIncome,
  getAccountById,
  getAccountExpenses,
  getAccountIncomes,
  getAccountSummary,
  getDailyExpensesSummary,
  getFinanceDashboard,
  getMonthlyExpensesSummary,
  getPeriodSummary,
  getWeeklyExpensesSummary,
  listBudgets,
  listCategories,
  listAccounts,
  listExpenses,
  listIncomes,
  listTransfers,
  updateBudget,
  updateCategory,
  updateAccount,
  updateExpense,
  updateIncome,
  transferBetweenAccounts
} from "../services/finance-service.js";
import {
  parseProjectDateToIso,
  parseProjectMonth
} from "../utils/date-utils.js";

const router = express.Router();
const validBudgetPeriods = ["daily", "weekly", "monthly", "yearly"];
const validCategoryKinds = ["expense", "income", "both"];

function parsePositiveId(value) {
  const id = Number(value);
  return Number.isInteger(id) && id > 0 ? id : null;
}

function validateCategoryPayload(payload) {
  const errors = [];

  if (!payload.name || typeof payload.name !== "string") {
    errors.push("name is required");
  }

  if (payload.kind && !validCategoryKinds.includes(payload.kind)) {
    errors.push("kind must be expense, income, or both");
  }

  return {
    errors,
    value: {
      name: payload.name?.trim(),
      kind: payload.kind ?? "expense",
      color: payload.color?.trim() || "#0E7490",
      icon: payload.icon?.trim() || "tag"
    }
  };
}

function validateExpensePayload(payload) {
  const errors = [];
  const amount = Number(payload.amount);
  const categoryId = Number(payload.categoryId);
  const accountId = Number(payload.accountId);
  const spentOn = parseProjectDateToIso(payload.spentOn);

  if (!payload.title || typeof payload.title !== "string") {
    errors.push("title is required");
  }

  if (Number.isNaN(amount) || amount < 0) {
    errors.push("amount must be a non-negative number");
  }

  if (!Number.isInteger(categoryId) || categoryId <= 0) {
    errors.push("categoryId must be a positive integer");
  }

  if (!Number.isInteger(accountId) || accountId <= 0) {
    errors.push("accountId must be a positive integer");
  }

  if (!spentOn) {
    errors.push("spentOn must be a valid date in dd-MM-yyyy format");
  }

  return {
    errors,
    value: {
      title: payload.title?.trim(),
      amount,
      categoryId,
      accountId,
      spentOn,
      notes: payload.notes?.trim() ?? ""
    }
  };
}

function validateIncomePayload(payload) {
  const errors = [];
  const amount = Number(payload.amount);
  const categoryId = Number(payload.categoryId);
  const accountId = Number(payload.accountId);
  const receivedOn = parseProjectDateToIso(payload.receivedOn);

  if (!payload.title || typeof payload.title !== "string") {
    errors.push("title is required");
  }

  if (Number.isNaN(amount) || amount < 0) {
    errors.push("amount must be a non-negative number");
  }

  if (!Number.isInteger(categoryId) || categoryId <= 0) {
    errors.push("categoryId must be a positive integer");
  }

  if (!Number.isInteger(accountId) || accountId <= 0) {
    errors.push("accountId must be a positive integer");
  }

  if (!receivedOn) {
    errors.push("receivedOn must be a valid date in dd-MM-yyyy format");
  }

  return {
    errors,
    value: {
      title: payload.title?.trim(),
      amount,
      categoryId,
      accountId,
      receivedOn,
      notes: payload.notes?.trim() ?? ""
    }
  };
}

function validateBudgetPayload(payload) {
  const errors = [];
  const amount = Number(payload.amount);
  const startDate = parseProjectDateToIso(payload.startDate);
  const categoryId = payload.categoryId === null || payload.categoryId === undefined || payload.categoryId === ""
    ? null
    : Number(payload.categoryId);

  if (!payload.name || typeof payload.name !== "string") {
    errors.push("name is required");
  }

  if (Number.isNaN(amount) || amount < 0) {
    errors.push("amount must be a non-negative number");
  }

  if (!validBudgetPeriods.includes(payload.period)) {
    errors.push("period must be daily, weekly, monthly, or yearly");
  }

  if (!startDate) {
    errors.push("startDate must be a valid date in dd-MM-yyyy format");
  }

  if (categoryId !== null && (!Number.isInteger(categoryId) || categoryId <= 0)) {
    errors.push("categoryId must be a positive integer when provided");
  }

  return {
    errors,
    value: {
      name: payload.name?.trim(),
      amount,
      period: payload.period,
      startDate,
      categoryId,
      notes: payload.notes?.trim() ?? ""
    }
  };
}

const validAccountTypes = ["cash", "bank", "credit_card", "investments"];

function validateAccountPayload(payload) {
  const errors = [];
  const initialBalance = Number(payload.initialBalance ?? 0);

  if (!payload.name || typeof payload.name !== "string") {
    errors.push("name is required");
  }

  if (payload.type && !validAccountTypes.includes(payload.type)) {
    errors.push("type must be cash, bank, credit_card, or investments");
  }

  if (Number.isNaN(initialBalance) || initialBalance < 0) {
    errors.push("initialBalance must be a non-negative number");
  }

  return {
    errors,
    value: {
      name: payload.name?.trim(),
      type: payload.type ?? "cash",
      initialBalance,
      color: payload.color?.trim() || "#0E7490",
      icon: payload.icon?.trim() || "account_balance_wallet",
      notes: payload.notes?.trim() ?? ""
    }
  };
}

function validateTransferPayload(payload) {
  const errors = [];
  const amount = Number(payload.amount);
  const fromAccountId = Number(payload.fromAccountId);
  const toAccountId = Number(payload.toAccountId);

  if (!Number.isInteger(fromAccountId) || fromAccountId <= 0) {
    errors.push("fromAccountId must be a positive integer");
  }

  if (!Number.isInteger(toAccountId) || toAccountId <= 0) {
    errors.push("toAccountId must be a positive integer");
  }

  if (fromAccountId === toAccountId) {
    errors.push("fromAccountId and toAccountId must be different");
  }

  if (Number.isNaN(amount) || amount <= 0) {
    errors.push("amount must be a positive number");
  }

  return {
    errors,
    value: {
      fromAccountId,
      toAccountId,
      amount,
      notes: payload.notes?.trim() ?? ""
    }
  };
}

router.get("/dashboard", async (req, res, next) => {
  try {
    const month = parseProjectMonth(req.query.month);
    if (!month) {
      return res.status(400).json({ error: "month must be in MM-YYYY or YYYY-MM format" });
    }

    res.json(await getFinanceDashboard(req.user.id, month));
  } catch (error) {
    next(error);
  }
});

router.get("/summary", async (req, res, next) => {
  try {
    const month = parseProjectMonth(req.query.month);
    if (!month) {
      return res.status(400).json({ error: "month must be in MM-YYYY or YYYY-MM format" });
    }

    res.json(await getPeriodSummary(req.user.id, month));
  } catch (error) {
    next(error);
  }
});

router.get("/categories", async (req, res, next) => {
  try {
    res.json(await listCategories(req.user.id, { kind: req.query.kind }));
  } catch (error) {
    next(error);
  }
});

router.post("/categories", async (req, res, next) => {
  try {
    const { errors, value } = validateCategoryPayload(req.body);
    if (errors.length) {
      return res.status(400).json({ errors });
    }

    res.status(201).json(await createCategory(req.user.id, value));
  } catch (error) {
    next(error);
  }
});

router.put("/categories/:id", async (req, res, next) => {
  try {
    const id = parsePositiveId(req.params.id);
    if (!id) {
      return res.status(400).json({ error: "id must be a positive integer" });
    }

    const { errors, value } = validateCategoryPayload(req.body);
    if (errors.length) {
      return res.status(400).json({ errors });
    }

    const category = await updateCategory(req.user.id, id, value);
    if (!category) {
      return res.status(404).json({ error: "Category not found" });
    }

    res.json(category);
  } catch (error) {
    next(error);
  }
});

router.delete("/categories/:id", async (req, res, next) => {
  try {
    const id = parsePositiveId(req.params.id);
    if (!id) {
      return res.status(400).json({ error: "id must be a positive integer" });
    }

    const deleted = await deleteCategory(req.user.id, id);
    if (!deleted) {
      return res.status(404).json({ error: "Category not found" });
    }

    res.status(204).send();
  } catch (error) {
    next(error);
  }
});

router.get("/expenses", async (req, res, next) => {
  try {
    res.json(
      await listExpenses(req.user.id, {
        categoryId: req.query.categoryId,
        from: req.query.from,
        to: req.query.to,
        limit: req.query.limit
      })
    );
  } catch (error) {
    next(error);
  }
});

router.get("/expenses/daily", async (req, res, next) => {
  try {
    const days = Math.min(Math.max(Number(req.query.days) || 7, 1), 30);
    res.json(await getDailyExpensesSummary(req.user.id, days));
  } catch (error) {
    next(error);
  }
});

router.get("/expenses/weekly", async (req, res, next) => {
  try {
    const weeks = Math.min(Math.max(Number(req.query.weeks) || 4, 1), 12);
    res.json(await getWeeklyExpensesSummary(req.user.id, weeks));
  } catch (error) {
    next(error);
  }
});

router.get("/expenses/monthly", async (req, res, next) => {
  try {
    const months = Math.min(Math.max(Number(req.query.months) || 6, 1), 12);
    res.json(await getMonthlyExpensesSummary(req.user.id, months));
  } catch (error) {
    next(error);
  }
});

router.post("/expenses", async (req, res, next) => {
  try {
    const { errors, value } = validateExpensePayload(req.body);
    if (errors.length) {
      return res.status(400).json({ errors });
    }

    res.status(201).json(await createExpense(req.user.id, value));
  } catch (error) {
    next(error);
  }
});

router.put("/expenses/:id", async (req, res, next) => {
  try {
    const id = parsePositiveId(req.params.id);
    if (!id) {
      return res.status(400).json({ error: "id must be a positive integer" });
    }

    const { errors, value } = validateExpensePayload(req.body);
    if (errors.length) {
      return res.status(400).json({ errors });
    }

    const expense = await updateExpense(req.user.id, id, value);
    if (!expense) {
      return res.status(404).json({ error: "Expense not found" });
    }

    res.json(expense);
  } catch (error) {
    next(error);
  }
});

router.delete("/expenses/:id", async (req, res, next) => {
  try {
    const id = parsePositiveId(req.params.id);
    if (!id) {
      return res.status(400).json({ error: "id must be a positive integer" });
    }

    const deleted = await deleteExpense(req.user.id, id);
    if (!deleted) {
      return res.status(404).json({ error: "Expense not found" });
    }

    res.status(204).send();
  } catch (error) {
    next(error);
  }
});

router.get("/incomes", async (req, res, next) => {
  try {
    res.json(
      await listIncomes(req.user.id, {
        categoryId: req.query.categoryId,
        from: req.query.from,
        to: req.query.to,
        limit: req.query.limit
      })
    );
  } catch (error) {
    next(error);
  }
});

router.post("/incomes", async (req, res, next) => {
  try {
    const { errors, value } = validateIncomePayload(req.body);
    if (errors.length) {
      return res.status(400).json({ errors });
    }

    res.status(201).json(await createIncome(req.user.id, value));
  } catch (error) {
    next(error);
  }
});

router.put("/incomes/:id", async (req, res, next) => {
  try {
    const id = parsePositiveId(req.params.id);
    if (!id) {
      return res.status(400).json({ error: "id must be a positive integer" });
    }

    const { errors, value } = validateIncomePayload(req.body);
    if (errors.length) {
      return res.status(400).json({ errors });
    }

    const income = await updateIncome(req.user.id, id, value);
    if (!income) {
      return res.status(404).json({ error: "Income not found" });
    }

    res.json(income);
  } catch (error) {
    next(error);
  }
});

router.delete("/incomes/:id", async (req, res, next) => {
  try {
    const id = parsePositiveId(req.params.id);
    if (!id) {
      return res.status(400).json({ error: "id must be a positive integer" });
    }

    const deleted = await deleteIncome(req.user.id, id);
    if (!deleted) {
      return res.status(404).json({ error: "Income not found" });
    }

    res.status(204).send();
  } catch (error) {
    next(error);
  }
});

router.get("/budgets", async (req, res, next) => {
  try {
    res.json(
      await listBudgets(req.user.id, {
        period: req.query.period,
        categoryId: req.query.categoryId
      })
    );
  } catch (error) {
    next(error);
  }
});

router.post("/budgets", async (req, res, next) => {
  try {
    const { errors, value } = validateBudgetPayload(req.body);
    if (errors.length) {
      return res.status(400).json({ errors });
    }

    res.status(201).json(await createBudget(req.user.id, value));
  } catch (error) {
    next(error);
  }
});

router.put("/budgets/:id", async (req, res, next) => {
  try {
    const id = parsePositiveId(req.params.id);
    if (!id) {
      return res.status(400).json({ error: "id must be a positive integer" });
    }

    const { errors, value } = validateBudgetPayload(req.body);
    if (errors.length) {
      return res.status(400).json({ errors });
    }

    const budget = await updateBudget(req.user.id, id, value);
    if (!budget) {
      return res.status(404).json({ error: "Budget not found" });
    }

    res.json(budget);
  } catch (error) {
    next(error);
  }
});

router.delete("/budgets/:id", async (req, res, next) => {
  try {
    const id = parsePositiveId(req.params.id);
    if (!id) {
      return res.status(400).json({ error: "id must be a positive integer" });
    }

    const deleted = await deleteBudget(req.user.id, id);
    if (!deleted) {
      return res.status(404).json({ error: "Budget not found" });
    }

    res.status(204).send();
  } catch (error) {
    next(error);
  }
});

router.get("/accounts", async (req, res, next) => {
  try {
    res.json(
      await listAccounts(req.user.id, {
        type: req.query.type,
        isActive: req.query.isActive === "true" ? true : req.query.isActive === "false" ? false : undefined
      })
    );
  } catch (error) {
    next(error);
  }
});

router.get("/accounts/:id", async (req, res, next) => {
  try {
    const id = parsePositiveId(req.params.id);
    if (!id) {
      return res.status(400).json({ error: "id must be a positive integer" });
    }

    const account = await getAccountById(req.user.id, id);
    if (!account) {
      return res.status(404).json({ error: "Account not found" });
    }

    res.json(account);
  } catch (error) {
    next(error);
  }
});

router.get("/accounts/:id/summary", async (req, res, next) => {
  try {
    const id = parsePositiveId(req.params.id);
    if (!id) {
      return res.status(400).json({ error: "id must be a positive integer" });
    }

    const summary = await getAccountSummary(req.user.id, id);
    if (!summary) {
      return res.status(404).json({ error: "Account not found" });
    }

    res.json(summary);
  } catch (error) {
    next(error);
  }
});

router.get("/accounts/:id/expenses", async (req, res, next) => {
  try {
    const id = parsePositiveId(req.params.id);
    if (!id) {
      return res.status(400).json({ error: "id must be a positive integer" });
    }

    res.json(
      await getAccountExpenses(req.user.id, id, {
        categoryId: req.query.categoryId,
        from: req.query.from,
        to: req.query.to,
        limit: req.query.limit
      })
    );
  } catch (error) {
    next(error);
  }
});

router.get("/accounts/:id/incomes", async (req, res, next) => {
  try {
    const id = parsePositiveId(req.params.id);
    if (!id) {
      return res.status(400).json({ error: "id must be a positive integer" });
    }

    res.json(
      await getAccountIncomes(req.user.id, id, {
        categoryId: req.query.categoryId,
        from: req.query.from,
        to: req.query.to,
        limit: req.query.limit
      })
    );
  } catch (error) {
    next(error);
  }
});

router.post("/accounts", async (req, res, next) => {
  try {
    const { errors, value } = validateAccountPayload(req.body);
    if (errors.length) {
      return res.status(400).json({ errors });
    }

    res.status(201).json(await createAccount(req.user.id, value));
  } catch (error) {
    next(error);
  }
});

router.put("/accounts/:id", async (req, res, next) => {
  try {
    const id = parsePositiveId(req.params.id);
    if (!id) {
      return res.status(400).json({ error: "id must be a positive integer" });
    }

    const updates = {};
    if (req.body.name !== undefined) updates.name = req.body.name.trim();
    if (req.body.type !== undefined) updates.type = req.body.type;
    if (req.body.color !== undefined) updates.color = req.body.color.trim();
    if (req.body.icon !== undefined) updates.icon = req.body.icon.trim();
    if (req.body.notes !== undefined) updates.notes = req.body.notes.trim();
    if (req.body.isActive !== undefined) updates.isActive = req.body.isActive;

    const account = await updateAccount(req.user.id, id, updates);
    if (!account) {
      return res.status(404).json({ error: "Account not found" });
    }

    res.json(account);
  } catch (error) {
    next(error);
  }
});

router.delete("/accounts/:id", async (req, res, next) => {
  try {
    const id = parsePositiveId(req.params.id);
    if (!id) {
      return res.status(400).json({ error: "id must be a positive integer" });
    }

    const result = await deleteAccount(req.user.id, id);
    if (!result) {
      return res.status(404).json({ error: "Account not found" });
    }

    if (result === "deactivated") {
      return res.json({ message: "Account deactivated (has transactions)" });
    }

    res.status(204).send();
  } catch (error) {
    next(error);
  }
});

router.get("/transfers", async (req, res, next) => {
  try {
    res.json(
      await listTransfers(req.user.id, {
        accountId: req.query.accountId,
        from: req.query.from,
        to: req.query.to,
        limit: req.query.limit
      })
    );
  } catch (error) {
    next(error);
  }
});

router.post("/transfers", async (req, res, next) => {
  try {
    const { errors, value } = validateTransferPayload(req.body);
    if (errors.length) {
      return res.status(400).json({ errors });
    }

    res.status(201).json(await transferBetweenAccounts(req.user.id, value));
  } catch (error) {
    if (error.message.includes("same account") || error.message.includes("positive")) {
      return res.status(400).json({ error: error.message });
    }
    if (error.message.includes("not found")) {
      return res.status(404).json({ error: error.message });
    }
    next(error);
  }
});

export default router;
