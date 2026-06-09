const fs = require("fs");
const path = require("path");
const Ajv = require("ajv");
const config = require("../config");
const httpError = require("../utils/http-error");

let validateCard;
let schemaLoadError;

function validateDivKitSchema(payload, pageName) {
  const validator = getValidator();
  if (!validator) {
    if (schemaLoadError) {
      throw httpError(500, "divkit_schema_unavailable", schemaLoadError.message);
    }
    return;
  }

  if (!validator(payload.card)) {
    const detail = validator.errors?.[0];
    const message = detail ? `${detail.instancePath || "/"} ${detail.message}` : "unknown schema error";
    throw httpError(500, "invalid_divkit_schema", `Card "${pageName}" does not match official DivKit schema: ${message}`);
  }
}

function getValidator() {
  if (!config.divkitSchemaDirectory) {
    return null;
  }
  if (validateCard || schemaLoadError) {
    return validateCard;
  }

  try {
    const ajv = new Ajv({ strict: false, allErrors: true, validateSchema: false });
    ajv.addFormat("color", true);
    ajv.addFormat("uri", true);
    for (const fileName of fs.readdirSync(config.divkitSchemaDirectory)) {
      if (!fileName.endsWith(".json")) {
        continue;
      }
      const schemaPath = path.join(config.divkitSchemaDirectory, fileName);
      const schema = normalizeDivKitSchema(JSON.parse(fs.readFileSync(schemaPath, "utf8")), fileName);
      ajv.addSchema(schema, fileName);
    }
    validateCard = ajv.getSchema("div-data.json") || ajv.compile(readSchema("div-data.json"));
  } catch (error) {
    schemaLoadError = error;
  }

  return validateCard;
}

function readSchema(fileName) {
  const schemaPath = path.join(config.divkitSchemaDirectory, fileName);
  return normalizeDivKitSchema(JSON.parse(fs.readFileSync(schemaPath, "utf8")), fileName);
}

function normalizeDivKitSchema(value, fileName) {
  if (fileName === "common.json") {
    return {
      definitions: normalizeDivKitSchema(value),
    };
  }
  return normalizeSchemaNode(value);
}

function normalizeSchemaNode(value) {
  if (!value || typeof value !== "object") {
    return value;
  }
  if (Array.isArray(value)) {
    return value.map(normalizeSchemaNode);
  }

  const result = {};
  for (const [key, child] of Object.entries(value)) {
    if (key === "$ref" && typeof child === "string" && child.startsWith("common.json#/")) {
      result[key] = child.replace("common.json#/", "common.json#/definitions/");
      continue;
    }
    result[key] = normalizeSchemaNode(child);
  }
  if (result.type === "dict") {
    result.type = "object";
  }
  return result;
}

module.exports = {
  validateDivKitSchema,
};
