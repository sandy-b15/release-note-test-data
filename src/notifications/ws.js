// WebSocket notification handler
const WebSocket = require('ws');
module.exports = (server) => {
  const wss = new WebSocket.Server({ server });
  wss.on('connection', (ws) => { ws.send(JSON.stringify({ type: 'connected' })); });
};