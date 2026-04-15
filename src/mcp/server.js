import { logger } from "../logger.js";
import { StdioServerTransport } from "@modelcontextprotocol/sdk/server/stdio.js";
import { createExpenseManagerServer } from "./create-server.js";

async function main() {
  const server = createExpenseManagerServer();
  const transport = new StdioServerTransport();
  await server.connect(transport);
}

main().catch((error) => {
  logger.error("MCP server failed to start.", { stack: error?.stack, message: error?.message });
  process.exit(1);
});
