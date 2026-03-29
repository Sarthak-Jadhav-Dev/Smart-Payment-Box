const morgan = require('morgan');

const logger = {
  info: (...args) => console.log(`[INFO]`, ...args),
  error: (...args) => console.error(`[ERROR]`, ...args),
  warn: (...args) => console.warn(`[WARN]`, ...args),
};

const requestLogger = morgan('dev');

module.exports = {
  ...logger,
  requestLogger
};
