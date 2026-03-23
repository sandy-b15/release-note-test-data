// RSS feed generator
exports.generateFeed = (notes) => {
  const items = notes.map(n => `<item><title>${n.title}</title><description>${n.content}</description></item>`);
  return `<?xml version='1.0'?><rss version='2.0'><channel>${items.join('')}</channel></rss>`;
};