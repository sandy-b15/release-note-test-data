// Session handler
exports.validateSession = (req) => {
  if (!req.session?.valid) { req.session.destroy(); return false; }
  return true;
};