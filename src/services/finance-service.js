import { QueryTypes, query } from "../db.js";
import {
  formatProjectDate,
  formatProjectMonth,
  parseProjectDateToIso,
  parseProjectMonth
} from "../utils/date-utils.js";

function normalizeCategory(row) {
  return {
    id: row.id,
    name: row.name,
    kind: row.kind,
    color: row.color,
    icon: row.icon,
    createdAt: row.created_at,
    updatedAt: row.updated_at
  };
}

function normalizeExpense(row) {
  return {
    id: row.id,
    title: row.title,
    amount: Number(row.amount),
    categoryId: row.category_id,
    categoryName: row.category_name,
    categoryColor: row.category_color,
    spentOn: formatProjectDate(row.spent_on),
    notes: row.notes,
    createdAt: row.created_at,
    updatedAt: row.updated_at
  };
}

function normalizeIncome(row) {
  return {
    id: row.id,
    title: row.title,
    amount: Number(row.amount),
    categoryId: row.category_id,
    categoryName: row.category_name,
    categoryColor: row.category_color,
    receivedOn: formatProjectDate(row.received_on),
    notes: row.notes,
    createdAt: row.created_at,
    updatedAt: row.updated_at
  };
}

function normalizeBudget(row) {
  return {
    id: row.id,
    name: row.name,
    amount: Number(row.amount),
    period: row.period,
    startDate: formatProjectDate(row.start_date),
    endDate: formatProjectDate(row.end_date),
    notes: row.notes,
    categoryId: row.category_id,
    categoryName: row.category_name,
    categoryColor: row.category_color,
    spent: Number(row.spent ?? 0),
    remaining: Number(row.remaining ?? row.amount),
    createdAt: row.created_at,
    updatedAt: row.updated_at
  };
}

function normalizeListLimit(limit) {
  if (limit === undefined || limit === null || limit === "") {
    return null;
  }

  const numeric = Number(limit);
  return Number.isInteger(numeric) && numeric > 0 ? numeric : null;
}

function uniqueRows(items, keySelector) {
  return [...new Map(items.map((item) => [keySelector(item), item])).values()];
}

export async function ensureDefaultCategoriesForUser(userId) {
  await query(
    `
      INSERT INTO categories (user_id, name, kind, color, icon)
      VALUES
        ($1, 'Food', 'expense', '#EF4444', 'restaurant'),
        ($1, 'Transport', 'expense', '#3B82F6', 'directions_car'),
        ($1, 'Bills', 'expense', '#F59E0B', 'receipt_long'),
        ($1, 'Shopping', 'expense', '#8B5CF6', 'shopping_bag'),
        ($1, 'Salary', 'income', '#10B981', 'payments'),
        ($1, 'Freelance', 'income', '#14B8A6', 'work'),
        ($1, 'Savings', 'both', '#0EA5A4', 'savings')
      ON CONFLICT (user_id, name) DO NOTHING
    `,
    [userId]
  );
}

export async function listCategories(userId, filters = {}) {
  const values = [];
  const conditions = [];

  values.push(userId);
  conditions.push(`user_id = $${values.length}`);

  if (filters.kind) {
    values.push(filters.kind);
    conditions.push(`(kind = $${values.length} OR kind = 'both')`);
  }

  const whereClause = conditions.length ? `WHERE ${conditions.join(" AND ")}` : "";
  const rows = await query(
    `
      SELECT id, name, kind, color, icon, created_at, updated_at
      FROM categories
      ${whereClause}
      ORDER BY name ASC
    `,
    values,
    { type: QueryTypes.SELECT }
  );

  return rows.map(normalizeCategory);
}

export async function createCategory(
  userId,
  { name, kind = "expense", color = "#0E7490", icon = "tag" }
) {
  const rows = await query(
    `
      INSERT INTO categories (user_id, name, kind, color, icon)
      VALUES ($1, $2, $3, $4, $5)
      RETURNING id, name, kind, color, icon, created_at, updated_at
    `,
    [userId, name, kind, color, icon]
  );

  return normalizeCategory(rows[0]);
}

async function ensureOwnedCategory(userId, categoryId) {
  const rows = await query(
    `
      SELECT id
      FROM categories
      WHERE id = $1 AND user_id = $2
    `,
    [categoryId, userId],
    { type: QueryTypes.SELECT }
  );

  if (!rows[0]) {
    throw new Error("Category not found");
  }
}

