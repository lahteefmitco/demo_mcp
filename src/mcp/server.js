import dotenv from "dotenv";
import { Server } from "@modelcontextprotocol/sdk/server/index.js";
import { StdioServerTransport } from "@modelcontextprotocol/sdk/server/stdio.js";
import {
  CallToolRequestSchema,
  ListToolsRequestSchema
} from "@modelcontextprotocol/sdk/types.js";
import {
  createExpense,
  getMonthlySummary,
  listExpenses
} from "../services/expense-service.js";

dotenv.config({ quiet: true });

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
      description: "List expenses with optional category and date filters.",
      inputSchema: {
        type: "object",
        properties: {
          category: { type: "string", description: "Optional category filter." },
          from: { type: "string", description: "Optional start date in YYYY-MM-DD." },
          to: { type: "string", description: "Optional end date in YYYY-MM-DD." }
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
    }
  ]
}));

server.setRequestHandler(CallToolRequestSchema, async (request) => {
  const { name, arguments: args = {} } = request.params;

  if (name === "list_expenses") {
    const expenses = await listExpenses(args);
    return {
      content: [
        {
          type: "text",
          text: JSON.stringify(expenses, null, 2)
        }
      ]
    };
  }

  if (name === "create_expense") {
    const expense = await createExpense({
      title: args.title,
      amount: args.amount,
      category: args.category,
      spentOn: args.spentOn,
      notes: args.notes ?? ""
    });

    return {
      content: [
        {
          type: "text",
          text: JSON.stringify(expense, null, 2)
        }
      ]
    };
  }

  if (name === "monthly_summary") {
    const summary = await getMonthlySummary(args.month);
    return {
      content: [
        {
          type: "text",
          text: JSON.stringify(summary, null, 2)
        }
      ]
    };
  }

  throw new Error(`Unknown tool: ${name}`);
});

async function main() {
  const transport = new StdioServerTransport();
  await server.connect(transport);
}

main().catch((error) => {
  console.error("MCP server failed to start.");
  console.error(error);
  process.exit(1);
});
