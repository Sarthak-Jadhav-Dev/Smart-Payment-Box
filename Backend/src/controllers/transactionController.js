const asyncHandler = require('../utils/asyncHandler');
const supabase = require('../config/supabase');
const mqttClient = require('../mqtt/client');
const ExcelJS = require('exceljs');

// @desc    Receive Payment Data
// @route   POST /api/transactions
// @access  Private
const createTransaction = asyncHandler(async (req, res) => {
  const { amount, sender, status } = req.body;
  const merchantId = req.user.id;

  // 1. Save to Supabase
  const { data: transaction, error } = await supabase
    .from('transactions')
    .insert([
      { merchant_id: merchantId, amount, sender, status }
    ])
    .select()
    .single();

  if (error) {
    throw new Error(`Failed to save transaction: ${error.message}`);
  }

  // 2. Publish MQTT Message
  const topic = `merchant/${merchantId}/payment`;
  const payload = { amount, status };
  mqttClient.publishMessage(topic, payload);

  res.status(201).json({
    success: true,
    data: transaction
  });
});

// @desc    Get Transaction History
// @route   GET /api/transactions
// @access  Private
const getTransactions = asyncHandler(async (req, res) => {
  const merchantId = req.user.id;
  const { page = 1, limit = 10, startDate, endDate } = req.query;

  const offset = (page - 1) * limit;

  let query = supabase
    .from('transactions')
    .select('*', { count: 'exact' })
    .eq('merchant_id', merchantId)
    .order('created_at', { ascending: false })
    .range(offset, offset + limit - 1);

  if (startDate) {
    query = query.gte('created_at', new Date(startDate).toISOString());
  }
  if (endDate) {
    query = query.lte('created_at', new Date(endDate).toISOString());
  }

  const { data, error, count } = await query;

  if (error) {
    throw new Error(`Failed to fetch transactions: ${error.message}`);
  }

  res.status(200).json({
    success: true,
    count: data.length,
    total: count,
    pagination: {
      page: parseInt(page),
      limit: parseInt(limit),
      totalPages: Math.ceil(count / limit)
    },
    data
  });
});

// @desc    Export Transactions as Excel (.xlsx) within a time frame
// @route   GET /api/transactions/export?startDate=YYYY-MM-DD&endDate=YYYY-MM-DD
// @access  Private
const exportTransactions = asyncHandler(async (req, res) => {
  const merchantId = req.user.id;
  const { startDate, endDate } = req.query;

  if (!startDate || !endDate) {
    const err = new Error('Both startDate and endDate query params are required');
    err.statusCode = 400;
    err.isOperational = true;
    throw err;
  }

  // 1. Fetch all transactions in the given date range (no pagination)
  const { data, error } = await supabase
    .from('transactions')
    .select('*')
    .eq('merchant_id', merchantId)
    .gte('created_at', new Date(startDate).toISOString())
    .lte('created_at', new Date(endDate).toISOString())
    .order('created_at', { ascending: false });

  if (error) {
    throw new Error(`Failed to fetch transactions for export: ${error.message}`);
  }

  // 2. Create Excel Workbook
  const workbook = new ExcelJS.Workbook();
  workbook.creator = 'Smart UPI Merchant Assistant';
  workbook.created = new Date();

  const worksheet = workbook.addWorksheet('Transactions');

  // Define columns
  worksheet.columns = [
    { header: 'S.No', key: 'sno', width: 8 },
    { header: 'Transaction ID', key: 'id', width: 38 },
    { header: 'Amount (₹)', key: 'amount', width: 15 },
    { header: 'Sender', key: 'sender', width: 25 },
    { header: 'Status', key: 'status', width: 12 },
    { header: 'Date & Time', key: 'created_at', width: 25 },
  ];

  // Style header row
  worksheet.getRow(1).font = { bold: true, size: 12 };
  worksheet.getRow(1).fill = {
    type: 'pattern',
    pattern: 'solid',
    fgColor: { argb: 'FF4472C4' },
  };
  worksheet.getRow(1).font = { bold: true, color: { argb: 'FFFFFFFF' }, size: 12 };

  // Add data rows
  data.forEach((txn, index) => {
    worksheet.addRow({
      sno: index + 1,
      id: txn.id,
      amount: Number(txn.amount),
      sender: txn.sender,
      status: txn.status,
      created_at: new Date(txn.created_at).toLocaleString('en-IN', { timeZone: 'Asia/Kolkata' }),
    });
  });

  // Add summary row at the bottom
  const totalAmount = data
    .filter((txn) => txn.status === 'success')
    .reduce((sum, txn) => sum + Number(txn.amount), 0);

  worksheet.addRow({});
  const summaryRow = worksheet.addRow({
    sno: '',
    id: '',
    amount: totalAmount,
    sender: '',
    status: 'TOTAL (Success)',
    created_at: '',
  });
  summaryRow.font = { bold: true };

  // 3. Set response headers for file download
  const fileName = `transactions_${startDate}_to_${endDate}.xlsx`;
  res.setHeader('Content-Type', 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet');
  res.setHeader('Content-Disposition', `attachment; filename="${fileName}"`);

  // 4. Stream the workbook directly to the response
  await workbook.xlsx.write(res);
  res.end();
});

module.exports = {
  createTransaction,
  getTransactions,
  exportTransactions
};
