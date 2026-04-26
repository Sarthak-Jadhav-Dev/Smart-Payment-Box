const supabase = require('../config/supabaseClient');
const excelJS = require('exceljs');
const { Resend } = require('resend');
const resend = new Resend(process.env.RESEND_API_KEY);

// Generate Excel file
exports.exportToExcel = async (req, res) => {
  try {
    const { data: transactions, error } = await supabase
      .from('synced_transactions')
      .select('*')
      .order('created_at', { ascending: false });

    if (error) return res.status(400).json({ error: error.message });

    const workbook = new excelJS.Workbook();
    const worksheet = workbook.addWorksheet('Transactions');

    worksheet.columns = [
      { header: 'ID', key: 'id', width: 30 },
      { header: 'Amount', key: 'amount', width: 15 },
      { header: 'Status', key: 'status', width: 15 },
      { header: 'Date', key: 'created_at', width: 25 },
      { header: 'Payer Info', key: 'payer_info', width: 30 }
    ];

    transactions.forEach(tx => {
      worksheet.addRow(tx);
    });

    res.setHeader(
      'Content-Type',
      'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'
    );
    res.setHeader(
      'Content-Disposition',
      'attachment; filename=' + 'transactions_report.xlsx'
    );

    await workbook.xlsx.write(res);
    res.status(200).end();
  } catch (err) {
    res.status(500).json({ error: 'Internal server error' });
  }
};

// Send Report to Email
exports.sendReportToEmail = async (req, res) => {
  try {
    const { targetEmail } = req.body;
    
    if (!targetEmail) {
      return res.status(400).json({ error: 'targetEmail is required' });
    }

    const { data: transactions, error } = await supabase
      .from('synced_transactions')
      .select('*')
      .order('created_at', { ascending: false });

    if (error) return res.status(400).json({ error: error.message });

    const workbook = new excelJS.Workbook();
    const worksheet = workbook.addWorksheet('Transactions');

    worksheet.columns = [
      { header: 'ID', key: 'id', width: 30 },
      { header: 'Amount', key: 'amount', width: 15 },
      { header: 'Status', key: 'status', width: 15 },
      { header: 'Date', key: 'created_at', width: 25 },
      { header: 'Payer Info', key: 'payer_info', width: 30 }
    ];

    transactions.forEach(tx => {
      worksheet.addRow(tx);
    });

    const buffer = await workbook.xlsx.writeBuffer();

    // Setup Resend
    const { data: emailData, error: emailError } = await resend.emails.send({
      from: 'Smart Payment Box <onboarding@resend.dev>',
      to: [targetEmail],
      subject: 'Smart Payment Box - Transactions Report',
      html: `
        <h2>Smart Payment Box Report</h2>
        <p>Hello,</p>
        <p>Please find attached your latest transactions report from your <strong>Smart Payment Box</strong>.</p>
        <p>This report was generated automatically. If you have any questions, please contact support.</p>
        <br/>
        <p style="color:#888">Smart Payment Box &copy; ${new Date().getFullYear()}</p>
      `,
      attachments: [
        {
          filename: 'transactions_report.xlsx',
          content: buffer.toString('base64'),
        }
      ]
    });

    if (emailError) {
      console.error('Resend Error:', JSON.stringify(emailError));
      return res.status(400).json({ error: emailError.message || JSON.stringify(emailError) });
    }

    res.status(200).json({ message: 'Report sent successfully', data: emailData });
  } catch (err) {
    res.status(500).json({ error: 'Internal server error' });
  }
};
