import { Server } from "@modelcontextprotocol/sdk/server/index.js";
import {
  CallToolRequestSchema,
  ListToolsRequestSchema
} from "@modelcontextprotocol/sdk/types.js";
import {
  createExpense,
  getMobileBootstrap,
  getMonthlySummary,
  listCategories,
  listExpenses
} from "../services/expense-service.js";

export function createExpenseManagerServer() {
  const server = new Server(
    {
      name: "expense-manager-mcp",
      version: "1.0.0"
    },
    {
      capabilities: {
        tools: {}
      }
    }
  );

  server.setRequestHandler(ListToolsRequestSchema, async () => ({
    tools: [
      {
        name: "list_expenses",
        description: "List expenses with optional category, date, and limit filters.",
        inputSchema: {
          type: "object",
          properties: {
            category: { type: "string", description: "Optional category filter." },
            from: { type: "string", description: "Optional start date in YYYY-MM-DD." },
            to: { type: "string", description: "Optional end date in YYYY-MM-DD." },
            limit: { type: "number", description: "Optional result limit." }
          }
        }
      },
      {
        name: "create_expense",
        description: "Create a new expense record.",
        inputSchema: {
          type: "object",
          required: ["title", "amount", "category", "spentOn"],
          properties: {
            title: { type: "string" },
            amount: { type: "number" },
            category: { type: "string" },
            spentOn: { type: "string", description: "Date in YYYY-MM-DD." },
            notes: { type: "string" }
          }
        }
      },
      {
        name: "monthly_summary",
        description: "Get monthly expense summary grouped by category.",
        inputSchema: {
          type: "object",
          required: ["month"],
          properties: {
            month: { type: "string", description: "Month in YYYY-MM format." }
          }
        }
      },
      {
        name: "list_categories",
        description: "List all known expense categories.",
        inputSchema: {
          type: "object",
          properties: {}
        }
      },
      {
        name: "dashboard_snapshot",
        description: "Get dashboard data with monthly summary, categories, and recent expenses.",
        inputSchema: {
          type: "object",
          required: ["month"],
          properties: {
            month: { type: "string", description: "Month in YYYY-MM format." }
          }
        }
      }
    ]
  }));

  server.setRequestHandler(CallToolRequestSchema, async (request) => {
    const { name, arguments: args = {} } = request.params;

    if (name === "list_expenses") {
      const expenses = await listExpenses(args);
      return jsonText(expenses);
    }

    if (name === "create_expense") {
      const expense = await createExpense({
        title: args.title,
        amount: args.amount,
        category: args.category,
        spentOn: args.spentOn,
        notes: args.notes ?? ""
      });

      return jsonText(expense);
    }

    if (name === "monthly_summary") {
      const summary = await getMonthlySummary(args.month);
      return jsonText(summary);
    }

    if (name === "list_categories") {
      const categories = await listCategories();
      return jsonText(categories);
    }

    if (name === "dashboard_snapshot") {
      const dashboard = await getMobileBootstrap(args.month);
      return jsonText(dashboard);
    }

    throw new Error(`Unknown tool: ${name}`);
  });

  return server;
}

function jsonText(value) {
  return {
    content: [
      {
        type: "text",
        text: JSON.stringify(value, null, 2)
      }
    ]
  };
}
