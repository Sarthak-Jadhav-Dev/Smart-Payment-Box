const express = require('express');
const router = express.Router();
const reportController = require('../controllers/report.controller');

router.get('/export', reportController.exportToExcel);
router.post('/email', reportController.sendReportToEmail);

module.exports = router;
