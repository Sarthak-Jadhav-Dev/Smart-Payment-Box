const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const { requestLogger } = require('./utils/logger');
const errorHandler = require('./middleware/errorHandler');

// Temporarily require an empty router, will create actual routes soon
const appRouter = require('./routes/index');

const app = express();

// Middlewares
app.use(helmet());
app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));
app.use(requestLogger);

// Routes
app.use('/api', appRouter);

// Health check endpoint
app.get('/health', (req, res) => {
  res.status(200).json({ status: 'UP' });
});

// Centralized Error Handling
app.use(errorHandler);

module.exports = app;
