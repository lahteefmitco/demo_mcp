import express from "express";
import {
  createBudget,
  createCategory,
  createExpense,
  createIncome,
  deleteBudget,
  deleteExpense,
  deleteIncome,
  getFinanceDashboard,
  getPeriodSummary,
  listBudgets,
  listCategories,
  listExpenses,
  listIncomes,
  updateBudget,
  updateExpense,
  updateIncome
} from "../services/finance-service.js";

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

  if (!payload.title || typeof payload.title !== "string") {
    errors.push("title is required");
  }

  if (Number.isNaN(amount) || amount < 0) {
    errors.push("amount must be a non-negative number");
  }

  if (!Number.isInteger(categoryId) || categoryId <= 0) {
    errors.push("categoryId must be a positive integer");
  }

  if (!payload.spentOn || Number.isNaN(Date.parse(payload.spentOn))) {
    errors.push("spentOn must be a valid date");
  }

  return {
    errors,
    value: {
      title: payload.title?.trim(),
      amount,
      categoryId,
      spentOn: payload.spentOn,
      notes: payload.notes?.trim() ?? ""
    }
  };
}

function validateIncomePayload(payload) {
  const errors = [];
  const amount = Number(payload.amount);
  const categoryId = Number(payload.categoryId);

  if (!payload.title || typeof payload.title !== "string") {
    errors.push("title is required");
  }

  if (Number.isNaN(amount) || amount < 0) {
    errors.push("amount must be a non-negative number");
  }

  if (!Number.isInteger(categoryId) || categoryId <= 0) {
    errors.push("categoryId must be a positive integer");
  }

  if (!payload.receivedOn || Number.isNaN(Date.parse(payload.receivedOn))) {
    errors.push("receivedOn must be a valid date");
  }

  return {
    errors,
    value: {
      title: payload.title?.trim(),
      amount,
      categoryId,
      receivedOn: payload.receivedOn,
      notes: payload.notes?.trim() ?? ""
    }
  };
}

function validateBudgetPayload(payload) {
  const errors = [];
  const amount = Number(payload.amount);
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

  if (!payload.startDate || Number.isNaN(Date.parse(payload.startDate))) {
    errors.push("startDate must be a valid date");
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
      startDate: payload.startDate,
      categoryId,
      notes: payload.notes?.trim() ?? ""
    }
  };
}

router.get("/dashboard", async (req, res, next) => {
  try {
    const month = req.query.month;
    if (!month || !/^\d{4}-\d{2}$/.test(month)) {
      return res.status(400).json({ error: "month must be in YYYY-MM format" });
    }

    res.json(await getFinanceDashboard(month));
  } catch (error) {
    next(error);
  }
});

router.get("/summary", async (req, res, next) => {
  try {
    const month = req.query.month;
    if (!month || !/^\d{4}-\d{2}$/.test(month)) {
      return res.status(400).json({ error: "month must be in YYYY-MM format" });
    }

    res.json(await getPeriodSummary(month));
  } catch (error) {
    next(error);
  }
});

router.get("/categories", async (req, res, next) => {
  try {
    res.json(await listCategories({ kind: req.query.kind }));
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

    res.status(201).json(await createCategory(value));
  } catch (error) {
    next(error);
  }
});

router.get("/expenses", async (req, res, next) => {
  try {
    res.json(
      await listExpenses({
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

router.post("/expenses", async (req, res, next) => {
  try {
    const { errors, value } = validateExpensePayload(req.body);
    if (errors.length) {
      return res.status(400).json({ errors });
    }

    res.status(201).json(await createExpense(value));
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

    const expense = await updateExpense(id, value);
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

    const deleted = await deleteExpense(id);
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
      await listIncomes({
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

    res.status(201).json(await createIncome(value));
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

    const income = await updateIncome(id, value);
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

    const deleted = await deleteIncome(id);
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
      await listBudgets({
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

    res.status(201).json(await createBudget(value));
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

    const budget = await updateBudget(id, value);
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

    const deleted = await deleteBudget(id);
    if (!deleted) {
      return res.status(404).json({ error: "Budget not found" });
    }

    res.status(204).send();
  } catch (error) {
    next(error);
  }
});

export default router;
