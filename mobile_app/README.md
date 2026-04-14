# Finance Mobile App

Flutter MCP client for the hosted personal finance backend.

## What It Does

- Connects to the backend MCP endpoint at `/mcp`
- Loads a finance dashboard with income, expenses, categories, and budgets
- Creates expenses, incomes, budgets, and categories through MCP tools
- Includes a chat tab backed by `/api/chat`

## Required Backend Features

Before running the app, redeploy your backend so it includes:

- the finance REST API
- the `/mcp` endpoint
- the `/api/chat` endpoint

Quick checks:

- `https://demo-mcp-l0rq.onrender.com/health`
- `https://demo-mcp-l0rq.onrender.com/mcp`

`GET /mcp` should return `405 Method not allowed`.

## Backend Environment Variables

For the chat tab:

- `GEMINI_API_KEY`
- `GEMINI_MODEL=gemini-2.5-flash`

## Run

```bash
cd mobile_app
flutter pub get
flutter run --dart-define=API_BASE_URL=https://demo-mcp-l0rq.onrender.com
```

## Main Files

- `lib/src/api/finance_mcp_client.dart`
- `lib/src/api/chat_api.dart`
- `lib/src/models/finance_models.dart`
- `lib/src/screens/home_screen.dart`
- `lib/src/screens/chat_screen.dart`

## MCP Tools Used by the App

- `finance_dashboard`
- `list_categories`
- `create_category`
- `create_expense`
- `create_income`
- `create_budget`
