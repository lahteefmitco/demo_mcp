import dotenv from "dotenv";
import { StdioServerTransport } from "@modelcontextprotocol/sdk/server/stdio.js";
import { createExpenseManagerServer } from "./create-server.js";

dotenv.config({ quiet: true });

async function main() {
  const server = createExpenseManagerServer();
  const transport = new StdioServerTransport();
  await server.connect(transport);
}

main().catch((error) => {
  console.error("MCP server failed to start.");
  console.error(error);
  process.exit(1);
});
