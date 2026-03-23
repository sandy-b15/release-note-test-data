// Dashboard widget system
export const WIDGET_TYPES = ['chart', 'table', 'kpi', 'list'];
export function createWidget(type, config) { return { id: crypto.randomUUID(), type, config, position: { x: 0, y: 0 } }; }