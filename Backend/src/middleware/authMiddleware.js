const jwt = require('jsonwebtoken');
const env = require('../config/env');

const authMiddleware = (req, res, next) => {
  const token = req.header('Authorization')?.replace('Bearer ', '');

  if (!token) {
    return res.status(401).json({ success: false, error: 'No token, authorization denied' });
  }

  try {
    const decoded = jwt.verify(token, env.jwt.secret);
    req.user = decoded; // Contains { id: userId }
    next();
  } catch (error) {
    res.status(401).json({ success: false, error: 'Token is not valid' });
  }
};

module.exports = authMiddleware;
