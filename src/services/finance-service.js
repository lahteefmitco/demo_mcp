import { QueryTypes, query } from "../db.js";

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
    spentOn: row.spent_on,
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
    receivedOn: row.received_on,
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
    startDate: row.start_date,
    endDate: row.end_date,
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

export async function listCategories(filters = {}) {
  const values = [];
  const conditions = [];

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

export async function createCategory({ name, kind = "expense", color = "#0E7490", icon = "tag" }) {
  const rows = await query(
    `
      INSERT INTO categories (name, kind, color, icon)
      VALUES ($1, $2, $3, $4)
      RETURNING id, name, kind, color, icon, created_at, updated_at
    `,
    [name, kind, color, icon]
  );

  return normalizeCategory(rows[0]);
}

export async function listExpenses(filters = {}) {
  const conditions = [];
  const values = [];
  const limit = normalizeListLimit(filters.limit);

  if (filters.categoryId) {
    values.push(filters.categoryId);
    conditions.push(`e.category_id = $${values.length}`);
  }

  if (filters.from) {
    values.push(filters.from);
    conditions.push(`e.spent_on >= $${values.length}`);
  }

  if (filters.to) {
    values.push(filters.to);
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
      JOIN categories c ON c.id = e.category_id
      ${whereClause}
      ORDER BY e.spent_on DESC, e.id DESC
      ${limit ? `LIMIT $${values.length + 1}` : ""}
    `,
    limit ? [...values, limit] : values,
    { type: QueryTypes.SELECT }
  );

  return rows.map(normalizeExpense);
}

export async function createExpense({ title, amount, categoryId, spentOn, notes = "" }) {
  const rows = await query(
    `
      INSERT INTO expenses (title, amount, category_id, spent_on, notes)
      VALUES ($1, $2, $3, $4, $5)
      RETURNING id, title, amount, category_id, spent_on, notes, created_at, updated_at
    `,
    [title, amount, categoryId, spentOn, notes]
  );

  const expense = await getExpenseById(rows[0].id);
  return expense;
}

export async function updateExpense(id, { title, amount, categoryId, spentOn, notes = "" }) {
  const rows = await query(
    `
      UPDATE expenses
      SET title = $2,
          amount = $3,
          category_id = $4,
          spent_on = $5,
          notes = $6
      WHERE id = $1
      RETURNING id
    `,
    [id, title, amount, categoryId, spentOn, notes]
  );

  if (!rows[0]) {
    return null;
  }

  return getExpenseById(rows[0].id);
}

export async function getExpenseById(id) {
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
      JOIN categories c ON c.id = e.category_id
      WHERE e.id = $1
    `,
    [id],
    { type: QueryTypes.SELECT }
  );

  return rows[0] ? normalizeExpense(rows[0]) : null;
}

export async function deleteExpense(id) {
  const rows = await query("DELETE FROM expenses WHERE id = $1 RETURNING id", [id]);
  return rows.length > 0;
}

export async function listIncomes(filters = {}) {
  const conditions = [];
  const values = [];
  const limit = normalizeListLimit(filters.limit);

  if (filters.categoryId) {
    values.push(filters.categoryId);
    conditions.push(`i.category_id = $${values.length}`);
  }

  if (filters.from) {
    values.push(filters.from);
    conditions.push(`i.received_on >= $${values.length}`);
  }

  if (filters.to) {
    values.push(filters.to);
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
      JOIN categories c ON c.id = i.category_id
      ${whereClause}
      ORDER BY i.received_on DESC, i.id DESC
      ${limit ? `LIMIT $${values.length + 1}` : ""}
    `,
    limit ? [...values, limit] : values,
    { type: QueryTypes.SELECT }
  );

  return rows.map(normalizeIncome);
}

export async function createIncome({ title, amount, categoryId, receivedOn, notes = "" }) {
  const rows = await query(
    `
      INSERT INTO incomes (title, amount, category_id, received_on, notes)
      VALUES ($1, $2, $3, $4, $5)
      RETURNING id
    `,
    [title, amount, categoryId, receivedOn, notes]
  );

  return getIncomeById(rows[0].id);
}

export async function updateIncome(id, { title, amount, categoryId, receivedOn, notes = "" }) {
  const rows = await query(
    `
      UPDATE incomes
      SET title = $2,
          amount = $3,
          category_id = $4,
          received_on = $5,
          notes = $6
      WHERE id = $1
      RETURNING id
    `,
    [id, title, amount, categoryId, receivedOn, notes]
  );

  if (!rows[0]) {
    return null;
  }

  return getIncomeById(rows[0].id);
}

export async function getIncomeById(id) {
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
      JOIN categories c ON c.id = i.category_id
      WHERE i.id = $1
    `,
    [id],
    { type: QueryTypes.SELECT }
  );

  return rows[0] ? normalizeIncome(rows[0]) : null;
}

export async function deleteIncome(id) {
  const rows = await query("DELETE FROM incomes WHERE id = $1 RETURNING id", [id]);
  return rows.length > 0;
}

export async function listBudgets(filters = {}) {
  const conditions = [];
  const values = [];

  if (filters.period) {
    values.push(filters.period);
    conditions.push(`b.period = $${values.length}`);
  }

  if (filters.categoryId) {
    values.push(filters.categoryId);
    conditions.push(`b.category_id = $${values.length}`);
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
      LEFT JOIN categories c ON c.id = bw.category_id
      LEFT JOIN expenses e
        ON e.spent_on BETWEEN bw.start_date AND bw.end_date
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

export async function createBudget({ name, amount, period, startDate, categoryId = null, notes = "" }) {
  const rows = await query(
    `
      INSERT INTO budgets (name, amount, period, start_date, category_id, notes)
      VALUES ($1, $2, $3, $4, $5, $6)
      RETURNING id
    `,
    [name, amount, period, startDate, categoryId, notes]
  );

  return getBudgetById(rows[0].id);
}

export async function updateBudget(id, { name, amount, period, startDate, categoryId = null, notes = "" }) {
  const rows = await query(
    `
      UPDATE budgets
      SET name = $2,
          amount = $3,
          period = $4,
          start_date = $5,
          category_id = $6,
          notes = $7
      WHERE id = $1
      RETURNING id
    `,
    [id, name, amount, period, startDate, categoryId, notes]
  );

  if (!rows[0]) {
    return null;
  }

  return getBudgetById(rows[0].id);
}

export async function getBudgetById(id) {
  const budgets = await listBudgets({});
  return budgets.find((budget) => budget.id === id) ?? null;
}

export async function deleteBudget(id) {
  const rows = await query("DELETE FROM budgets WHERE id = $1 RETURNING id", [id]);
  return rows.length > 0;
}

export async function getPeriodSummary(month) {
  const expenseTotals = await query(
    `
      SELECT COALESCE(SUM(amount), 0)::numeric(12, 2) AS total, COUNT(*)::int AS item_count
      FROM expenses
      WHERE TO_CHAR(spent_on, 'YYYY-MM') = $1
    `,
    [month],
    { type: QueryTypes.SELECT }
  );

  const incomeTotals = await query(
    `
      SELECT COALESCE(SUM(amount), 0)::numeric(12, 2) AS total, COUNT(*)::int AS item_count
      FROM incomes
      WHERE TO_CHAR(received_on, 'YYYY-MM') = $1
    `,
    [month],
    { type: QueryTypes.SELECT }
  );

  const expenseByCategory = await query(
    `
      SELECT c.name AS category, c.color, COALESCE(SUM(e.amount), 0)::numeric(12, 2) AS total
      FROM expenses e
      JOIN categories c ON c.id = e.category_id
      WHERE TO_CHAR(e.spent_on, 'YYYY-MM') = $1
      GROUP BY c.name, c.color
      ORDER BY total DESC, c.name ASC
    `,
    [month],
    { type: QueryTypes.SELECT }
  );

  return {
    month,
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

export async function getFinanceDashboard(month) {
  const [summary, recentExpenses, recentIncomes, categories, budgets] = await Promise.all([
    getPeriodSummary(month),
    listExpenses({ limit: 8 }),
    listIncomes({ limit: 8 }),
    listCategories({}),
    listBudgets({})
  ]);

  return {
    month,
    summary,
    categories,
    recentExpenses,
    recentIncomes,
    budgets: budgets.slice(0, 8)
  };
}
