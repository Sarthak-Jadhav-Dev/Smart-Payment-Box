/**
 * Middleware to validate request payload against a Joi schema
 * @param {Joi.Schema} schema
 */
const validateRequest = (schema) => (req, res, next) => {
  const { error } = schema.validate(req.body, { abortEarly: false });
  if (error) {
    const errorMessages = error.details.map((details) => details.message).join(', ');
    const err = new Error(errorMessages);
    err.statusCode = 400;
    err.isOperational = true;
    return next(err);
  }
  next();
};

module.exports = validateRequest;
