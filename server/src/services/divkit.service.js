const cardRepository = require("../repositories/card.repository");
const { validateDivKitPayload } = require("../validators/divkit.validator");
const { validateSDUIActions } = require("../validators/sdui-action.validator");
const httpError = require("../utils/http-error");

async function getCard(pageName) {
  const rawJson = await cardRepository.readCardJson(pageName);
  const payload = parseCardJson(rawJson, pageName);
  validateDivKitPayload(payload, pageName);
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
