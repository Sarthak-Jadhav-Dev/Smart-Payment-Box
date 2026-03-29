const jwt = require('jsonwebtoken');
const env = require('../config/env');
const asyncHandler = require('../utils/asyncHandler');
const supabase = require('../config/supabase');

// Mock login logic, checks or creates a merchant via phone number
const login = asyncHandler(async (req, res) => {
  const { phone, name } = req.body;

  // 1. Try to fetch existing merchant
  let { data: merchant, error: fetchError } = await supabase
    .from('merchants')
    .select('*')
    .eq('phone', phone)
    .single();

  if (fetchError && fetchError.code !== 'PGRST116') { // PGRST116 is 'not found'
    throw new Error(`Failed to fetch merchant: ${fetchError.message}`);
  }

  // 2. If not found, create new merchant
  if (!merchant) {
    const { data: newMerchant, error: insertError } = await supabase
      .from('merchants')
      .insert([{ phone, name: name || 'Mock Merchant' }])
      .select()
      .single();

    if (insertError) {
      throw new Error(`Failed to create merchant: ${insertError.message}`);
    }
    merchant = newMerchant;
  }

  // 3. Generate JWT
  const payload = {
    id: merchant.id,
    phone: merchant.phone
  };

  const token = jwt.sign(payload, env.jwt.secret, { expiresIn: '30d' });

  res.status(200).json({
    success: true,
    token,
    user: merchant
  });
});

module.exports = {
  login
};
