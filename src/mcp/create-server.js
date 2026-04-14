import { Server } from "@modelcontextprotocol/sdk/server/index.js";
import {
  CallToolRequestSchema,
  ListToolsRequestSchema
} from "@modelcontextprotocol/sdk/types.js";
import {
  executeFinanceMcpTool,
  getFinanceMcpToolDefinitions
} from "./tool-registry.js";

export function createExpenseManagerServer({ user }) {
  const userId = user.id;
  const server = new Server(
    {
      name: "personal-finance-mcp",
      version: "2.0.0"
    },
    {
      capabilities: {
        tools: {}
      }
    }
  );

  server.setRequestHandler(ListToolsRequestSchema, async () => ({
    tools: getFinanceMcpToolDefinitions()
  }));

  server.setRequestHandler(CallToolRequestSchema, async (request) => {
    const { name, arguments: args = {} } = request.params;
    return jsonText(await executeFinanceMcpTool({ userId, name, args }));
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
