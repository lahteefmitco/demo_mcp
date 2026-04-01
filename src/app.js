import dotenv from "dotenv";
import express from "express";
import { StreamableHTTPServerTransport } from "@modelcontextprotocol/sdk/server/streamableHttp.js";
import { createExpenseManagerServer } from "./mcp/create-server.js";
import { runExpenseChat } from "./services/chat-service.js";
import expensesRouter from "./routes/expenses.js";

dotenv.config({ quiet: true });

const app = express();
const port = Number(process.env.PORT || 3000);

app.use(express.json());

app.get("/", (_req, res) => {
  res.json({ message: "Welcome to the Expense Manager API" });
});

app.get("/health", (_req, res) => {
  res.json({ ok: true, service: "expense-manager-api" });
});

app.post("/api/chat", async (req, res, next) => {
  try {
    const result = await runExpenseChat(req.body.messages);
    res.json(result);
  } catch (error) {
    next(error);
  }
});

app.post("/mcp", async (req, res) => {
  const server = createExpenseManagerServer();
  const transport = new StreamableHTTPServerTransport({
    sessionIdGenerator: undefined
  });

  try {
    await server.connect(transport);
    await transport.handleRequest(req, res, req.body);
  } catch (error) {
    console.error("MCP request failed", error);

    if (!res.headersSent) {
      res.status(500).json({
        jsonrpc: "2.0",
        error: {
          code: -32603,
          message: "Internal server error"
        },
        id: null
      });
    }
  } finally {
    res.on("close", () => {
      transport.close().catch(() => {});
      server.close().catch(() => {});
    });
  }
});

app.get("/mcp", (_req, res) => {
  res.status(405).json({
    jsonrpc: "2.0",
    error: {
      code: -32000,
      message: "Method not allowed."
    },
    id: null
  });
});

app.delete("/mcp", (_req, res) => {
  res.status(405).json({
    jsonrpc: "2.0",
    error: {
      code: -32000,
      message: "Method not allowed."
    },
    id: null
  });
});

app.use("/api/expenses", expensesRouter);

app.use((error, _req, res, _next) => {
  console.error(error);
  res.status(500).json({
    error: "Internal server error",
    details: error.message
  });
});

app.listen(port, () => {
  console.log(`Expense manager API listening on http://localhost:${port}`);
});
