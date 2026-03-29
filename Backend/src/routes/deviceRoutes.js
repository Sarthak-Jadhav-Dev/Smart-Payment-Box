const express = require('express');
const router = express.Router();
const Joi = require('joi');
const deviceController = require('../controllers/deviceController');
const validateRequest = require('../middleware/validateRequest');
const authMiddleware = require('../middleware/authMiddleware');

const statusSchema = Joi.object({
  status: Joi.string().valid('online', 'offline').required()
});

router.get('/status', authMiddleware, deviceController.getDeviceStatus);
router.post('/status', authMiddleware, validateRequest(statusSchema), deviceController.updateDeviceStatus);

module.exports = router;
