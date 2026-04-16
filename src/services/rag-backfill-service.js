import { query } from "../db.js";
import { logger } from "../logger.js";
import { mistralEmbedTexts } from "./mistral-embeddings.js";
import { RAG_EMBEDDING_DIMENSION, upsertAiDocument } from "./rag-service.js";

const EMBEDDING_PROVIDER = "mistral";
const EMBED_BATCH = Math.min(32, Math.max(1, Number(process.env.RAG_EMBED_BATCH || 16)));

export function chunkText(raw, maxChars = Number(process.env.RAG_CHUNK_CHARS || 1600)) {
  const t = (raw ?? "").trim();
  if (!t) {
    return [];
  }

  if (t.length <= maxChars) {
    return [t];
  }

  const chunks = [];
  let i = 0;

  while (i < t.length) {
    let end = Math.min(i + maxChars, t.length);
    if (end < t.length) {
      const para = t.lastIndexOf("\n\n", end);
      if (para > i + Math.floor(maxChars / 2)) {
        end = para + 2;
      } else {
        const sent = t.lastIndexOf(". ", end);
        if (sent > i + Math.floor(maxChars / 2)) {
          end = sent + 2;
        }
      }
    }

    const piece = t.slice(i, end).trim();
    if (piece) {
      chunks.push(piece);
    }

    const next = end <= i ? i + maxChars : end;
    if (next <= i) {
      break;
    }
    i = next;
  }

  return chunks;
}

async function tableExists(name) {
  const rows = await query(
    `SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = $1 LIMIT 1`,
    [name]
  );
  return rows.length > 0;
}

async function columnExists(tableName, columnName) {
  const rows = await query(
    `
      SELECT 1 FROM information_schema.columns
      WHERE table_schema = 'public' AND table_name = $1 AND column_name = $2
      LIMIT 1
    `,
    [tableName, columnName]
  );
  return rows.length > 0;
}

function embeddingModelLabel() {
  return process.env.MISTRAL_EMBEDDING_MODEL || "mistral-embed";
}

/**
 * @typedef {{ userId: number, documentKey: string, documentType: string, sourceId: string | null, content: string, metadata: object }} RagChunk
 */

/** @returns {Promise<RagChunk[]>} */
async function collectCategoryChunks(userId) {
  const uuidCol = await columnExists("categories", "uuid");
  const select = uuidCol
    ? `SELECT id, uuid::text AS uuid, name, kind FROM categories WHERE user_id = $1`
    : `SELECT id, NULL::text AS uuid, name, kind FROM categories WHERE user_id = $1`;

  const rows = await query(select, [userId]);
  const out = [];

  for (const r of rows) {
    const body = [`Category: ${r.name}`, `Kind: ${r.kind}`].join("\n");
    const sourceId = r.uuid || String(r.id);
    const parts = chunkText(body);
    parts.forEach((content, idx) => {
      out.push({
        userId,
        documentKey: `category:${r.id}:chunk:${idx}`,
        documentType: "category",
        sourceId,
        content,
        metadata: { categoryId: r.id, uuid: r.uuid }
      });
    });
  }

  return out;
}

/** @returns {Promise<RagChunk[]>} */
async function collectExpenseChunks(userId) {
  const uuidCol = await columnExists("expenses", "uuid");
  const hasAccounts = (await tableExists("accounts")) && (await columnExists("expenses", "account_id"));

  const sql = hasAccounts
    ? `
      SELECT e.id,
             ${uuidCol ? "e.uuid::text" : "NULL::text"} AS uuid,
             e.title, e.amount, e.notes, e.spent_on,
             c.name AS category_name,
             a.name AS account_name
      FROM expenses e
      JOIN categories c ON c.id = e.category_id AND c.user_id = e.user_id
      LEFT JOIN accounts a ON a.id = e.account_id AND a.user_id = e.user_id
      WHERE e.user_id = $1
    `
    : `
      SELECT e.id,
             ${uuidCol ? "e.uuid::text" : "NULL::text"} AS uuid,
             e.title, e.amount, e.notes, e.spent_on,
             c.name AS category_name,
             NULL::text AS account_name
      FROM expenses e
      JOIN categories c ON c.id = e.category_id AND c.user_id = e.user_id
      WHERE e.user_id = $1
    `;

  const rows = await query(sql, [userId]);
  const out = [];

  for (const r of rows) {
    const lines = [
      `Expense: ${r.title}`,
      `Amount: ${r.amount} (spent_on ${r.spent_on})`,
      `Category: ${r.category_name}`
    ];
    if (r.account_name) {
      lines.push(`Account: ${r.account_name}`);
    }
    if (r.notes) {
      lines.push(`Notes: ${r.notes}`);
    }

    const body = lines.join("\n");
    const sourceId = r.uuid || String(r.id);
    const parts = chunkText(body);
    parts.forEach((content, idx) => {
      out.push({
        userId,
        documentKey: `expense:${r.id}:chunk:${idx}`,
        documentType: "expense",
        sourceId,
        content,
        metadata: { expenseId: r.id, uuid: r.uuid }
      });
    });
  }

  return out;
}

