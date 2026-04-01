import dotenv from "dotenv";
import express from "express";
import expensesRouter from "./routes/expenses.js";

dotenv.config({ quiet: true });

const app = express();
const port = Number(process.env.PORT || 3000);

app.use(express.json());

app.get("/", (_req, res) => {
  res.json({ message: "Welcome to the Expense Manager API" });
});

app.get("/health", (_req, res) => {
  res.json({ ok: true, service: "expense-manager-api" });
});

app.use("/api/expenses", expensesRouter);

app.use((error, _req, res, _next) => {
  console.error(error);
  res.status(500).json({
    error: "Internal server error",
    details: error.message
  });
});

app.listen(port, () => {
  console.log(`Expense manager API listening on http://localhost:${port}`);
});
