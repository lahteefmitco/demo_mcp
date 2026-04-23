import dotenv from "dotenv";
import express from "express";
import { StreamableHTTPServerTransport } from "@modelcontextprotocol/sdk/server/streamableHttp.js";
import { createExpenseManagerServer } from "./mcp/create-server.js";
import { authenticateRequest, requireAuth, unauthorizedJsonRpcResponse } from "./middleware/auth-middleware.js";
import { corsMiddleware } from "./middleware/cors.js";
import { logger, requestLogger } from "./logger.js";
import { runExpenseChat } from "./services/chat-service.js";
import authRouter from "./routes/auth.js";
import financeRouter from "./routes/finance.js";
import ragRouter from "./routes/rag.js";
import helpRouter from "./routes/help.js";

dotenv.config({ quiet: true, override: false });

const app = express();
const port = Number(process.env.PORT || 3000);

app.use(express.json());
app.use(express.urlencoded({ extended: false }));
app.use(requestLogger());
app.use(corsMiddleware());

// Handle browser CORS preflight before auth middleware.
app.options(/.*/, (_req, res) => {
  res.sendStatus(204);
});

app.get("/", (_req, res) => {
  logger.info("Welcome to the Personal Finance API (root)");
  res.json({ message: "Welcome to the Personal Finance API" });
});

function sendHealthJson(_req, res) {
  res.json({ ok: true, service: "personal-finance-api" });
}

app.get("/health", sendHealthJson);
// Alias for probes and docs that expect a path under /api
app.get("/api/health", sendHealthJson);

app.use("/api", authRouter);

app.post("/api/chat", requireAuth, async (req, res, next) => {
  try {
    const result = await runExpenseChat(req.body.messages, req.body.provider, req.user);
    res.json(result);
  } catch (error) {
    next(error);
  }
});

app.post("/mcp", async (req, res) => {
  try {
    const user = await authenticateRequest(req);
    const server = createExpenseManagerServer({ user });
    const transport = new StreamableHTTPServerTransport({
      sessionIdGenerator: undefined
    });

    await server.connect(transport);
    await transport.handleRequest(req, res, req.body);

    res.on("close", () => {
      transport.close().catch(() => {});
      server.close().catch(() => {});
    });
  } catch (error) {
    logger.error(`MCP request failed: ${error?.message || error}`, {
      stack: error?.stack
    });

    if (!res.headersSent) {
      if (error.statusCode === 401) {
        res.status(401).json(unauthorizedJsonRpcResponse(error.message));
      } else {
        res.status(500).json({
          jsonrpc: "2.0",
          error: {
            code: -32603,
            message: "Internal server error"
          },
          id: null
        });
      }
    }
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

app.use("/api/finance", requireAuth, financeRouter);
app.use("/api/help", helpRouter);
app.use("/api/rag", requireAuth, ragRouter);

app.use((error, _req, res, _next) => {
  logger.error(error?.message || String(error), { stack: error?.stack });
  const statusCode = error.statusCode || 500;
  res.status(statusCode).json({
    error: statusCode === 401 ? "Unauthorized" : "Internal server error",
    details: error.message
  });
});

app.listen(port, () => {
  logger.info(`Personal finance API listening on http://localhost:${port}`);
});
