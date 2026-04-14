# Personal Finance Manager with MCP

This project includes:

- An Express.js API for categories, expenses, incomes, and budgets
- PostgreSQL with Sequelize raw SQL queries
- MCP servers over `stdio` and remote HTTP
- A Flutter mobile client
- A LangChain-powered AI assistant with MCP tools, RAG, pgvector memory, and multi-LLM routing

## Features

- Manage expense and income categories
- Track expenses and incomes
- Create budgets for `daily`, `weekly`, `monthly`, and `yearly` periods
- View finance dashboard totals for a month
- Access the same finance data from REST, MCP, and chat
- Run semantic search over expenses, incomes, categories, and prior AI conversations
- Detect overspending, anomalies, and month-over-month trends
- Switch chat and embedding providers between Gemini, Mistral, and OpenRouter

## Project Structure

```text
src/
  app.js
  ai/
    agent/
    insights/
    llm/providers/
    memory/
    vector/
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
GEMINI_EMBEDDING_MODEL=text-embedding-004
AI_PROVIDER=gemini
EMBEDDING_PROVIDER=gemini
EMBEDDING_DIMENSIONS=768
```

## Initialize the Database

```bash
npm install
npm run db:init
npm run db:migrate-ai
npm run ai:reindex
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

The AI layer keeps MCP as the tool boundary. LangChain wraps the MCP tool catalog rather than calling finance persistence directly.

## AI Architecture

```text
User chat
  -> LangChain agent
     -> MCP-backed finance tools
     -> pgvector semantic retriever
     -> financial insights service
  -> response + vector memory write
```

Folder structure:

```text
src/ai/
  agent/
    finance-agent.js
    json-schema-to-zod.js
    mcp-langchain-tools.js
  insights/
    finance-insights-service.js
  llm/
    provider-factory.js
    providers/
      gemini.provider.js
      mistral.provider.js
      openrouter.provider.js
      generic.provider.js
  memory/
    conversation-memory.js
  vector/
    document-store.js
    finance-document-sync.js
    finance-retriever.js
    pgvector-utils.js
```

## pgvector Schema

`npm run db:migrate-ai` creates:

- `ai_documents`
- `vector` and `pgcrypto` extensions
- metadata and user/type indexes
- HNSW similarity index with IVFFLAT fallback

Embedded document types:

- `expense`
- `income`
- `category`
- `query_memory`

## Multi-LLM

Provider selection is environment-driven:

- `AI_PROVIDER=gemini|mistral|openrouter`
- `EMBEDDING_PROVIDER=gemini|mistral|openrouter|generic`

OpenRouter can be used for model routing. Generic embeddings can target any OpenAI-compatible embedding endpoint.

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

`POST /api/chat` uses LangChain as the orchestration layer and gives the selected model access to:

- the existing MCP finance tools
- semantic retrieval over pgvector
- overspending and anomaly insight generation
- long-term vector memory of prior finance chats

This lets the mobile chat tab handle prompts like:

- "Add an income of 5000 for freelance today"
- "Create a monthly food budget of 300"
- "Show my balance for this month"
- "Where am I overspending?"
- "Show unusual expenses"
- "Compare this month with last month"
