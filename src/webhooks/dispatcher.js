// Webhook dispatcher
const crypto = require('crypto');
exports.sign = (payload, secret) => crypto.createHmac('sha256', secret).update(JSON.stringify(payload)).digest('hex');
exports.dispatch = async (url, payload, secret) => { /* fetch with retry */ };