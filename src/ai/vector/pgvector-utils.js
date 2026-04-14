export function toPgVectorLiteral(values) {
  if (!Array.isArray(values) || values.length === 0) {
    throw new Error("Embedding vector must be a non-empty array.");
  }

  return `[${values.map((value) => Number(value)).join(",")}]`;
}

export function buildDocumentKey(sourceType, sourceId) {
  return `${sourceType}:${sourceId}`;
}
