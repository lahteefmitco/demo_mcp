# Expense Mobile App

Flutter MCP client for the hosted expense manager backend.

## What It Does

- Initializes a remote MCP session against `/mcp`
- Lists available MCP tools
- Loads dashboard data through the `dashboard_snapshot` tool
- Lists expenses through the `list_expenses` tool
- Creates expenses through the `create_expense` tool

## Important

Before running the mobile app, redeploy your backend so Render includes the new `/mcp` endpoint.

After redeploy, verify:

- `https://demo-mcp-l0rq.onrender.com/health`
- `https://demo-mcp-l0rq.onrender.com/mcp`

`GET /mcp` should return `405 Method not allowed`, which confirms the MCP route exists.

## Default API Base URL

The app defaults to:

```text
https://demo-mcp-l0rq.onrender.com
```

You can override it at runtime with `--dart-define`.

## Run the App

```bash
cd mobile_app
flutter pub get
flutter run
```

To override the backend URL:

```bash
flutter run --dart-define=API_BASE_URL=https://demo-mcp-l0rq.onrender.com
```

## Main Files

- `lib/src/api/expense_mcp_client.dart`
- `lib/src/screens/home_screen.dart`
- `lib/src/screens/add_expense_screen.dart`

## MCP Tools Used by the App

- `dashboard_snapshot`
- `list_expenses`
- `create_expense`
- `list_categories`
