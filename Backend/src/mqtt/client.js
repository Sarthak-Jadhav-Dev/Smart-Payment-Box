const mqtt = require('mqtt');
const env = require('../config/env');
const logger = require('../utils/logger');
// supabase handles device state changes, so let's import the supabase client or models
// for now just basic handler
const supabase = require('../config/supabase');

class MqttService {
  constructor() {
    this.client = null;
  }

  connect() {
    this.client = mqtt.connect(env.mqtt.brokerUrl, {
      clientId: `upi_backend_${Math.random().toString(16).slice(3)}`,
      clean: true,
      connectTimeout: 4000,
      reconnectPeriod: 1000,
    });

    this.client.on('connect', () => {
      logger.info('Connected to MQTT Broker successfully');
      this.subscribeToTopic('device/+/status');
    });

    this.client.on('message', async (topic, message) => {
      logger.info(`Received message on ${topic}: ${message.toString()}`);
      
      // Parse device/<merchant_id>/status
      const topicParts = topic.split('/');
      if (topicParts.length === 3 && topicParts[0] === 'device' && topicParts[2] === 'status') {
        const merchantId = topicParts[1];
        try {
          const payload = JSON.parse(message.toString());
          // Update device status in Supabase table "device_status"
          await supabase.from('device_status').upsert({
            merchant_id: merchantId,
            status: payload.status,
            last_seen: new Date().toISOString()
          }, { onConflict: 'merchant_id' });
          logger.info(`Updated status for device ${merchantId} to ${payload.status}`);
        } catch (error) {
          logger.error(`Error processing device status: ${error.message}`);
        }
      }
    });

    this.client.on('error', (err) => {
      logger.error('MQTT connection error', err);
    });
  }

  subscribeToTopic(topic) {
    if (this.client) {
      this.client.subscribe(topic, (err) => {
        if (err) {
          logger.error(`Error subscribing to ${topic}: `, err);
        } else {
          logger.info(`Successfully subscribed to ${topic}`);
        }
      });
    }
  }

  publishMessage(topic, message, options = { qos: 1 }) {
    if (this.client && this.client.connected) {
      const payload = typeof message === 'string' ? message : JSON.stringify(message);
      this.client.publish(topic, payload, options, (err) => {
        if (err) {
          logger.error(`Failed to publish message to ${topic}`, err);
        } else {
          logger.info(`Published successfully to ${topic}`);
        }
      });
    } else {
      logger.error('MQTT Client is not connected. Message not published.');
    }
  }
}

module.exports = new MqttService();