export async function listExpenses(userId, filters = {}) {
  const conditions = [];
  const values = [];
  const limit = normalizeListLimit(filters.limit);
  const from = parseProjectDateToIso(filters.from);
  const to = parseProjectDateToIso(filters.to);

  values.push(userId);
  conditions.push(`e.user_id = $${values.length}`);

  if (filters.categoryId) {
    values.push(filters.categoryId);
    conditions.push(`e.category_id = $${values.length}`);
  }

  if (from) {
    values.push(from);
    conditions.push(`e.spent_on >= $${values.length}`);
  }

  if (to) {
    values.push(to);
    conditions.push(`e.spent_on <= $${values.length}`);
  }

  const whereClause = conditions.length ? `WHERE ${conditions.join(" AND ")}` : "";
  const rows = await query(
    `
      SELECT
        e.id,
        e.title,
        e.amount,
        e.category_id,
        c.name AS category_name,
        c.color AS category_color,
        e.spent_on,
        e.notes,
        e.created_at,
        e.updated_at
      FROM expenses e
      JOIN categories c ON c.id = e.category_id AND c.user_id = e.user_id
      ${whereClause}
      ORDER BY e.spent_on DESC, e.id DESC
      ${limit ? `LIMIT $${values.length + 1}` : ""}
    `,
    limit ? [...values, limit] : values,
    { type: QueryTypes.SELECT }
  );

  return rows.map(normalizeExpense);
}

export async function createExpense(
  userId,
  { title, amount, categoryId, spentOn, notes = "" }
) {
  await ensureOwnedCategory(userId, categoryId);
  const normalizedSpentOn = parseProjectDateToIso(spentOn) ?? spentOn;
  const rows = await query(
    `
      INSERT INTO expenses (user_id, title, amount, category_id, spent_on, notes)
      VALUES ($1, $2, $3, $4, $5, $6)
      RETURNING id, title, amount, category_id, spent_on, notes, created_at, updated_at
    `,
    [userId, title, amount, categoryId, normalizedSpentOn, notes]
  );

  const expense = await getExpenseById(userId, rows[0].id);
  return expense;
}

export async function updateExpense(
  userId,
  id,
  { title, amount, categoryId, spentOn, notes = "" }
) {
  await ensureOwnedCategory(userId, categoryId);
  const normalizedSpentOn = parseProjectDateToIso(spentOn) ?? spentOn;
  const rows = await query(
    `
      UPDATE expenses
      SET title = $3,
          amount = $4,
          category_id = $5,
          spent_on = $6,
          notes = $7
      WHERE id = $1 AND user_id = $2
      RETURNING id
    `,
    [id, userId, title, amount, categoryId, normalizedSpentOn, notes]
  );

  if (!rows[0]) {
    return null;
  }

  return getExpenseById(userId, rows[0].id);
}

export async function getExpenseById(userId, id) {
  const rows = await query(
    `
      SELECT
        e.id,
        e.title,
        e.amount,
        e.category_id,
        c.name AS category_name,
        c.color AS category_color,
        e.spent_on,
        e.notes,
        e.created_at,
        e.updated_at
      FROM expenses e
      JOIN categories c ON c.id = e.category_id AND c.user_id = e.user_id
      WHERE e.id = $1 AND e.user_id = $2
    `,
    [id, userId],
    { type: QueryTypes.SELECT }
  );

  return rows[0] ? normalizeExpense(rows[0]) : null;
}

export async function deleteExpense(userId, id) {
  const rows = await query(
    "DELETE FROM expenses WHERE id = $1 AND user_id = $2 RETURNING id",
    [id, userId]
  );
  return rows.length > 0;
}

export async function listIncomes(userId, filters = {}) {
  const conditions = [];
  const values = [];
  const limit = normalizeListLimit(filters.limit);
  const from = parseProjectDateToIso(filters.from);
  const to = parseProjectDateToIso(filters.to);

  values.push(userId);
  conditions.push(`i.user_id = $${values.length}`);

  if (filters.categoryId) {
    values.push(filters.categoryId);
    conditions.push(`i.category_id = $${values.length}`);
  }

  if (from) {
    values.push(from);
    conditions.push(`i.received_on >= $${values.length}`);
  }

  if (to) {
    values.push(to);
    conditions.push(`i.received_on <= $${values.length}`);
  }

  const whereClause = conditions.length ? `WHERE ${conditions.join(" AND ")}` : "";
  const rows = await query(
    `
      SELECT
        i.id,
        i.title,
        i.amount,
        i.category_id,
        c.name AS category_name,
        c.color AS category_color,
        i.received_on,
        i.notes,
        i.created_at,
        i.updated_at
      FROM incomes i
      JOIN categories c ON c.id = i.category_id AND c.user_id = i.user_id
      ${whereClause}
      ORDER BY i.received_on DESC, i.id DESC
      ${limit ? `LIMIT $${values.length + 1}` : ""}
    `,
    limit ? [...values, limit] : values,
    { type: QueryTypes.SELECT }
  );

  return rows.map(normalizeIncome);
}

