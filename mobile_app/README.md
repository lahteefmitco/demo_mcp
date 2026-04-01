# Expense Mobile App

Flutter client for the hosted expense manager API.

## What It Does

- Loads dashboard data from `/api/expenses/bootstrap`
- Lists recent expenses from `/api/expenses`
- Creates new expenses with `POST /api/expenses`

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

To override the API URL:

```bash
flutter run --dart-define=API_BASE_URL=https://demo-mcp-l0rq.onrender.com
```

## Main Files

- `lib/src/api/expense_api.dart`
- `lib/src/screens/home_screen.dart`
- `lib/src/screens/add_expense_screen.dart`

## Verify the Backend First

Check these endpoints in your browser or Postman:

- `https://demo-mcp-l0rq.onrender.com/health`
- `https://demo-mcp-l0rq.onrender.com/api/expenses`
- `https://demo-mcp-l0rq.onrender.com/api/expenses/bootstrap?month=2026-04`