/** @returns {Promise<RagChunk[]>} */
async function collectIncomeChunks(userId) {
  const uuidCol = await columnExists("incomes", "uuid");
  const hasAccounts = (await tableExists("accounts")) && (await columnExists("incomes", "account_id"));

  const sql = hasAccounts
    ? `
      SELECT i.id,
             ${uuidCol ? "i.uuid::text" : "NULL::text"} AS uuid,
             i.title, i.amount, i.notes, i.received_on,
             c.name AS category_name,
             a.name AS account_name
      FROM incomes i
      JOIN categories c ON c.id = i.category_id AND c.user_id = i.user_id
      LEFT JOIN accounts a ON a.id = i.account_id AND a.user_id = i.user_id
      WHERE i.user_id = $1
    `
    : `
      SELECT i.id,
             ${uuidCol ? "i.uuid::text" : "NULL::text"} AS uuid,
             i.title, i.amount, i.notes, i.received_on,
             c.name AS category_name,
             NULL::text AS account_name
      FROM incomes i
      JOIN categories c ON c.id = i.category_id AND c.user_id = i.user_id
      WHERE i.user_id = $1
    `;

  const rows = await query(sql, [userId]);
  const out = [];

  for (const r of rows) {
    const lines = [
      `Income: ${r.title}`,
      `Amount: ${r.amount} (received_on ${r.received_on})`,
      `Category: ${r.category_name}`
    ];
    if (r.account_name) {
      lines.push(`Account: ${r.account_name}`);
    }
    if (r.notes) {
      lines.push(`Notes: ${r.notes}`);
    }

    const body = lines.join("\n");
    const sourceId = r.uuid || String(r.id);
    const parts = chunkText(body);
    parts.forEach((content, idx) => {
      out.push({
        userId,
        documentKey: `income:${r.id}:chunk:${idx}`,
        documentType: "income",
        sourceId,
        content,
        metadata: { incomeId: r.id, uuid: r.uuid }
      });
    });
  }

  return out;
}

/** @returns {Promise<RagChunk[]>} */
async function collectBudgetChunks(userId) {
  const uuidCol = await columnExists("budgets", "uuid");
  const select = uuidCol
    ? `
      SELECT b.id, b.uuid::text AS uuid, b.name, b.amount, b.period, b.start_date, b.notes,
             c.name AS category_name
      FROM budgets b
      LEFT JOIN categories c ON c.id = b.category_id AND c.user_id = b.user_id
      WHERE b.user_id = $1
    `
    : `
      SELECT b.id, NULL::text AS uuid, b.name, b.amount, b.period, b.start_date, b.notes,
             c.name AS category_name
      FROM budgets b
      LEFT JOIN categories c ON c.id = b.category_id AND c.user_id = b.user_id
      WHERE b.user_id = $1
    `;

  const rows = await query(select, [userId]);
  const out = [];

  for (const r of rows) {
    const lines = [
      `Budget: ${r.name}`,
      `Amount: ${r.amount}, period: ${r.period}, starts: ${r.start_date}`
    ];
    if (r.category_name) {
      lines.push(`Category: ${r.category_name}`);
    }
    if (r.notes) {
      lines.push(`Notes: ${r.notes}`);
    }

    const body = lines.join("\n");
    const sourceId = r.uuid || String(r.id);
    const parts = chunkText(body);
    parts.forEach((content, idx) => {
      out.push({
        userId,
        documentKey: `budget:${r.id}:chunk:${idx}`,
        documentType: "budget",
        sourceId,
        content,
        metadata: { budgetId: r.id, uuid: r.uuid }
      });
    });
  }

  return out;
}

/** @returns {Promise<RagChunk[]>} */
async function collectAccountChunks(userId) {
  if (!(await tableExists("accounts"))) {
    return [];
  }

  const uuidCol = await columnExists("accounts", "uuid");
  const select = uuidCol
    ? `
      SELECT id, uuid::text AS uuid, name, type, initial_balance, notes, is_active
      FROM accounts
      WHERE user_id = $1
    `
    : `
      SELECT id, NULL::text AS uuid, name, type, initial_balance, notes, is_active
      FROM accounts
      WHERE user_id = $1
    `;

  const rows = await query(select, [userId]);
  const out = [];

  for (const r of rows) {
    const lines = [
      `Account: ${r.name}`,
      `Type: ${r.type}, initial_balance: ${r.initial_balance}, active: ${r.is_active}`
    ];
    if (r.notes) {
      lines.push(`Notes: ${r.notes}`);
    }

    const body = lines.join("\n");
    const sourceId = r.uuid || String(r.id);
    const parts = chunkText(body);
    parts.forEach((content, idx) => {
      out.push({
        userId,
        documentKey: `account:${r.id}:chunk:${idx}`,
        documentType: "account",
        sourceId,
        content,
        metadata: { accountId: r.id, uuid: r.uuid }
      });
    });
  }

  return out;
}

