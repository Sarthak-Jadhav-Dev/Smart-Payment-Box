const express = require('express');
const router = express.Router();
const Joi = require('joi');
const authController = require('../controllers/authController');
const validateRequest = require('../middleware/validateRequest');

const loginSchema = Joi.object({
  phone: Joi.string().required(),
  name: Joi.string().optional()
});

router.post('/login', validateRequest(loginSchema), authController.login);

module.exports = router;
