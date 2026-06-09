const divkitService = require("../services/divkit.service");
const { normalizePageName } = require("../validators/page.validator");

async function getHomeCard(req, res, next) {
  try {
    const card = await divkitService.getCard("home");
    setPageHeaders(res, card.page);
    res.json(card);
  } catch (error) {
    next(error);
  }
}

async function getPageCard(req, res, next) {
  try {
    const pageName = normalizePageName(req.params.page);
    const card = await divkitService.getCard(pageName);
    setPageHeaders(res, card.page);
    res.json(card);
  } catch (error) {
    next(error);
  }
}

function setPageHeaders(res, page) {
  if (!page) {
    return;
  }
  if (page.id) {
    res.set("X-SDUI-Page-Id", page.id);
  }
  if (page.version !== undefined) {
    res.set("X-SDUI-Page-Version", String(page.version));
  }
  if (page.publishedAt) {
    res.set("X-SDUI-Published-At", page.publishedAt);
  }
}

module.exports = {
  getHomeCard,
  getPageCard,
};
