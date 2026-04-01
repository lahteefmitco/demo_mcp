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

## Notes

- Claude Desktop must be able to find `node` on your machine if you use the `node` command directly.
- The MCP server and the API both require PostgreSQL to be running.
- If Claude Desktop does not load the server, check its logs and verify the absolute paths in the config.
