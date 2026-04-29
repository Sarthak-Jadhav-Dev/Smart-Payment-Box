/**
 * Built-in Keep-Alive Module
 * 
 * This can be integrated into your server.js to automatically
 * ping itself when running on Render.
 * 
 * To use: Import and call this in server.js
 */

const http = require('http');
const https = require('https');

class KeepAlive {
  constructor(url, intervalMinutes = 10) {
    this.url = url;
    this.interval = intervalMinutes * 60 * 1000;
    this.timer = null;
  }

  start() {
    // Only start if we're in production (Render)
    if (process.env.NODE_ENV !== 'production') {
      console.log('📍 Keep-alive disabled in development mode');
      return;
    }

    if (!this.url) {
      console.log('⚠️ Keep-alive URL not set, skipping...');
      return;
    }

    console.log(`🔄 Keep-alive started - Pinging every ${this.interval / 60000} minutes`);
    this.ping();
    this.timer = setInterval(() => this.ping(), this.interval);
  }

  ping() {
    try {
      const url = new URL(this.url);
      const client = url.protocol === 'https:' ? https : http;

      const options = {
        hostname: url.hostname,
        port: url.port || (url.protocol === 'https:' ? 443 : 80),
        path: '/health',
        method: 'GET',
        timeout: 30000,
      };

      const req = client.request(options, (res) => {
        const timestamp = new Date().toISOString();
        if (res.statusCode === 200) {
          console.log(`[${timestamp}] 💓 Self-ping successful`);
        }
      });

      req.on('error', (error) => {
        console.error(`[${new Date().toISOString()}] Self-ping error:`, error.message);
      });

      req.end();
    } catch (error) {
      console.error('Keep-alive error:', error.message);
    }
  }

  stop() {
    if (this.timer) {
      clearInterval(this.timer);
      this.timer = null;
    }
  }
}

module.exports = KeepAlive;
