// Bulk actions component
export function BulkActions({ selected, onAction }) {
  const actions = ['delete', 'archive', 'export', 'tag'];
  return actions.map(a => ({ action: a, count: selected.length }));
}