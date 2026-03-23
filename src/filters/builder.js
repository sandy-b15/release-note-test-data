// Filter builder
export function buildQuery(filters) {
  return filters.map(f => ({
    field: f.field, op: f.operator, value: f.value
  }));
}