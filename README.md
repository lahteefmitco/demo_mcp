# Personal Finance Manager with MCP

This project includes:

- An Express.js API for categories, expenses, incomes, and budgets
- PostgreSQL with Sequelize raw SQL queries
- MCP servers over `stdio` and remote HTTP
- A Flutter mobile client
- A Gemini-powered chat endpoint that can use finance tools

## Features

- Manage expense and income categories
- Track expenses and incomes
- Create budgets for `daily`, `weekly`, `monthly`, and `yearly` periods
- View finance dashboard totals for a month
- Access the same finance data from REST, MCP, and chat

## Project Structure

```text
src/
  app.js
  db.js
  schema.sql
  routes/finance.js
  services/finance-service.js
  services/chat-service.js
  scripts/init-db.js
  mcp/create-server.js
  mcp/server.js

mobile_app/
  lib/
```

## Environment

Copy the example file:

```bash
cp .env.example .env
```

Example values:

```env
PORT=3000
DATABASE_URL=postgresql://postgres:your_password@localhost:5432/expense_manager
GEMINI_API_KEY=your_gemini_api_key
GEMINI_MODEL=gemini-2.5-flash
```

## Initialize the Database

```bash
npm install
npm run db:init
```

Important:

- `db:init` recreates the finance schema
- it is intended for a fresh demo environment
- rerunning it will reset old local data

## Run the API

```bash
npm run dev
```

Useful endpoints:

- `GET /health`
- `GET /api/dashboard?month=2026-04`
- `GET /api/summary?month=2026-04`
- `GET /api/categories`
- `POST /api/categories`
- `GET /api/expenses`
- `POST /api/expenses`
- `GET /api/incomes`
- `POST /api/incomes`
- `GET /api/budgets`
- `POST /api/budgets`
- `POST /api/chat`
- `POST /mcp`

## MCP

Local stdio MCP server:

```bash
npm run mcp
```

Remote MCP endpoint:

```text
POST /mcp
```

Main MCP tools:

- `finance_dashboard`
- `period_summary`
- `list_categories`
- `create_category`
- `list_expenses`
- `create_expense`
- `list_incomes`
- `create_income`
- `list_budgets`
- `create_budget`

## Render + Neon

Recommended production setup:

- Render for the Node app
- Neon for PostgreSQL

Render environment variables:

- `DATABASE_URL`
- `GEMINI_API_KEY`
- `GEMINI_MODEL=gemini-2.5-flash`

After deploying, initialize the schema once against Neon:

```bash
npm run db:init
```

## Flutter App

The Flutter client lives in [mobile_app](/Users/mictco/Desktop/demo_mcp/mobile_app).

Run it with:

```bash
cd mobile_app
flutter pub get
flutter run --dart-define=API_BASE_URL=https://your-render-url.onrender.com
```

The app supports:

- finance dashboard
- add expense
- add income
- add budget
- add category
- chat assistant

## Chat

`POST /api/chat` uses Gemini with `gemini-2.5-flash` by default and gives the model access to your finance tools.

This lets the mobile chat tab handle prompts like:

- "Add an income of 5000 for freelance today"
- "Create a monthly food budget of 300"
- "Show my balance for this month"
