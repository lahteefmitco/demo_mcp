import { z } from "zod";

export function jsonSchemaToZod(schema = { type: "object", properties: {} }) {
  if (schema.type === "string") {
    return z.string();
  }

  if (schema.type === "number") {
    return z.number();
  }

  if (schema.type === "boolean") {
    return z.boolean();
  }

  if (schema.type === "array") {
    return z.array(jsonSchemaToZod(schema.items || { type: "string" }));
  }

  if (schema.type === "object" || schema.properties) {
    const required = new Set(schema.required || []);
    const shape = {};

    for (const [key, value] of Object.entries(schema.properties || {})) {
      const mapped = jsonSchemaToZod(value);
      shape[key] = required.has(key) ? mapped : mapped.optional();
    }

    return z.object(shape);
  }

  return z.any();
}
