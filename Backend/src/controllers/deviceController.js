const asyncHandler = require('../utils/asyncHandler');
const supabase = require('../config/supabase');

// @desc    Get Device Status
// @route   GET /api/device/status
// @access  Private
const getDeviceStatus = asyncHandler(async (req, res) => {
  const merchantId = req.user.id;

  const { data: deviceStatus, error } = await supabase
    .from('device_status')
    .select('*')
    .eq('merchant_id', merchantId)
    .single();

  if (error && error.code !== 'PGRST116') {
    throw new Error(`Failed to fetch device status: ${error.message}`);
  }

  res.status(200).json({
    success: true,
    data: deviceStatus || { merchant_id: merchantId, status: 'offline', last_seen: null }
  });
});

// @desc    Update Device Status (Manual override or API trigger)
// @route   POST /api/device/status
// @access  Private
const updateDeviceStatus = asyncHandler(async (req, res) => {
  const merchantId = req.user.id;
  const { status } = req.body;

  const { data: deviceStatus, error } = await supabase
    .from('device_status')
    .upsert({
      merchant_id: merchantId,
      status,
      last_seen: new Date().toISOString()
    }, { onConflict: 'merchant_id' })
    .select()
    .single();

  if (error) {
    throw new Error(`Failed to update device status: ${error.message}`);
  }

  res.status(200).json({
    success: true,
    data: deviceStatus
  });
});

module.exports = {
  getDeviceStatus,
  updateDeviceStatus
};
