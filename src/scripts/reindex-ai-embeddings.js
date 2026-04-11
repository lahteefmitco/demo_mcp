import { closeDatabase, query } from "../db.js";
import {
  listCategories,
  listExpenses,
  listIncomes
} from "../services/finance-service.js";
import { syncFinanceDocument } from "../ai/vector/finance-document-sync.js";

async function main() {
  const users = await query("SELECT id FROM users ORDER BY id ASC");

  for (const user of users) {
    const userId = user.id;
    const [categories, expenses, incomes] = await Promise.all([
      listCategories(userId),
      listExpenses(userId),
      listIncomes(userId)
    ]);

    for (const category of categories) {
      await syncFinanceDocument({ userId, sourceType: "category", sourceId: category.id });
    }

    for (const expense of expenses) {
      await syncFinanceDocument({ userId, sourceType: "expense", sourceId: expense.id });
    }

    for (const income of incomes) {
      await syncFinanceDocument({ userId, sourceType: "income", sourceId: income.id });
    }

    console.log(
      `Indexed user ${userId}: ${categories.length} categories, ${expenses.length} expenses, ${incomes.length} incomes.`
    );
  }
}

main()
  .catch((error) => {
    console.error("Failed to reindex AI embeddings.");
    console.error(error);
    process.exitCode = 1;
  })
  .finally(async () => {
    await closeDatabase();
  });
