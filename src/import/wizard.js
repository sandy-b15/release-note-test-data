// Import wizard
exports.parseCSV = (text) => {
  const [header, ...rows] = text.split('
').map(r => r.split(','));
  return rows.map(r => Object.fromEntries(header.map((h, i) => [h.trim(), r[i]?.trim()])));
};