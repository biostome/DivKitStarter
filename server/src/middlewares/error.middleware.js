function errorMiddleware(error, req, res, next) {
  const status = error.status || 500;
  const code = error.code || "internal_error";
  const message = status >= 500 ? "Internal server error" : error.message;

  if (status >= 500) {
    console.error(error);
  }

  res.status(status).json({
    error: {
      code,
      message,
    },
  });
}

module.exports = errorMiddleware;
