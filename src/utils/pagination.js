// Pagination utility
exports.paginate = (page, limit = 50) => ({
  offset: (Math.max(1, page) - 1) * limit,
  limit,
});