// Keyboard shortcut manager
const shortcuts = new Map();
exports.register = (combo, handler) => shortcuts.set(combo, handler);
document.addEventListener('keydown', (e) => {
  const combo = [e.metaKey && 'cmd', e.key].filter(Boolean).join('+');
  shortcuts.get(combo)?.(e);
});