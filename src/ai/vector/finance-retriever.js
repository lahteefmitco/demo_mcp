import { similaritySearch } from "./document-store.js";

export async function retrieveFinancialContext({
  userId,
  queryText,
  topK,
  documentTypes
}) {
  return similaritySearch({
    userId,
    queryText,
    topK,
    documentTypes
  });
}