export async function createIncome(
  userId,
  { title, amount, categoryId, receivedOn, notes = "" }
) {
  await ensureOwnedCategory(userId, categoryId);
  const normalizedReceivedOn = parseProjectDateToIso(receivedOn) ?? receivedOn;
  const rows = await query(
    `
      INSERT INTO incomes (user_id, title, amount, category_id, received_on, notes)
      VALUES ($1, $2, $3, $4, $5, $6)
      RETURNING id
    `,
    [userId, title, amount, categoryId, normalizedReceivedOn, notes]
  );

  return getIncomeById(userId, rows[0].id);
}

export async function updateIncome(
  userId,
  id,
  { title, amount, categoryId, receivedOn, notes = "" }
) {
  await ensureOwnedCategory(userId, categoryId);
  const normalizedReceivedOn = parseProjectDateToIso(receivedOn) ?? receivedOn;
  const rows = await query(
    `
      UPDATE incomes
      SET title = $3,
          amount = $4,
          category_id = $5,
          received_on = $6,
          notes = $7
      WHERE id = $1 AND user_id = $2
      RETURNING id
    `,
    [id, userId, title, amount, categoryId, normalizedReceivedOn, notes]
  );

  if (!rows[0]) {
    return null;
  }

  return getIncomeById(userId, rows[0].id);
}

export async function getIncomeById(userId, id) {
  const rows = await query(
    `
      SELECT
        i.id,
        i.title,
        i.amount,
        i.category_id,
        c.name AS category_name,
        c.color AS category_color,
        i.received_on,
        i.notes,
        i.created_at,
        i.updated_at
      FROM incomes i
      JOIN categories c ON c.id = i.category_id AND c.user_id = i.user_id
      WHERE i.id = $1 AND i.user_id = $2
    `,
    [id, userId],
    { type: QueryTypes.SELECT }
  );

  return rows[0] ? normalizeIncome(rows[0]) : null;
}

export async function deleteIncome(userId, id) {
  const rows = await query(
    "DELETE FROM incomes WHERE id = $1 AND user_id = $2 RETURNING id",
    [id, userId]
  );
  return rows.length > 0;
}

export async function listBudgets(userId, filters = {}) {
  const conditions = [];
  const values = [];

  values.push(userId);
  conditions.push(`bw.user_id = $${values.length}`);

  if (filters.period) {
    values.push(filters.period);
    conditions.push(`bw.period = $${values.length}`);
  }

  if (filters.categoryId) {
    values.push(filters.categoryId);
    conditions.push(`bw.category_id = $${values.length}`);
  }

  const whereClause = conditions.length ? `WHERE ${conditions.join(" AND ")}` : "";
  const rows = await query(
    `
      WITH budget_windows AS (
        SELECT
          b.*,
          CASE
            WHEN b.period = 'daily' THEN b.start_date
            WHEN b.period = 'weekly' THEN b.start_date + INTERVAL '6 day'
            WHEN b.period = 'monthly' THEN (b.start_date + INTERVAL '1 month' - INTERVAL '1 day')
            WHEN b.period = 'yearly' THEN (b.start_date + INTERVAL '1 year' - INTERVAL '1 day')
          END::date AS end_date
        FROM budgets b
      )
      SELECT
        bw.id,
        bw.name,
        bw.amount,
        bw.period,
        bw.start_date,
        bw.end_date,
        bw.notes,
        bw.category_id,
        bw.created_at,
        bw.updated_at,
        c.name AS category_name,
        c.color AS category_color,
        COALESCE(SUM(e.amount), 0)::numeric(12, 2) AS spent,
        (bw.amount - COALESCE(SUM(e.amount), 0))::numeric(12, 2) AS remaining
      FROM budget_windows bw
      LEFT JOIN categories c ON c.id = bw.category_id AND c.user_id = bw.user_id
      LEFT JOIN expenses e
        ON e.spent_on BETWEEN bw.start_date AND bw.end_date
        AND e.user_id = bw.user_id
        AND (bw.category_id IS NULL OR e.category_id = bw.category_id)
      ${whereClause}
      GROUP BY
        bw.id, bw.name, bw.amount, bw.period, bw.start_date, bw.end_date, bw.notes,
        bw.category_id, bw.created_at, bw.updated_at, c.name, c.color
      ORDER BY bw.start_date DESC, bw.id DESC
    `,
    values,
    { type: QueryTypes.SELECT }
  );

  return rows.map(normalizeBudget);
}

