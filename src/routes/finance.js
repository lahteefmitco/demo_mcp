import express from "express";
import {
  createBudget,
  createCategory,
  createExpense,
  createIncome,
  deleteBudget,
  deleteCategory,
  deleteExpense,
  deleteIncome,
  getDailyExpensesSummary,
  getFinanceDashboard,
  getMonthlyExpensesSummary,
  getPeriodSummary,
  getWeeklyExpensesSummary,
  listBudgets,
  listCategories,
  listExpenses,
  listIncomes,
  updateBudget,
  updateCategory,
  updateExpense,
  updateIncome
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

  if (!spentOn) {
    errors.push("spentOn must be a valid date in dd-MM-yyyy format");
  }

  return {
    errors,
    value: {
      title: payload.title?.trim(),
      amount,
      categoryId,
      spentOn,
      notes: payload.notes?.trim() ?? ""
    }
  };
}

function validateIncomePayload(payload) {
  const errors = [];
  const amount = Number(payload.amount);
  const categoryId = Number(payload.categoryId);
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

  if (!receivedOn) {
    errors.push("receivedOn must be a valid date in dd-MM-yyyy format");
  }

  return {
    errors,
    value: {
      title: payload.title?.trim(),
      amount,
      categoryId,
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

export default router;
