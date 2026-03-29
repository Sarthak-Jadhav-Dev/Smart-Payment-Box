const { createClient } = require('@supabase/supabase-js');
const env = require('./env');

const supabase = createClient(env.supabase.url, env.supabase.key, {
  auth: {
    autoRefreshToken: false,
    persistSession: false
  }
});

module.exports = supabase;
