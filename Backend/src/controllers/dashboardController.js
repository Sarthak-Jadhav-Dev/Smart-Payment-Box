const asyncHandler = require('../utils/asyncHandler');
const supabase = require('../config/supabase');

// @desc    Get Dashboard Analytics
// @route   GET /api/dashboard
// @access  Private
const getDashboardAnalytics = asyncHandler(async (req, res) => {
  const merchantId = req.user.id;

  // Calculate today's start date
  const startOfToday = new Date();
  startOfToday.setHours(0, 0, 0, 0);

  // 1. Fetch Today's Transactions
  const { data: todayTransactions, error: todayError } = await supabase
    .from('transactions')
    .select('amount')
    .eq('merchant_id', merchantId)
    .eq('status', 'success')
    .gte('created_at', startOfToday.toISOString());

  if (todayError) {
    throw new Error(`Failed to fetch today's transactions: ${todayError.message}`);
  }

  const todayTotal = todayTransactions.reduce((sum, txn) => sum + Number(txn.amount), 0);

  // 2. Fetch All Successful Transactions (for Total Count & Average)
  const { data: allTransactions, error: allError } = await supabase
    .from('transactions')
    .select('amount', { count: 'exact' })
    .eq('merchant_id', merchantId)
    .eq('status', 'success');

  if (allError) {
    throw new Error(`Failed to fetch total transactions: ${allError.message}`);
  }

  const totalCount = allTransactions.length;
  const overallTotal = allTransactions.reduce((sum, txn) => sum + Number(txn.amount), 0);
  const averageTransaction = totalCount > 0 ? Math.round(overallTotal / totalCount) : 0;

  res.status(200).json({
    success: true,
    data: {
      todayTotal,
      totalTransactions: totalCount,
      averageTransaction
    }
  });
});

module.exports = {
  getDashboardAnalytics
};
