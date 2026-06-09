function notFoundMiddleware(req, res) {
  res.status(404).json({
    error: {
      code: "route_not_found",
      message: `Route ${req.method} ${req.originalUrl} not found`,
    },
  });
}

module.exports = notFoundMiddleware;
