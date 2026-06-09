const cardRepository = require("../repositories/card.repository");
const { validateDivKitPayload } = require("../validators/divkit.validator");
const { validateDivKitSchema } = require("../validators/divkit-schema.validator");
const { validatePagePayload } = require("../validators/page-payload.validator");
const { validatePagePublication } = require("../validators/page-publication.validator");
const { validateSDUIActions } = require("../validators/sdui-action.validator");
const httpError = require("../utils/http-error");

async function getCard(pageName) {
  const rawJson = await cardRepository.readCardJson(pageName);
  const payload = parseCardJson(rawJson, pageName);
  validatePagePayload(payload, pageName);
  validatePagePublication(payload, pageName);
  validateDivKitPayload(payload, pageName);
  validateDivKitSchema(payload, pageName);
  validateSDUIActions(payload, pageName);
  return payload;
}

function parseCardJson(rawJson, pageName) {
  try {
    return JSON.parse(rawJson);
  } catch (error) {
    throw httpError(500, "invalid_json", `Card "${pageName}" is not valid JSON`);
  }
}

module.exports = {
  getCard,
};