export async function createBudget(
  userId,
  { name, amount, period, startDate, categoryId = null, notes = "" }
) {
  if (categoryId !== null) {
    await ensureOwnedCategory(userId, categoryId);
  }
  const normalizedStartDate = parseProjectDateToIso(startDate) ?? startDate;
  const rows = await query(
    `
      INSERT INTO budgets (user_id, name, amount, period, start_date, category_id, notes)
      VALUES ($1, $2, $3, $4, $5, $6, $7)
      RETURNING id
    `,
    [userId, name, amount, period, normalizedStartDate, categoryId, notes]
  );

  return getBudgetById(userId, rows[0].id);
}

export async function updateBudget(
  userId,
  id,
  { name, amount, period, startDate, categoryId = null, notes = "" }
) {
  if (categoryId !== null) {
    await ensureOwnedCategory(userId, categoryId);
  }
  const normalizedStartDate = parseProjectDateToIso(startDate) ?? startDate;
  const rows = await query(
    `
      UPDATE budgets
      SET name = $3,
          amount = $4,
          period = $5,
          start_date = $6,
          category_id = $7,
          notes = $8
      WHERE id = $1 AND user_id = $2
      RETURNING id
    `,
    [id, userId, name, amount, period, normalizedStartDate, categoryId, notes]
  );

  if (!rows[0]) {
    return null;
  }

  return getBudgetById(userId, rows[0].id);
}

export async function getBudgetById(userId, id) {
  const budgets = await listBudgets(userId, {});
  return budgets.find((budget) => budget.id === id) ?? null;
}

export async function deleteBudget(userId, id) {
  const rows = await query(
    "DELETE FROM budgets WHERE id = $1 AND user_id = $2 RETURNING id",
    [id, userId]
  );
  return rows.length > 0;
}

export async function getPeriodSummary(userId, month) {
  const normalizedMonth = parseProjectMonth(month) ?? month;
  const expenseTotals = await query(
    `
      SELECT COALESCE(SUM(amount), 0)::numeric(12, 2) AS total, COUNT(*)::int AS item_count
      FROM expenses
      WHERE user_id = $1 AND TO_CHAR(spent_on, 'YYYY-MM') = $2
    `,
    [userId, normalizedMonth],
    { type: QueryTypes.SELECT }
  );

  const incomeTotals = await query(
    `
      SELECT COALESCE(SUM(amount), 0)::numeric(12, 2) AS total, COUNT(*)::int AS item_count
      FROM incomes
      WHERE user_id = $1 AND TO_CHAR(received_on, 'YYYY-MM') = $2
    `,
    [userId, normalizedMonth],
    { type: QueryTypes.SELECT }
  );

  const expenseByCategory = await query(
    `
      SELECT c.name AS category, c.color, COALESCE(SUM(e.amount), 0)::numeric(12, 2) AS total
      FROM expenses e
      JOIN categories c ON c.id = e.category_id AND c.user_id = e.user_id
      WHERE e.user_id = $1 AND TO_CHAR(e.spent_on, 'YYYY-MM') = $2
      GROUP BY c.name, c.color
      ORDER BY total DESC, c.name ASC
    `,
    [userId, normalizedMonth],
    { type: QueryTypes.SELECT }
  );

  return {
    month: formatProjectMonth(normalizedMonth),
    expenseTotal: Number(expenseTotals[0].total),
    expenseCount: expenseTotals[0].item_count,
    incomeTotal: Number(incomeTotals[0].total),
    incomeCount: incomeTotals[0].item_count,
    balance: Number(incomeTotals[0].total) - Number(expenseTotals[0].total),
    expenseByCategory: expenseByCategory.map((row) => ({
      category: row.category,
      color: row.color,
      total: Number(row.total)
    }))
  };
}

export async function getFinanceDashboard(userId, month) {
  const normalizedMonth = parseProjectMonth(month) ?? month;
  await ensureDefaultCategoriesForUser(userId);
  const [summary, recentExpenses, recentIncomes, categories, budgets] = await Promise.all([
    getPeriodSummary(userId, normalizedMonth),
    listExpenses(userId, { limit: 8 }),
    listIncomes(userId, { limit: 8 }),
    listCategories(userId, {}),
    listBudgets(userId, {})
  ]);

  return {
    month: formatProjectMonth(normalizedMonth),
    summary,
    categories,
    recentExpenses,
    recentIncomes,
    budgets: uniqueRows(budgets, (budget) => budget.id).slice(0, 8)
  };
}
