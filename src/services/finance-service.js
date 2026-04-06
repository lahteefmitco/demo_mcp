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
    accountId: row.account_id,
    accountName: row.account_name,
    accountColor: row.account_color,
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
    accountId: row.account_id,
    accountName: row.account_name,
    accountColor: row.account_color,
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

export async function updateCategory(
  userId,
  id,
  { name, kind, color, icon }
) {
  const rows = await query(
    `
      UPDATE categories
      SET name = $3,
          kind = $4,
          color = $5,
          icon = $6
      WHERE id = $1 AND user_id = $2
      RETURNING id
    `,
    [id, userId, name, kind, color, icon]
  );

  if (!rows[0]) {
    return null;
  }

  return getCategoryById(userId, rows[0].id);
}

export async function getCategoryById(userId, id) {
  const rows = await query(
    `
      SELECT id, name, kind, color, icon, created_at, updated_at
      FROM categories
      WHERE id = $1 AND user_id = $2
    `,
    [id, userId],
    { type: QueryTypes.SELECT }
  );

  return rows[0] ? normalizeCategory(rows[0]) : null;
}

export async function deleteCategory(userId, id) {
  const rows = await query(
    "DELETE FROM categories WHERE id = $1 AND user_id = $2 RETURNING id",
    [id, userId]
  );
  return rows.length > 0;
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

async function ensureOwnedAccount(userId, accountId) {
  const rows = await query(
    `
      SELECT id
      FROM accounts
      WHERE id = $1 AND user_id = $2 AND is_active = true
    `,
    [accountId, userId],
    { type: QueryTypes.SELECT }
  );

  if (!rows[0]) {
    throw new Error("Account not found");
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

  if (filters.accountId) {
    values.push(filters.accountId);
    conditions.push(`e.account_id = $${values.length}`);
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
        e.account_id,
        a.name AS account_name,
        a.color AS account_color,
        e.spent_on,
        e.notes,
        e.created_at,
        e.updated_at
      FROM expenses e
      JOIN categories c ON c.id = e.category_id AND c.user_id = e.user_id
      JOIN accounts a ON a.id = e.account_id AND a.user_id = e.user_id
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
  { title, amount, categoryId, accountId, spentOn, notes = "" }
) {
  await ensureOwnedCategory(userId, categoryId);
  await ensureOwnedAccount(userId, accountId);
  const normalizedSpentOn = parseProjectDateToIso(spentOn) ?? spentOn;
  const rows = await query(
    `
      INSERT INTO expenses (user_id, title, amount, category_id, account_id, spent_on, notes)
      VALUES ($1, $2, $3, $4, $5, $6, $7)
      RETURNING id, title, amount, category_id, account_id, spent_on, notes, created_at, updated_at
    `,
    [userId, title, amount, categoryId, accountId, normalizedSpentOn, notes]
  );

  const expense = await getExpenseById(userId, rows[0].id);
  return expense;
}

export async function updateExpense(
  userId,
  id,
  { title, amount, categoryId, accountId, spentOn, notes = "" }
) {
  await ensureOwnedCategory(userId, categoryId);
  await ensureOwnedAccount(userId, accountId);
  const normalizedSpentOn = parseProjectDateToIso(spentOn) ?? spentOn;
  const rows = await query(
    `
      UPDATE expenses
      SET title = $3,
          amount = $4,
          category_id = $5,
          account_id = $6,
          spent_on = $7,
          notes = $8
      WHERE id = $1 AND user_id = $2
      RETURNING id
    `,
    [id, userId, title, amount, categoryId, accountId, normalizedSpentOn, notes]
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
        e.account_id,
        a.name AS account_name,
        a.color AS account_color,
        e.spent_on,
        e.notes,
        e.created_at,
        e.updated_at
      FROM expenses e
      JOIN categories c ON c.id = e.category_id AND c.user_id = e.user_id
      JOIN accounts a ON a.id = e.account_id AND a.user_id = e.user_id
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

  if (filters.accountId) {
    values.push(filters.accountId);
    conditions.push(`i.account_id = $${values.length}`);
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
        i.account_id,
        a.name AS account_name,
        a.color AS account_color,
        i.received_on,
        i.notes,
        i.created_at,
        i.updated_at
      FROM incomes i
      JOIN categories c ON c.id = i.category_id AND c.user_id = i.user_id
      JOIN accounts a ON a.id = i.account_id AND a.user_id = i.user_id
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
  { title, amount, categoryId, accountId, receivedOn, notes = "" }
) {
  await ensureOwnedCategory(userId, categoryId);
  await ensureOwnedAccount(userId, accountId);
  const normalizedReceivedOn = parseProjectDateToIso(receivedOn) ?? receivedOn;
  const rows = await query(
    `
      INSERT INTO incomes (user_id, title, amount, category_id, account_id, received_on, notes)
      VALUES ($1, $2, $3, $4, $5, $6, $7)
      RETURNING id
    `,
    [userId, title, amount, categoryId, accountId, normalizedReceivedOn, notes]
  );

  return getIncomeById(userId, rows[0].id);
}

export async function updateIncome(
  userId,
  id,
  { title, amount, categoryId, accountId, receivedOn, notes = "" }
) {
  await ensureOwnedCategory(userId, categoryId);
  await ensureOwnedAccount(userId, accountId);
  const normalizedReceivedOn = parseProjectDateToIso(receivedOn) ?? receivedOn;
  const rows = await query(
    `
      UPDATE incomes
      SET title = $3,
          amount = $4,
          category_id = $5,
          account_id = $6,
          received_on = $7,
          notes = $8
      WHERE id = $1 AND user_id = $2
      RETURNING id
    `,
    [id, userId, title, amount, categoryId, accountId, normalizedReceivedOn, notes]
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
        i.account_id,
        a.name AS account_name,
        a.color AS account_color,
        i.received_on,
        i.notes,
        i.created_at,
        i.updated_at
      FROM incomes i
      JOIN categories c ON c.id = i.category_id AND c.user_id = i.user_id
      JOIN accounts a ON a.id = i.account_id AND a.user_id = i.user_id
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
  await ensureDefaultAccountForUser(userId);
  const [summary, recentExpenses, recentIncomes, categories, budgets, accounts] = await Promise.all([
    getPeriodSummary(userId, normalizedMonth),
    listExpenses(userId, { limit: 8 }),
    listIncomes(userId, { limit: 8 }),
    listCategories(userId, {}),
    listBudgets(userId, {}),
    listAccounts(userId, { isActive: true })
  ]);

  return {
    month: formatProjectMonth(normalizedMonth),
    summary,
    categories,
    recentExpenses,
    recentIncomes,
    budgets: uniqueRows(budgets, (budget) => budget.id).slice(0, 8),
    accounts
  };
}

export async function getDailyExpensesSummary(userId, days = 7) {
  const dailyExpenses = await query(
    `
      WITH date_series AS (
        SELECT generate_series(
          CURRENT_DATE - INTERVAL '${days - 1} days',
          CURRENT_DATE,
          '1 day'::interval
        )::date AS day
      ),
      daily_totals AS (
        SELECT 
          ds.day,
          COALESCE(SUM(e.amount), 0)::numeric(12, 2) AS total,
          COUNT(e.id)::int AS count
        FROM date_series ds
        LEFT JOIN expenses e 
          ON e.user_id = $1 
          AND DATE(e.spent_on) = ds.day
        GROUP BY ds.day
      )
      SELECT 
        day,
        total,
        count,
        TO_CHAR(day, 'Dy') AS day_name,
        TO_CHAR(day, 'DD') AS day_number
      FROM daily_totals
      ORDER BY day ASC
    `,
    [userId],
    { type: QueryTypes.SELECT }
  );

  return dailyExpenses.map(row => ({
    date: formatProjectDate(row.day),
    dayName: row.day_name,
    dayNumber: row.day_number,
    total: Number(row.total),
    count: row.count
  }));
}

export async function getWeeklyExpensesSummary(userId, weeks = 4) {
  const weeklyExpenses = await query(
    `
      WITH week_series AS (
        SELECT generate_series(
          DATE_TRUNC('week', CURRENT_DATE) - INTERVAL '${weeks - 1} weeks',
          DATE_TRUNC('week', CURRENT_DATE),
          '1 week'::interval
        )::date AS week_start
      ),
      weekly_totals AS (
        SELECT 
          ws.week_start,
          COALESCE(SUM(e.amount), 0)::numeric(12, 2) AS total,
          COUNT(e.id)::int AS count
        FROM week_series ws
        LEFT JOIN expenses e 
          ON e.user_id = $1 
          AND DATE_TRUNC('week', e.spent_on) = ws.week_start
        GROUP BY ws.week_start
      )
      SELECT 
        week_start,
        total,
        count,
        TO_CHAR(week_start, 'YYYY') AS year,
        TO_CHAR(week_start, 'MM/DD') AS date_range
      FROM weekly_totals
      ORDER BY week_start ASC
    `,
    [userId],
    { type: QueryTypes.SELECT }
  );

  return weeklyExpenses.map(row => ({
    weekStart: formatProjectDate(row.week_start),
    dateRange: row.date_range,
    year: row.year,
    total: Number(row.total),
    count: row.count
  }));
}

export async function getMonthlyExpensesSummary(userId, months = 6) {
  const monthlyExpenses = await query(
    `
      WITH month_series AS (
        SELECT generate_series(
          DATE_TRUNC('month', CURRENT_DATE) - INTERVAL '${months - 1} months',
          DATE_TRUNC('month', CURRENT_DATE),
          '1 month'::interval
        )::date AS month_start
      ),
      monthly_totals AS (
        SELECT 
          ms.month_start,
          COALESCE(SUM(e.amount), 0)::numeric(12, 2) AS total,
          COUNT(e.id)::int AS count
        FROM month_series ms
        LEFT JOIN expenses e 
          ON e.user_id = $1 
          AND DATE_TRUNC('month', e.spent_on) = ms.month_start
        GROUP BY ms.month_start
      )
      SELECT 
        month_start,
        total,
        count,
        TO_CHAR(month_start, 'Mon') AS month_name,
        TO_CHAR(month_start, 'YYYY') AS year
      FROM monthly_totals
      ORDER BY month_start ASC
    `,
    [userId],
    { type: QueryTypes.SELECT }
  );

  return monthlyExpenses.map(row => ({
    monthStart: formatProjectDate(row.month_start),
    monthName: row.month_name,
    year: row.year,
    total: Number(row.total),
    count: row.count
  }));
}

export async function ensureDefaultAccountForUser(userId) {
  await query(
    `
      INSERT INTO accounts (user_id, name, type, initial_balance, color, icon, notes)
      VALUES ($1, 'General Account', 'cash', 0, '#10B981', 'account_balance_wallet', 'Default account for all transactions')
      ON CONFLICT (user_id, name) DO NOTHING
    `,
    [userId]
  );
}

export async function listAccounts(userId, filters = {}) {
  const values = [];
  const conditions = [];

  values.push(userId);
  conditions.push(`user_id = $${values.length}`);

  if (filters.type) {
    values.push(filters.type);
    conditions.push(`type = $${values.length}`);
  }

  if (filters.isActive !== undefined) {
    values.push(filters.isActive);
    conditions.push(`is_active = $${values.length}`);
  }

  const whereClause = conditions.length ? `WHERE ${conditions.join(" AND ")}` : "";
  const rows = await query(
    `
      SELECT 
        a.id,
        a.name,
        a.type,
        a.initial_balance,
        a.color,
        a.icon,
        a.notes,
        a.is_active,
        a.created_at,
        a.updated_at,
        COALESCE(
          a.initial_balance + 
          COALESCE((SELECT SUM(i.amount) FROM incomes i WHERE i.account_id = a.id), 0) -
          COALESCE((SELECT SUM(e.amount) FROM expenses e WHERE e.account_id = a.id), 0),
          a.initial_balance
        )::numeric(12, 2) AS current_balance
      FROM accounts a
      ${whereClause}
      ORDER BY a.name ASC
    `,
    values,
    { type: QueryTypes.SELECT }
  );

  return rows.map(normalizeAccount);
}

function normalizeAccount(row) {
  return {
    id: row.id,
    name: row.name,
    type: row.type,
    initialBalance: Number(row.initial_balance),
    currentBalance: Number(row.current_balance),
    color: row.color,
    icon: row.icon,
    notes: row.notes,
    isActive: row.is_active,
    createdAt: row.created_at,
    updatedAt: row.updated_at
  };
}

export async function createAccount(
  userId,
  { name, type = "cash", initialBalance = 0, color = "#0E7490", icon = "account_balance_wallet", notes = "" }
) {
  const rows = await query(
    `
      INSERT INTO accounts (user_id, name, type, initial_balance, color, icon, notes)
      VALUES ($1, $2, $3, $4, $5, $6, $7)
      RETURNING id
    `,
    [userId, name, type, initialBalance, color, icon, notes]
  );

  return getAccountById(userId, rows[0].id);
}

export async function updateAccount(
  userId,
  id,
  { name, type, color, icon, notes, isActive }
) {
  const fields = [];
  const values = [];
  let paramIndex = 3;

  if (name !== undefined) {
    values.push(name);
    fields.push(`name = $${paramIndex++}`);
  }
  if (type !== undefined) {
    values.push(type);
    fields.push(`type = $${paramIndex++}`);
  }
  if (color !== undefined) {
    values.push(color);
    fields.push(`color = $${paramIndex++}`);
  }
  if (icon !== undefined) {
    values.push(icon);
    fields.push(`icon = $${paramIndex++}`);
  }
  if (notes !== undefined) {
    values.push(notes);
    fields.push(`notes = $${paramIndex++}`);
  }
  if (isActive !== undefined) {
    values.push(isActive);
    fields.push(`is_active = $${paramIndex++}`);
  }

  if (fields.length === 0) {
    return getAccountById(userId, id);
  }

  values.push(id, userId);
  const rows = await query(
    `
      UPDATE accounts
      SET ${fields.join(", ")}
      WHERE id = $${paramIndex++} AND user_id = $${paramIndex}
      RETURNING id
    `,
    values
  );

  if (!rows[0]) {
    return null;
  }

  return getAccountById(userId, rows[0].id);
}

export async function getAccountById(userId, id) {
  const rows = await query(
    `
      SELECT 
        a.id,
        a.name,
        a.type,
        a.initial_balance,
        a.color,
        a.icon,
        a.notes,
        a.is_active,
        a.created_at,
        a.updated_at,
        COALESCE(
          a.initial_balance + 
          COALESCE((SELECT SUM(i.amount) FROM incomes i WHERE i.account_id = a.id), 0) -
          COALESCE((SELECT SUM(e.amount) FROM expenses e WHERE e.account_id = a.id), 0),
          a.initial_balance
        )::numeric(12, 2) AS current_balance
      FROM accounts a
      WHERE a.id = $1 AND a.user_id = $2
    `,
    [id, userId],
    { type: QueryTypes.SELECT }
  );

  return rows[0] ? normalizeAccount(rows[0]) : null;
}

export async function deleteAccount(userId, id) {
  const hasTransactions = await query(
    `
      SELECT EXISTS(
        SELECT 1 FROM expenses WHERE account_id = $1 AND user_id = $2
        UNION ALL
        SELECT 1 FROM incomes WHERE account_id = $1 AND user_id = $2
        UNION ALL
        SELECT 1 FROM transfers WHERE from_account_id = $1 AND user_id = $2
        UNION ALL
        SELECT 1 FROM transfers WHERE to_account_id = $1 AND user_id = $2
        LIMIT 1
      ) AS has_transactions
    `,
    [id, userId],
    { type: QueryTypes.SELECT }
  );

  if (hasTransactions[0]?.has_transactions) {
    const rows = await query(
      "UPDATE accounts SET is_active = false WHERE id = $1 AND user_id = $2 RETURNING id",
      [id, userId]
    );
    return rows.length > 0 ? "deactivated" : null;
  }

  const rows = await query(
    "DELETE FROM accounts WHERE id = $1 AND user_id = $2 RETURNING id",
    [id, userId]
  );
  return rows.length > 0 ? "deleted" : null;
}

export async function getAccountSummary(userId, accountId) {
  const account = await getAccountById(userId, accountId);
  if (!account) {
    return null;
  }

  const incomeTotals = await query(
    `
      SELECT COALESCE(SUM(amount), 0)::numeric(12, 2) AS total, COUNT(*)::int AS item_count
      FROM incomes
      WHERE user_id = $1 AND account_id = $2
    `,
    [userId, accountId],
    { type: QueryTypes.SELECT }
  );

  const expenseTotals = await query(
    `
      SELECT COALESCE(SUM(amount), 0)::numeric(12, 2) AS total, COUNT(*)::int AS item_count
      FROM expenses
      WHERE user_id = $1 AND account_id = $2
    `,
    [userId, accountId],
    { type: QueryTypes.SELECT }
  );

  const recentExpenses = await query(
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
      WHERE e.user_id = $1 AND e.account_id = $2
      ORDER BY e.spent_on DESC, e.id DESC
      LIMIT 10
    `,
    [userId, accountId],
    { type: QueryTypes.SELECT }
  );

  const recentIncomes = await query(
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
      WHERE i.user_id = $1 AND i.account_id = $2
      ORDER BY i.received_on DESC, i.id DESC
      LIMIT 10
    `,
    [userId, accountId],
    { type: QueryTypes.SELECT }
  );

  return {
    account,
    summary: {
      totalIncome: Number(incomeTotals[0].total),
      incomeCount: incomeTotals[0].item_count,
      totalExpenses: Number(expenseTotals[0].total),
      expenseCount: expenseTotals[0].item_count,
      currentBalance: account.currentBalance
    },
    recentExpenses: recentExpenses.map(normalizeExpense),
    recentIncomes: recentIncomes.map(normalizeIncome)
  };
}

export async function getAccountExpenses(userId, accountId, filters = {}) {
  const conditions = [];
  const values = [];
  const limit = normalizeListLimit(filters.limit);

  values.push(userId);
  conditions.push(`e.user_id = $${values.length}`);

  values.push(accountId);
  conditions.push(`e.account_id = $${values.length}`);

  if (filters.categoryId) {
    values.push(filters.categoryId);
    conditions.push(`e.category_id = $${values.length}`);
  }

  if (filters.from) {
    const fromDate = parseProjectDateToIso(filters.from);
    if (fromDate) {
      values.push(fromDate);
      conditions.push(`e.spent_on >= $${values.length}`);
    }
  }

  if (filters.to) {
    const toDate = parseProjectDateToIso(filters.to);
    if (toDate) {
      values.push(toDate);
      conditions.push(`e.spent_on <= $${values.length}`);
    }
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

export async function getAccountIncomes(userId, accountId, filters = {}) {
  const conditions = [];
  const values = [];
  const limit = normalizeListLimit(filters.limit);

  values.push(userId);
  conditions.push(`i.user_id = $${values.length}`);

  values.push(accountId);
  conditions.push(`i.account_id = $${values.length}`);

  if (filters.categoryId) {
    values.push(filters.categoryId);
    conditions.push(`i.category_id = $${values.length}`);
  }

  if (filters.from) {
    const fromDate = parseProjectDateToIso(filters.from);
    if (fromDate) {
      values.push(fromDate);
      conditions.push(`i.received_on >= $${values.length}`);
    }
  }

  if (filters.to) {
    const toDate = parseProjectDateToIso(filters.to);
    if (toDate) {
      values.push(toDate);
      conditions.push(`i.received_on <= $${values.length}`);
    }
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

export async function transferBetweenAccounts(
  userId,
  { fromAccountId, toAccountId, amount, notes = "" }
) {
  if (fromAccountId === toAccountId) {
    throw new Error("Cannot transfer to the same account");
  }

  if (amount <= 0) {
    throw new Error("Transfer amount must be positive");
  }

  const fromAccount = await getAccountById(userId, fromAccountId);
  const toAccount = await getAccountById(userId, toAccountId);

  if (!fromAccount) {
    throw new Error("Source account not found");
  }
  if (!toAccount) {
    throw new Error("Destination account not found");
  }

  const result = await query(
    `
      INSERT INTO transfers (user_id, from_account_id, to_account_id, amount, notes)
      VALUES ($1, $2, $3, $4, $5)
      RETURNING id, from_account_id, to_account_id, amount, notes, created_at
    `,
    [userId, fromAccountId, toAccountId, amount, notes]
  );

  const transfer = result[0];

  return {
    id: transfer.id,
    fromAccountId: transfer.from_account_id,
    fromAccountName: fromAccount.name,
    toAccountId: transfer.to_account_id,
    toAccountName: toAccount.name,
    amount: Number(transfer.amount),
    notes: transfer.notes,
    createdAt: transfer.created_at
  };
}

export async function listTransfers(userId, filters = {}) {
  const conditions = [];
  const values = [];

  values.push(userId);
  conditions.push(`t.user_id = $${values.length}`);

  if (filters.accountId) {
    values.push(filters.accountId);
    conditions.push(`(t.from_account_id = $${values.length} OR t.to_account_id = $${values.length})`);
  }

  if (filters.from) {
    const fromDate = parseProjectDateToIso(filters.from);
    if (fromDate) {
      values.push(fromDate);
      conditions.push(`DATE(t.created_at) >= $${values.length}`);
    }
  }

  if (filters.to) {
    const toDate = parseProjectDateToIso(filters.to);
    if (toDate) {
      values.push(toDate);
      conditions.push(`DATE(t.created_at) <= $${values.length}`);
    }
  }

  const whereClause = conditions.length ? `WHERE ${conditions.join(" AND ")}` : "";
  const limit = normalizeListLimit(filters.limit);

  const rows = await query(
    `
      SELECT
        t.id,
        t.from_account_id,
        fa.name AS from_account_name,
        t.to_account_id,
        ta.name AS to_account_name,
        t.amount,
        t.notes,
        t.created_at
      FROM transfers t
      JOIN accounts fa ON fa.id = t.from_account_id
      JOIN accounts ta ON ta.id = t.to_account_id
      ${whereClause}
      ORDER BY t.created_at DESC, t.id DESC
      ${limit ? `LIMIT $${values.length + 1}` : ""}
    `,
    limit ? [...values, limit] : values,
    { type: QueryTypes.SELECT }
  );

  return rows.map(row => ({
    id: row.id,
    fromAccountId: row.from_account_id,
    fromAccountName: row.from_account_name,
    toAccountId: row.to_account_id,
    toAccountName: row.to_account_name,
    amount: Number(row.amount),
    notes: row.notes,
    createdAt: row.created_at
  }));
}
