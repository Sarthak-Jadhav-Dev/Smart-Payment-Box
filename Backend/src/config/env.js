const dotenv = require('dotenv');
const Joi = require('joi');

dotenv.config();

const envSchema = Joi.object({
  PORT: Joi.number().default(3000),
  SUPABASE_URL: Joi.string().required(),
  SUPABASE_KEY: Joi.string().required(),
  JWT_SECRET: Joi.string().required(),
  MQTT_BROKER_URL: Joi.string().required()
}).unknown().required();

const { error, value: envVars } = envSchema.validate(process.env);

if (error) {
  throw new Error(`Config validation error: ${error.message}`);
}

module.exports = {
  port: envVars.PORT,
  supabase: {
    url: envVars.SUPABASE_URL,
    key: envVars.SUPABASE_KEY
  },
  jwt: {
    secret: envVars.JWT_SECRET
  },
  mqtt: {
    brokerUrl: envVars.MQTT_BROKER_URL
  }
};
