// Timezone-aware date utility
exports.toUserTZ = (date, offsetMinutes) => {
  const d = new Date(date);
  d.setMinutes(d.getMinutes() + offsetMinutes);
  return d;
};