/**
 * Cron Job Script for Render Free Tier
 * 
 * This script pings your Render backend every 10 minutes to keep it alive.
 * Render free tier spins down after 15 minutes of inactivity.
 * 
 * Usage:
 * 1. Upload this file with your backend to Render
 * 2. Set up a Cron Job on Render that runs: node cron-ping.js
 * 3. Set schedule to every 10 minutes (*/10 * * * *)
 * 
 * Alternative: Use an external service like UptimeRobot (easier method)
 */

const http = require('http');
const https = require('https');

// Your Render backend URL (change this after deployment)
const BACKEND_URL = process.env.BACKEND_URL || 'https://your-app.onrender.com';

function pingServer() {
  const url = new URL(BACKEND_URL);
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
      console.log(`[${timestamp}] ✅ Ping successful - Server is alive`);
    } else {
      console.log(`[${timestamp}] ⚠️ Unexpected status: ${res.statusCode}`);
    }
  });

  req.on('error', (error) => {
    console.error(`[${new Date().toISOString()}] ❌ Ping failed:`, error.message);
  });

  req.on('timeout', () => {
    console.error(`[${new Date().toISOString()}] ⏱️ Request timeout`);
    req.destroy();
  });

  req.end();
}

// Execute ping immediately
pingServer();

// Exit after ping completes (for cron jobs)
setTimeout(() => process.exit(0), 5000);
