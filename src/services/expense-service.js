import { QueryTypes, query } from "../db.js";

function normalizeExpense(row) {
  return {
    id: row.id,
    title: row.title,
    amount: Number(row.amount),
    category: row.category,
    spentOn: row.spent_on,
    notes: row.notes,
    createdAt: row.created_at,
    updatedAt: row.updated_at
  };
}

export async function listExpenses(filters = {}) {
  const conditions = [];
  const values = [];
  const limit = filters.limit ? Number(filters.limit) : null;

  if (filters.category) {
    values.push(filters.category);
    conditions.push(`category = $${values.length}`);
  }

  if (filters.from) {
    values.push(filters.from);
    conditions.push(`spent_on >= $${values.length}`);
  }

  if (filters.to) {
    values.push(filters.to);
    conditions.push(`spent_on <= $${values.length}`);
  }

  const whereClause = conditions.length ? `WHERE ${conditions.join(" AND ")}` : "";
  const sql = `
    SELECT id, title, amount, category, spent_on, notes, created_at, updated_at
    FROM expenses
    ${whereClause}
    ORDER BY spent_on DESC, id DESC
    ${limit ? `LIMIT $${values.length + 1}` : ""}
  `;

  const bindValues = limit ? [...values, limit] : values;
  const rows = await query(sql, bindValues, { type: QueryTypes.SELECT });
  return rows.map(normalizeExpense);
}

export async function getExpenseById(id) {
  const rows = await query(
    `
      SELECT id, title, amount, category, spent_on, notes, created_at, updated_at
      FROM expenses
      WHERE id = $1
    `,
    [id],
    { type: QueryTypes.SELECT }
  );

  return rows[0] ? normalizeExpense(rows[0]) : null;
}

export async function createExpense({ title, amount, category, spentOn, notes = "" }) {
  const rows = await query(
    `
      INSERT INTO expenses (title, amount, category, spent_on, notes)
      VALUES ($1, $2, $3, $4, $5)
      RETURNING id, title, amount, category, spent_on, notes, created_at, updated_at
    `,
    [title, amount, category, spentOn, notes]
  );

  return normalizeExpense(rows[0]);
}

export async function updateExpense(id, { title, amount, category, spentOn, notes = "" }) {
  const rows = await query(
    `
      UPDATE expenses
      SET title = $2,
          amount = $3,
          category = $4,
          spent_on = $5,
          notes = $6
      WHERE id = $1
      RETURNING id, title, amount, category, spent_on, notes, created_at, updated_at
    `,
    [id, title, amount, category, spentOn, notes]
  );

  return rows[0] ? normalizeExpense(rows[0]) : null;
}

export async function deleteExpense(id) {
  const rows = await query("DELETE FROM expenses WHERE id = $1 RETURNING id", [id]);
  return rows.length > 0;
}

export async function getMonthlySummary(month) {
  const totals = await query(
    `
      SELECT
        COALESCE(SUM(amount), 0)::numeric(12, 2) AS total,
        COUNT(*)::int AS expense_count
      FROM expenses
      WHERE TO_CHAR(spent_on, 'YYYY-MM') = $1
    `,
    [month],
    { type: QueryTypes.SELECT }
  );

  const byCategory = await query(
    `
      SELECT category, COALESCE(SUM(amount), 0)::numeric(12, 2) AS total
      FROM expenses
      WHERE TO_CHAR(spent_on, 'YYYY-MM') = $1
      GROUP BY category
      ORDER BY total DESC, category ASC
    `,
    [month],
    { type: QueryTypes.SELECT }
  );

  return {
    month,
    total: Number(totals[0].total),
    expenseCount: totals[0].expense_count,
    byCategory: byCategory.map((row) => ({
      category: row.category,
      total: Number(row.total)
    }))
  };
}

export async function listCategories() {
  const rows = await query(
    `
      SELECT DISTINCT category
      FROM expenses
      WHERE category IS NOT NULL AND category <> ''
      ORDER BY category ASC
    `,
    [],
    { type: QueryTypes.SELECT }
  );

  return rows.map((row) => row.category);
}

export async function getMobileBootstrap(month) {
  const [summary, recentExpenses, categories] = await Promise.all([
    getMonthlySummary(month),
    listExpenses({ limit: 10 }),
    listCategories()
  ]);

  return {
    month,
    summary,
    categories,
    recentExpenses
  };
}
