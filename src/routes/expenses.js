import express from "express";
import {
  createExpense,
  deleteExpense,
  getExpenseById,
  getMonthlySummary,
  listExpenses,
  updateExpense
} from "../services/expense-service.js";

const router = express.Router();

function validateExpensePayload(payload) {
  const errors = [];

  if (!payload.title || typeof payload.title !== "string") {
    errors.push("title is required");
  }

  const amount = Number(payload.amount);
  if (Number.isNaN(amount) || amount < 0) {
    errors.push("amount must be a non-negative number");
  }

  if (!payload.category || typeof payload.category !== "string") {
    errors.push("category is required");
  }

  if (!payload.spentOn || Number.isNaN(Date.parse(payload.spentOn))) {
    errors.push("spentOn must be a valid date");
  }

  if (payload.notes !== undefined && typeof payload.notes !== "string") {
    errors.push("notes must be a string");
  }

  return {
    errors,
    value: {
      title: payload.title?.trim(),
      amount,
      category: payload.category?.trim(),
      spentOn: payload.spentOn,
      notes: payload.notes?.trim() ?? ""
    }
  };
}

router.get("/", async (req, res, next) => {
  try {
    const expenses = await listExpenses({
      category: req.query.category,
      from: req.query.from,
      to: req.query.to
    });
    res.json(expenses);
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

    const summary = await getMonthlySummary(month);
    res.json(summary);
  } catch (error) {
    next(error);
  }
});

router.get("/:id", async (req, res, next) => {
  try {
    const expense = await getExpenseById(Number(req.params.id));
    if (!expense) {
      return res.status(404).json({ error: "Expense not found" });
    }
    res.json(expense);
  } catch (error) {
    next(error);
  }
});

router.post("/", async (req, res, next) => {
  try {
    const { errors, value } = validateExpensePayload(req.body);
    if (errors.length) {
      return res.status(400).json({ errors });
    }

    const expense = await createExpense(value);
    res.status(201).json(expense);
  } catch (error) {
    next(error);
  }
});

router.put("/:id", async (req, res, next) => {
  try {
    const { errors, value } = validateExpensePayload(req.body);
    if (errors.length) {
      return res.status(400).json({ errors });
    }

    const expense = await updateExpense(Number(req.params.id), value);
    if (!expense) {
      return res.status(404).json({ error: "Expense not found" });
    }

    res.json(expense);
  } catch (error) {
    next(error);
  }
});

router.delete("/:id", async (req, res, next) => {
  try {
    const deleted = await deleteExpense(Number(req.params.id));
    if (!deleted) {
      return res.status(404).json({ error: "Expense not found" });
    }

    res.status(204).send();
  } catch (error) {
    next(error);
  }
});

export default router;