/** @returns {Promise<RagChunk[]>} */
async function collectTransferChunks(userId) {
  if (!(await tableExists("transfers"))) {
    return [];
  }

  const uuidCol = await columnExists("transfers", "uuid");
  const select = uuidCol
    ? `
      SELECT t.id, t.uuid::text AS uuid, t.amount, t.notes, t.created_at,
             fa.name AS from_account, ta.name AS to_account
      FROM transfers t
      JOIN accounts fa ON fa.id = t.from_account_id AND fa.user_id = t.user_id
      JOIN accounts ta ON ta.id = t.to_account_id AND ta.user_id = t.user_id
      WHERE t.user_id = $1
    `
    : `
      SELECT t.id, NULL::text AS uuid, t.amount, t.notes, t.created_at,
             fa.name AS from_account, ta.name AS to_account
      FROM transfers t
      JOIN accounts fa ON fa.id = t.from_account_id AND fa.user_id = t.user_id
      JOIN accounts ta ON ta.id = t.to_account_id AND ta.user_id = t.user_id
      WHERE t.user_id = $1
    `;

  const rows = await query(select, [userId]);
  const out = [];

  for (const r of rows) {
    const lines = [
      `Transfer: ${r.amount} from "${r.from_account}" to "${r.to_account}"`,
      `Created: ${r.created_at}`
    ];
    if (r.notes) {
      lines.push(`Notes: ${r.notes}`);
    }

    const body = lines.join("\n");
    const sourceId = r.uuid || String(r.id);
    const parts = chunkText(body);
    parts.forEach((content, idx) => {
      out.push({
        userId,
        documentKey: `transfer:${r.id}:chunk:${idx}`,
        documentType: "transfer",
        sourceId,
        content,
        metadata: { transferId: r.id, uuid: r.uuid }
      });
    });
  }

  return out;
}

/** @returns {Promise<RagChunk[]>} */
async function collectAllChunksForUser(userId) {
  const parts = await Promise.all([
    collectCategoryChunks(userId),
    collectExpenseChunks(userId),
    collectIncomeChunks(userId),
    collectBudgetChunks(userId),
    collectAccountChunks(userId),
    collectTransferChunks(userId)
  ]);

  return parts.flat();
}

async function embedAndStoreChunks(chunks) {
  const model = embeddingModelLabel();

  for (let i = 0; i < chunks.length; i += EMBED_BATCH) {
    const slice = chunks.slice(i, i + EMBED_BATCH);
    const texts = slice.map((c) => c.content);
    const vectors = await mistralEmbedTexts(texts);

    if (vectors.length !== slice.length) {
      throw new Error("Mistral embeddings batch size mismatch.");
    }

    for (let j = 0; j < slice.length; j += 1) {
      const chunk = slice[j];
      const embedding = vectors[j];
      if (!embedding || embedding.length !== RAG_EMBEDDING_DIMENSION) {
        throw new Error(
          `Unexpected embedding dimension ${embedding?.length}; expected ${RAG_EMBEDDING_DIMENSION}`
        );
      }

      await upsertAiDocument({
        userId: chunk.userId,
        documentKey: chunk.documentKey,
        documentType: chunk.documentType,
        sourceId: chunk.sourceId,
        content: chunk.content,
        embedding,
        embeddingProvider: EMBEDDING_PROVIDER,
        embeddingModel: model,
        metadata: chunk.metadata
      });
    }
  }
}

/**
 * Deletes existing ai_documents for the user, then rebuilds from finance tables.
 * @param {number} userId
 */
export async function reindexUser(userId) {
  if (!process.env.MISTRAL_API_KEY) {
    throw new Error("MISTRAL_API_KEY is required to reindex.");
  }

  await query("DELETE FROM ai_documents WHERE user_id = $1", [userId]);
  const chunks = await collectAllChunksForUser(userId);
  logger.info("RAG reindex: collected chunks", { userId, count: chunks.length });

  if (!chunks.length) {
    return { userId, chunks: 0, documents: 0 };
  }

  await embedAndStoreChunks(chunks);
  return { userId, chunks: chunks.length, documents: chunks.length };
}

/**
 * Truncates ai_documents for all users, then rebuilds from finance data.
 */
export async function truncateAndReindexAllUsers() {
  if (!process.env.MISTRAL_API_KEY) {
    throw new Error("MISTRAL_API_KEY is required to reindex.");
  }

  await query("TRUNCATE TABLE ai_documents");
  const users = await query("SELECT id FROM users ORDER BY id ASC");
  let totalChunks = 0;

  for (const u of users) {
    const { chunks } = await reindexUser(u.id);
    totalChunks += chunks;
  }

  logger.info("RAG full reindex complete.", { users: users.length, totalChunks });
  return { users: users.length, totalChunks };
}
