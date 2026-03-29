const express = require('express');
const router = express.Router();
const authRoutes = require('./authRoutes');
const transactionRoutes = require('./transactionRoutes');
const dashboardRoutes = require('./dashboardRoutes');
const deviceRoutes = require('./deviceRoutes');

router.use('/auth', authRoutes);
router.use('/transactions', transactionRoutes);
router.use('/dashboard', dashboardRoutes);
router.use('/device', deviceRoutes);

module.exports = router;
