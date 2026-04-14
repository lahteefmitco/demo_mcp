import { DynamicStructuredTool } from "@langchain/core/tools";
import { executeFinanceMcpTool, getFinanceMcpToolDefinitions } from "../../mcp/tool-registry.js";
import { getFinancialInsights } from "../insights/finance-insights-service.js";
import { searchConversationMemory } from "../memory/conversation-memory.js";
import { retrieveFinancialContext } from "../vector/finance-retriever.js";
import { jsonSchemaToZod } from "./json-schema-to-zod.js";

export function createFinanceLangChainTools({ user }) {
  const mcpTools = getFinanceMcpToolDefinitions().map(
    (toolDefinition) =>
      new DynamicStructuredTool({
        name: toolDefinition.name,
        description: `${toolDefinition.description} This is an MCP-backed finance tool.`,
        schema: jsonSchemaToZod(toolDefinition.inputSchema),
        func: async (input) => {
          const result = await executeFinanceMcpTool({
            userId: user.id,
            name: toolDefinition.name,
            args: input
          });
          return JSON.stringify(result, null, 2);
        }
      })
  );

  const semanticSearchTool = new DynamicStructuredTool({
    name: "semantic_finance_search",
    description:
      "Search semantically across embedded expenses, incomes, categories, accounts, budgets, transfers, and memory entries. Use this for fuzzy recall, note-based matching, and concept search.",
    schema: jsonSchemaToZod({
      type: "object",
      required: ["query"],
      properties: {
        query: { type: "string" },
        topK: { type: "number" },
        documentTypes: {
          type: "array",
          items: { type: "string" }
        }
      }
    }),
    func: async ({ query, topK, documentTypes }) => {
      const result = await retrieveFinancialContext({
        userId: user.id,
        queryText: query,
        topK,
        documentTypes
      });
      return JSON.stringify(result, null, 2);
    }
  });

  const memorySearchTool = new DynamicStructuredTool({
    name: "search_conversation_memory",
    description:
      "Search long-term vector memory of previous user finance questions and assistant replies.",
    schema: jsonSchemaToZod({
      type: "object",
      required: ["query"],
      properties: {
        query: { type: "string" },
        topK: { type: "number" }
      }
    }),
    func: async ({ query, topK }) => {
      const result = await searchConversationMemory({
        userId: user.id,
        queryText: query,
        topK
      });
      return JSON.stringify(result, null, 2);
    }
  });

  const insightsTool = new DynamicStructuredTool({
    name: "financial_insights",
    description:
      "Generate structured spending trends, overspending signals, anomaly detection, and month-over-month insights.",
    schema: jsonSchemaToZod({
      type: "object",
      required: ["month"],
      properties: {
        month: { type: "string", description: "Month in YYYY-MM format." }
      }
    }),
    func: async ({ month }) => {
      const result = await getFinancialInsights(user.id, month);
      return JSON.stringify(result, null, 2);
    }
  });

  return [...mcpTools, semanticSearchTool, memorySearchTool, insightsTool];
}
