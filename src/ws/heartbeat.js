// WebSocket heartbeat
exports.startHeartbeat = (wss, interval = 30000) => {
  setInterval(() => { wss.clients.forEach(ws => { if (!ws.isAlive) return ws.terminate(); ws.isAlive = false; ws.ping(); }); }, interval);
};