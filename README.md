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

## Flutter Web + CORS

When running the Flutter app in a browser, the API must allow your web app origin via CORS.

Set `CORS_ORIGINS` (comma-separated) in `.env` to include your Flutter web origin(s), for example:

```env
CORS_ORIGINS=http://localhost:5173,https://app.yourdomain.com
```

Preflight requests (`OPTIONS`) are handled by the API automatically.

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

- `GET /health` (same JSON at `GET /api/health`)
- `GET /api/finance/dashboard?month=2026-04`
- `GET /api/finance/summary?month=2026-04`
- `GET /api/finance/categories`
- `POST /api/finance/categories`
- `GET /api/finance/expenses`
- `POST /api/finance/expenses`
- `GET /api/finance/incomes`
- `POST /api/finance/incomes`
- `GET /api/finance/budgets`
- `POST /api/finance/budgets`
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

## Google Cloud Run + Neon

You can run the Node API on [Cloud Run](https://cloud.google.com/run) and keep PostgreSQL on [Neon](https://neon.tech). The repo includes a root [`Dockerfile`](Dockerfile) that copies [`src/`](src/) and runs `npm run start` as a non-root user. Cloud Run sets `PORT` automatically; the app reads it in [`src/app.js`](src/app.js).

### Prerequisites

- [Google Cloud SDK](https://cloud.google.com/sdk/docs/install) (`gcloud`) and a project with billing enabled.
- APIs used by source-based deploys: Cloud Run and Cloud Build (Artifact Registry is used implicitly for staging images when you deploy from source).

### Deploy from the repo root

Replace placeholders with your project ID, region, and service name:

```bash
gcloud config set project YOUR_GCP_PROJECT_ID

gcloud run deploy YOUR_SERVICE_NAME \
  --source . \
  --region YOUR_REGION \
  --allow-unauthenticated \
  --set-secrets DATABASE_URL=neon-database-url:latest,AUTH_SECRET=auth-secret:latest \
  --set-env-vars "APP_BASE_URL=https://YOUR_SERVICE_NAME-XXXX.a.run.app,CORS_ALLOW_ALL=false,GEMINI_MODEL=gemini-2.5-flash"
```

- Use `--no-allow-unauthenticated` if you only want authenticated callers (IAM).
- Store sensitive values in [Secret Manager](https://cloud.google.com/secret-manager) and reference them with `--set-secrets` (`ENV_VAR=secret-name:version`).
- Point `DATABASE_URL` at Neon’s connection string; prefer Neon’s **pooled** / pooler endpoint so many Cloud Run instances do not exhaust database connections.
- Set `APP_BASE_URL` to your service URL (or custom domain) so auth and email links match production.
- Set `CORS_ORIGINS` (comma-separated) for browser clients; keep `CORS_ALLOW_ALL=false` in production. See [`.env.example`](.env.example) for the full set of variables (`GEMINI_*`, `MISTRAL_*`, `OPENROUTER_*`, mail, RAG, etc.).

### One-time database setup

Run against Neon from your machine or CI (not as part of the container startup unless you add a job):

```bash
DATABASE_URL='postgresql://...neon...' npm run db:init
```

Run other migration scripts from [`.env.example`](.env.example) / `package.json` as needed for your environment.

### Local image build (optional)

The image sets **`PORT=8080`** by default so `docker run -p 8080:8080` matches the process inside the container. If your `--env-file` sets `PORT` (for example to `3000`), map the host port to that value instead, e.g. `-p 8080:3000`.

```bash
docker build -t finance-api:local .
docker run --rm -p 8080:8080 --env-file .env finance-api:local
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
