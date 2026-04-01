# Personal Expense Manager with MCP

This project includes:

- An Express.js REST API for managing personal expenses
- PostgreSQL persistence with Sequelize
- A sample MCP server that exposes expense tools over stdio
- Claude Desktop connection instructions

## Features

- Create, list, update, and delete expenses
- Filter expenses by category or date range
- Monthly summary grouped by category
- Reuse the same PostgreSQL database from both the API and the MCP server
- Use Sequelize as the ORM while executing raw SQL queries

## Project Structure

```text
src/
  app.js
  db.js
  schema.sql
  routes/expenses.js
  services/expense-service.js
  scripts/init-db.js
  mcp/server.js
```

## 1. Install Dependencies

```bash
npm install
```

## 2. Start PostgreSQL

The quickest option is Docker Compose:

```bash
docker compose up -d
```

You can also create the database manually with `psql` if PostgreSQL is already installed locally.

## 3. Create PostgreSQL Database

Example using `psql`:

```bash
createdb expense_manager
```

Copy the env file and update it if needed:

```bash
cp .env.example .env
```

Example `.env`:

```env
PORT=3000
DATABASE_URL=postgresql://postgres:postgres@localhost:5432/expense_manager
```

Initialize the database schema:

```bash
npm run db:init
```

## 4. Run the Express API

```bash
npm run dev
```

Available endpoints:

- `GET /health`
- `GET /api/expenses`
- `GET /api/expenses?category=Food&from=2026-04-01&to=2026-04-30`
- `GET /api/expenses/summary?month=2026-04`
- `GET /api/expenses/:id`
- `POST /api/expenses`
- `PUT /api/expenses/:id`
- `DELETE /api/expenses/:id`

Example create request:

```bash
curl -X POST http://localhost:3000/api/expenses \
  -H "Content-Type: application/json" \
  -d '{
    "title": "Groceries",
    "amount": 42.50,
    "category": "Food",
    "spentOn": "2026-04-01",
    "notes": "Weekly shopping"
  }'
```

## 5. Run the MCP Server

The MCP server uses stdio, which is the easiest way to connect from Claude Desktop:

```bash
npm run mcp
```

It exposes these tools:

- `list_expenses`
- `create_expense`
- `monthly_summary`

## 6. Connect to Claude Desktop

Claude Desktop reads MCP server definitions from its config file.

On macOS, open:

```text
~/Library/Application Support/Claude/claude_desktop_config.json
```

Add a server entry like this and replace the paths with your local values:

```json
{
  "mcpServers": {
    "expense-manager": {
      "command": "node",
      "args": [
        "/Users/mictco/Desktop/demo_mcp/src/mcp/server.js"
      ],
      "env": {
        "DATABASE_URL": "postgresql://postgres:postgres@localhost:5432/expense_manager"
      }
    }
  }
}
```

If you prefer to launch through npm:

```json
{
  "mcpServers": {
    "expense-manager": {
      "command": "npm",
      "args": [
        "run",
        "mcp"
      ],
      "cwd": "/Users/mictco/Desktop/demo_mcp",
      "env": {
        "DATABASE_URL": "postgresql://postgres:postgres@localhost:5432/expense_manager"
      }
    }
  }
}
```

After saving the file:

1. Quit Claude Desktop completely
2. Reopen Claude Desktop
3. Start a new chat
4. Confirm the `expense-manager` MCP server is available

## 7. Deploy to Render with Neon

This project is a good fit for:

- Render for hosting the Express API
- Neon for hosting PostgreSQL
- Claude Desktop connecting to the MCP server locally on your machine

### Architecture

- Render hosts the Express API from [src/app.js](/Users/mictco/Desktop/demo_mcp/src/app.js)
- Neon hosts the PostgreSQL database
- Claude Desktop connects to the local MCP server from [src/mcp/server.js](/Users/mictco/Desktop/demo_mcp/src/mcp/server.js)

Hosting the Express API on Render does not replace the local MCP server. Claude Desktop still talks to the MCP server over local stdio.

### 1. Prepare Neon

1. Create a Neon project
2. Copy the pooled connection string from the Neon dashboard
3. Prefer `sslmode=verify-full` for production-style usage

Example:

```env
DATABASE_URL=postgresql://neondb_owner:YOUR_PASSWORD@ep-example-pooler.us-east-1.aws.neon.tech/neondb?sslmode=verify-full&channel_binding=require
```

If you exposed your Neon password anywhere, rotate it before deploying.

### 2. Push the Project to GitHub

Render deploys this app cleanly from a GitHub repository, so push the full project first.

### 3. Create a Render Web Service

In Render:

1. Create a new `Web Service`
2. Select your GitHub repository
3. Use these settings:

- Environment: `Node`
- Build Command: `npm install`
- Start Command: `npm start`

Render will provide the `PORT` environment variable automatically. This app already reads `PORT`, so no code changes are required for that.

### 4. Add Environment Variables in Render

Set this environment variable in the Render dashboard:

```env
DATABASE_URL=postgresql://neondb_owner:YOUR_PASSWORD@ep-example-pooler.us-east-1.aws.neon.tech/neondb?sslmode=verify-full&channel_binding=require
```

You do not usually need to set `PORT` manually on Render.

### 5. Initialize the Database Schema

Render will deploy the API, but it will not automatically create your tables unless you run the schema initialization step.

Run this once against your Neon database:

```bash
npm run db:init
```

You can run it locally as long as your local `.env` points to the same Neon `DATABASE_URL`.

### 6. Verify the Deployment

After Render finishes deploying, open:

- `https://YOUR-RENDER-SERVICE.onrender.com/`
- `https://YOUR-RENDER-SERVICE.onrender.com/health`
- `https://YOUR-RENDER-SERVICE.onrender.com/api/expenses`

Expected responses:

- `/` returns a welcome JSON message
- `/health` returns API health status
- `/api/expenses` returns your stored expense records

### 7. Connect Claude Desktop to the Same Neon Database

Keep the MCP server local on your Mac, but point it to the Neon database.

Example Claude Desktop config on macOS:

```json
{
  "mcpServers": {
    "expense-manager": {
      "command": "/opt/homebrew/bin/node",
      "args": [
        "/Users/mictco/Desktop/demo_mcp/src/mcp/server.js"
      ],
      "env": {
        "DATABASE_URL": "postgresql://neondb_owner:YOUR_PASSWORD@ep-example-pooler.us-east-1.aws.neon.tech/neondb?sslmode=verify-full&channel_binding=require"
      }
    }
  }
}
```

This lets:

- Render use Neon for the hosted API
- Claude Desktop use the same Neon database through your local MCP server

### Production Notes

- Use the Neon pooled connection string for hosted environments
- Keep secrets only in `.env` locally and Render environment variables in production
- Do not commit live credentials to Git
- Rotate credentials if they were ever shared
- Run `npm run db:init` whenever you need to initialize a fresh database
- If you later add migrations, use migrations instead of running the full schema file repeatedly

## Notes

- Claude Desktop must be able to find `node` on your machine if you use the `node` command directly.
- The MCP server and the API both require PostgreSQL to be running.
- If Claude Desktop does not load the server, check its logs and verify the absolute paths in the config.
