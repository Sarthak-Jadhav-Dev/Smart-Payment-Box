const supabase = require('../config/supabaseClient');

exports.syncTransactions = async (req, res) => {
  try {
    const { transactions } = req.body;
    
    if (!transactions || !Array.isArray(transactions)) {
      return res.status(400).json({ error: 'Transactions array is required' });
    }

    if (transactions.length === 0) {
      return res.status(200).json({ message: 'No new transactions to sync' });
    }

    // Insert transactions into Supabase table "synced_transactions"
    const { data, error } = await supabase
      .from('synced_transactions')
      .insert(transactions)
      .select();

    if (error) {
      return res.status(400).json({ error: error.message });
    }

    res.status(201).json({ message: 'Transactions synced successfully', syncedCount: data.length });
  } catch (err) {
    res.status(500).json({ error: 'Internal server error' });
  }
};
