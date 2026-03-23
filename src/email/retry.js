// Email retry logic
exports.sendWithRetry = async (mailer, opts, maxRetries = 3) => {
  for (let i = 0; i < maxRetries; i++) {
    try { return await mailer.send(opts); }
    catch (e) { if (i === maxRetries - 1) throw e; await new Promise(r => setTimeout(r, 1000 * 2 ** i)); }
  }
};