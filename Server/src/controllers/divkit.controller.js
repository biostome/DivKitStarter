const divkitService = require("../services/divkit.service");
const { normalizePageName } = require("../validators/page.validator");

async function getHomeCard(req, res, next) {
  try {
    const card = await divkitService.getCard("home");
    res.json(card);
  } catch (error) {
    next(error);
  }
}

async function getPageCard(req, res, next) {
  try {
    const pageName = normalizePageName(req.params.page);
    const card = await divkitService.getCard(pageName);
    res.json(card);
  } catch (error) {
    next(error);
  }
}

module.exports = {
  getHomeCard,
  getPageCard,
};
