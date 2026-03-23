// TOTP 2FA
const speakeasy = require('speakeasy');
exports.generateSecret = () => speakeasy.generateSecret({ length: 20 });
exports.verify = (secret, token) => speakeasy.totp.verify({ secret, token, encoding: 'base32' });