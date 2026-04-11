import { Router } from "express";
import { query } from "../db.js";
import {
  listAccounts,
  listBudgets,
  listCategories,
  listExpenses,
  listIncomes,
  listTransfers
} from "../services/finance-service.js";
import { syncFinanceDocument } from "../ai/vector/finance-document-sync.js";

const router = Router();

/**
 * POST /api/admin/reindex
 *
 * Triggers a full reindex of all financial data into the vector store.
 * Protected by AUTH_SECRET header — not user auth.
 *
 * Usage:
 *   curl -X POST https://your-app.onrender.com/api/admin/reindex \
 *     -H "x-admin-secret: YOUR_AUTH_SECRET"
 */
router.post("/reindex", async (req, res) => {
  const adminSecret = process.env.AUTH_SECRET;
  const providedSecret = req.headers["x-admin-secret"];

  if (!adminSecret || providedSecret !== adminSecret) {
    return res.status(401).json({ error: "Unauthorized" });
  }

  try {
    const users = await query("SELECT id FROM users ORDER BY id ASC");
    const results = [];

    for (const user of users) {
      const userId = user.id;
      const [categories, expenses, incomes, accounts, budgets, transfers] =
        await Promise.all([
          listCategories(userId),
          listExpenses(userId),
          listIncomes(userId),
          listAccounts(userId),
          listBudgets(userId),
          listTransfers(userId)
        ]);

      let indexed = 0;
      let errors = 0;

      const items = [
        ...categories.map((r) => ({ sourceType: "category", sourceId: r.id })),
        ...expenses.map((r) => ({ sourceType: "expense", sourceId: r.id })),
        ...incomes.map((r) => ({ sourceType: "income", sourceId: r.id })),
        ...accounts.map((r) => ({ sourceType: "account", sourceId: r.id })),
        ...budgets.map((r) => ({ sourceType: "budget", sourceId: r.id })),
        ...transfers.map((r) => ({ sourceType: "transfer", sourceId: r.id }))
      ];

      for (const item of items) {
        try {
          await syncFinanceDocument({ userId, ...item });
          indexed++;
        } catch (err) {
          console.error(
            `Failed to index ${item.sourceType}:${item.sourceId} for user ${userId}:`,
            err.message
          );
          errors++;
        }
      }

      results.push({
        userId,
        total: items.length,
        indexed,
        errors,
        breakdown: {
          categories: categories.length,
          expenses: expenses.length,
          incomes: incomes.length,
          accounts: accounts.length,
          budgets: budgets.length,
          transfers: transfers.length
        }
      });
    }

    res.json({
      ok: true,
      message: "Reindex complete",
      results
    });
  } catch (error) {
    console.error("Reindex failed:", error);
    res.status(500).json({ error: "Reindex failed", details: error.message });
  }
});

export default router;
