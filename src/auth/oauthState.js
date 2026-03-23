const crypto = require('crypto'); exports.create = (uid, secret) => crypto.createHmac('sha256', secret).update(uid).digest('hex');
