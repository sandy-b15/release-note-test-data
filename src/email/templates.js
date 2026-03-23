// Email template engine
const Handlebars = require('handlebars');
exports.render = (template, data) => {
  const compiled = Handlebars.compile(template);
  return compiled(data);
};