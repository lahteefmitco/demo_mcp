import { getAiConfig } from "../config.js";
import {
  getCategoryById,
  getExpenseById,
  getIncomeById
} from "../../services/finance-service.js";
import { deleteDocument, embedText, upsertDocument } from "./document-store.js";

export async function syncFinanceDocument({ userId, sourceType, sourceId }) {
  const config = getAiConfig();

  if (sourceType === "category" && !config.enableCategoryEmbeddings) {
    return;
  }

  const record = await loadFinanceRecordForEmbedding({ userId, sourceType, sourceId });

  if (!record) {
    return;
  }

  const document = buildFinanceDocument(sourceType, record);
  const embedding = await embedText(document.content, config.embeddingProvider);

  await upsertDocument({
    userId,
    sourceType,
    sourceId,
    content: document.content,
    metadata: document.metadata,
    providerName: embedding.providerName,
    modelName: embedding.modelName,
    vector: embedding.vector
  });
}

export async function deleteFinanceDocument({ userId, sourceType, sourceId }) {
  await deleteDocument({ userId, sourceType, sourceId });
}

function buildFinanceDocument(sourceType, record) {
  if (sourceType === "expense") {
    return {
      content: [
        `Expense: ${record.title}`,
        `Amount: ${record.amount}`,
        `Spent on: ${record.spentOn}`,
        `Category: ${record.categoryName}`,
        `Account: ${record.accountName}`,
        `Notes: ${record.notes || "none"}`
      ].join("\n"),
      metadata: {
        sourceType,
        title: record.title,
        amount: record.amount,
        date: record.spentOn,
        categoryId: record.categoryId,
        categoryName: record.categoryName,
        accountId: record.accountId,
        accountName: record.accountName
      }
    };
  }

  if (sourceType === "income") {
    return {
      content: [
        `Income: ${record.title}`,
        `Amount: ${record.amount}`,
        `Received on: ${record.receivedOn}`,
        `Category: ${record.categoryName}`,
        `Account: ${record.accountName}`,
        `Notes: ${record.notes || "none"}`
      ].join("\n"),
      metadata: {
        sourceType,
        title: record.title,
        amount: record.amount,
        date: record.receivedOn,
        categoryId: record.categoryId,
        categoryName: record.categoryName,
        accountId: record.accountId,
        accountName: record.accountName
      }
    };
  }

  if (sourceType === "category") {
    return {
      content: [
        `Category: ${record.name}`,
        `Kind: ${record.kind}`,
        `Color: ${record.color}`,
        `Icon: ${record.icon}`
      ].join("\n"),
      metadata: {
        sourceType,
        name: record.name,
        kind: record.kind,
        color: record.color,
        icon: record.icon
      }
    };
  }

  throw new Error(`Unsupported finance document source type: ${sourceType}`);
}

async function loadFinanceRecordForEmbedding({ userId, sourceType, sourceId }) {
  if (sourceType === "expense") {
    return getExpenseById(userId, sourceId);
  }

  if (sourceType === "income") {
    return getIncomeById(userId, sourceId);
  }

  if (sourceType === "category") {
    return getCategoryById(userId, sourceId);
  }

  throw new Error(`Unsupported source type for embeddings: ${sourceType}`);
}
