const express = require('express');
const router = express.Router();
const Joi = require('joi');
const transactionController = require('../controllers/transactionController');
const validateRequest = require('../middleware/validateRequest');
const authMiddleware = require('../middleware/authMiddleware');

const transactionSchema = Joi.object({
  amount: Joi.number().positive().required(),
  sender: Joi.string().required(),
  status: Joi.string().valid('success', 'failed').required()
});

router.get('/export', authMiddleware, transactionController.exportTransactions);
router.post('/', authMiddleware, validateRequest(transactionSchema), transactionController.createTransaction);
router.get('/', authMiddleware, transactionController.getTransactions);

module.exports = router;
