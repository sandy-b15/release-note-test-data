// CSV export utility
export function toCSV(data, columns) {
  const header = columns.join(',');
  const rows = data.map(r => columns.map(c => r[c]).join(','));
  return [header, ...rows].join('
');
}