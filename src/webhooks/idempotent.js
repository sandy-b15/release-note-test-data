const sent = new Set(); exports.shouldSend = (key) => { if (sent.has(key)) return false; sent.add(key); return true; };
