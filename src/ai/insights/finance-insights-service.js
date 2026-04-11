import { QueryTypes, query } from "../../db.js";
import { getPeriodSummary } from "../../services/finance-service.js";

export async function getFinancialInsights(userId, month) {
  const [yearText, monthText] = String(month).split("-");
  const year = Number(yearText);
  const monthIndex = Number(monthText);

  if (!year || !monthIndex) {
    throw new Error("month must be in YYYY-MM format");
  }

  const currentDate = new Date(Date.UTC(year, monthIndex - 1, 1));
  const previousDate = new Date(Date.UTC(year, monthIndex - 2, 1));
  const previousMonth = `${previousDate.getUTCFullYear()}-${String(previousDate.getUTCMonth() + 1).padStart(2, "0")}`;

  const [currentSummary, previousSummary, categoryTrends, anomalies] = await Promise.all([
    getPeriodSummary(userId, month),
    getPeriodSummary(userId, previousMonth),
    getCategoryTrends(userId, currentDate),
    getExpenseAnomalies(userId, currentDate)
  ]);

  const expenseDelta = currentSummary.expenseTotal - previousSummary.expenseTotal;
  const incomeDelta = currentSummary.incomeTotal - previousSummary.incomeTotal;
  const balanceDelta = currentSummary.balance - previousSummary.balance;

  return {
    month,
    comparisonMonth: previousMonth,
    totals: {
      current: currentSummary,
      previous: previousSummary,
      deltas: {
        expenses: expenseDelta,
        income: incomeDelta,
        balance: balanceDelta
      }
    },
    trends: {
      expenseDirection: expenseDelta > 0 ? "increase" : expenseDelta < 0 ? "decrease" : "flat",
      incomeDirection: incomeDelta > 0 ? "increase" : incomeDelta < 0 ? "decrease" : "flat",
      balanceDirection: balanceDelta > 0 ? "increase" : balanceDelta < 0 ? "decrease" : "flat",
      topCategoryMovers: categoryTrends
    },
    anomalies,
    summary: summarizeInsights({
      expenseDelta,
      incomeDelta,
      balanceDelta,
      categoryTrends,
      anomalies
    })
  };
}

async function getCategoryTrends(userId, currentDate) {
  const rows = await query(
    `
      WITH monthly AS (
        SELECT
          c.name AS category_name,
          date_trunc('month', e.spent_on)::date AS month_bucket,
          SUM(e.amount)::numeric(12, 2) AS total_amount
        FROM expenses e
        JOIN categories c
          ON c.id = e.category_id
         AND c.user_id = e.user_id
        WHERE e.user_id = $1
          AND date_trunc('month', e.spent_on) IN (
            date_trunc('month', $2::date),
            date_trunc('month', $2::date - INTERVAL '1 month')
          )
        GROUP BY c.name, date_trunc('month', e.spent_on)
      )
      SELECT
        category_name,
        COALESCE(MAX(total_amount) FILTER (WHERE month_bucket = date_trunc('month', $2::date)), 0) AS current_total,
        COALESCE(MAX(total_amount) FILTER (WHERE month_bucket = date_trunc('month', $2::date - INTERVAL '1 month')), 0) AS previous_total
      FROM monthly
      GROUP BY category_name
      ORDER BY (COALESCE(MAX(total_amount) FILTER (WHERE month_bucket = date_trunc('month', $2::date)), 0)
        - COALESCE(MAX(total_amount) FILTER (WHERE month_bucket = date_trunc('month', $2::date - INTERVAL '1 month')), 0)) DESC
      LIMIT 5
    `,
    [userId, currentDate.toISOString().slice(0, 10)],
    { type: QueryTypes.SELECT }
  );

  return rows.map((row) => ({
    categoryName: row.category_name,
    currentTotal: Number(row.current_total),
    previousTotal: Number(row.previous_total),
    delta: Number(row.current_total) - Number(row.previous_total)
  }));
}

async function getExpenseAnomalies(userId, currentDate) {
  const rows = await query(
    `
      SELECT
        e.id,
        e.title,
        e.amount,
        e.spent_on,
        c.name AS category_name,
        COALESCE(AVG(prev.amount), 0)::numeric(12, 2) AS category_average,
        CASE
          WHEN COALESCE(AVG(prev.amount), 0) = 0 THEN NULL
          ELSE ROUND((e.amount / AVG(prev.amount))::numeric, 2)
        END AS ratio_to_average
      FROM expenses e
      JOIN categories c
        ON c.id = e.category_id
       AND c.user_id = e.user_id
      LEFT JOIN expenses prev
        ON prev.user_id = e.user_id
       AND prev.category_id = e.category_id
       AND prev.spent_on < e.spent_on
       AND prev.spent_on >= e.spent_on - INTERVAL '90 day'
      WHERE e.user_id = $1
        AND date_trunc('month', e.spent_on) = date_trunc('month', $2::date)
      GROUP BY e.id, e.title, e.amount, e.spent_on, c.name
      HAVING e.amount >= GREATEST(COALESCE(AVG(prev.amount) * 2, 0), 50)
      ORDER BY ratio_to_average DESC NULLS LAST, e.amount DESC
      LIMIT 5
    `,
    [userId, currentDate.toISOString().slice(0, 10)],
    { type: QueryTypes.SELECT }
  );

  return rows.map((row) => ({
    id: row.id,
    title: row.title,
    amount: Number(row.amount),
    spentOn: row.spent_on,
    categoryName: row.category_name,
    categoryAverage: Number(row.category_average),
    ratioToAverage: row.ratio_to_average == null ? null : Number(row.ratio_to_average)
  }));
}

function summarizeInsights({ expenseDelta, incomeDelta, balanceDelta, categoryTrends, anomalies }) {
  const summary = [];

  if (expenseDelta > 0) {
    summary.push(`Expenses increased by ${expenseDelta.toFixed(2)} compared with last month.`);
  } else if (expenseDelta < 0) {
    summary.push(`Expenses decreased by ${Math.abs(expenseDelta).toFixed(2)} compared with last month.`);
  } else {
    summary.push("Expenses are flat compared with last month.");
  }

  if (incomeDelta > 0) {
    summary.push(`Income increased by ${incomeDelta.toFixed(2)}.`);
  } else if (incomeDelta < 0) {
    summary.push(`Income decreased by ${Math.abs(incomeDelta).toFixed(2)}.`);
  }

  if (balanceDelta !== 0) {
    summary.push(`Net balance moved by ${balanceDelta.toFixed(2)}.`);
  }

  if (categoryTrends[0]) {
    summary.push(
      `${categoryTrends[0].categoryName} is the biggest spending mover at ${categoryTrends[0].delta.toFixed(2)}.`
    );
  }

  if (anomalies.length > 0) {
    summary.push(`${anomalies.length} unusual expenses were detected this month.`);
  }

  return summary.join(" ");
}
