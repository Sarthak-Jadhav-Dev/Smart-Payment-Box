const app = require('./app');
const env = require('./config/env');
const logger = require('./utils/logger');
const mqttClient = require('./mqtt/client');

const startServer = async () => {
  try {
    // 1. Connect to MQTT Broker
    mqttClient.connect();

    // 2. Start Express server
    app.listen(env.port, () => {
      logger.info(`Server is running on port ${env.port}`);
    });

  } catch (error) {
    logger.error('Failed to start server:', error);
    process.exit(1);
  }
};

startServer();
