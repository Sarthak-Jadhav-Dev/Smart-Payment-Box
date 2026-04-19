import '../models/transaction.dart';

class NotificationParser {
  static Transaction? parseNotification(String packageName, String title, String text) {
    final lowerPkg = packageName.toLowerCase();
    if (lowerPkg.contains('com.google.android.apps.nbu.paisa.user') || lowerPkg.contains('gpay')) {
        return _parseGPay(title, text);
    } else if (lowerPkg.contains('com.phonepe.app') || lowerPkg.contains('phonepe')) {
        return _parsePhonePe(title, text);
    } else if (lowerPkg.contains('net.one97.paytm') || lowerPkg.contains('paytm')) {
        return _parsePaytm(title, text);
    } else if (lowerPkg.contains('kotak') || lowerPkg.contains('hdfc') || lowerPkg.contains('sbi') || lowerPkg.contains('axis')) {
        return _parseBankApp(title, text);
    }
    return null;
  }

  static String _generateId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }

  static Transaction? _parseGPay(String title, String text) {
    // CREDIT: "Mr DARSHAN DATTATREY JADHAV paid you ₹1.00" / "₹1.00 received from Name"
    // DEBIT: "You paid ₹1.00 to Name" / "₹1.00 sent to Name"
    final content = title.toLowerCase();
    final isCredit = content.contains('paid you') || content.contains('received');
    final isDebit = content.contains('you paid') || content.contains('sent to') || content.contains('paid to');
    
    // Only process credit transactions (money received)
    if (isDebit || !isCredit) return null;
    
    final amountMatch = RegExp(r'₹\s?([\d.,]+)').firstMatch(title);
    final nameMatchPaidYou = RegExp(r'([A-Za-z\s.]+)\s+paid\s+you').firstMatch(title);
    final nameMatchFrom = RegExp(r'from\s+([A-Za-z\s.]+)').firstMatch(title);
    
    final name = nameMatchPaidYou?.group(1)?.trim() ?? nameMatchFrom?.group(1)?.trim();
    
    if (amountMatch != null && name != null) {
       return Transaction(
         id: 'gpay_${_generateId()}',
         amount: double.tryParse(amountMatch.group(1)!.replaceAll(',', '')) ?? 0.0,
         senderName: name,
         timestamp: DateTime.now(),
         status: 'success',
         sourceApp: 'GPay',
         type: 'credit',
       );
    }
    return null;
  }

  static Transaction? _parsePhonePe(String title, String text) {
    // CREDIT: "Received ₹200 from Amit" / "You received ₹200"
    // DEBIT: "Sent ₹200 to Amit" / "You paid ₹200"
    final content = (text.contains('₹') ? text : title).toLowerCase();
    final isCredit = content.contains('received') || content.contains('credited') || content.contains('money added');
    final isDebit = content.contains('sent') || content.contains('paid') || content.contains('debited');
    
    // Skip debit transactions
    if (isDebit && !isCredit) return null;
    
    final amountMatch = RegExp(r'₹\s?([\d.,]+)').firstMatch(content);
    final nameMatch = RegExp(r'from\s+([A-Za-z\s]+)').firstMatch(content);
    
    if (amountMatch != null && nameMatch != null) {
       return Transaction(
         id: 'pe_${_generateId()}',
         amount: double.tryParse(amountMatch.group(1)!.replaceAll(',', '')) ?? 0.0,
         senderName: nameMatch.group(1)!.trim(),
         timestamp: DateTime.now(),
         status: 'success',
         sourceApp: 'PhonePe',
         type: 'credit',
       );
    }
    return null;
  }

  static Transaction? _parsePaytm(String title, String text) {
    // CREDIT: "Received ₹ 50 from Suresh" / "Money added ₹50"
    // DEBIT: "Sent ₹50 to Suresh" / "Payment of ₹50"
    final content = (text.contains('₹') ? text : title).toLowerCase();
    final isCredit = content.contains('received') || content.contains('money added') || content.contains('cashback');
    final isDebit = content.contains('sent') || content.contains('payment of') || content.contains('paid to');
    
    // Skip debit transactions
    if (isDebit && !isCredit) return null;
    
    final amountMatch = RegExp(r'₹\s?([\d.,]+)').firstMatch(content);
    final nameMatch = RegExp(r'from\s+([A-Za-z\s]+)').firstMatch(content);
    
    if (amountMatch != null && nameMatch != null) {
       return Transaction(
         id: 'ptm_${_generateId()}',
         amount: double.tryParse(amountMatch.group(1)!.replaceAll(',', '')) ?? 0.0,
         senderName: nameMatch.group(1)!.trim(),
         timestamp: DateTime.now(),
         status: 'success',
         sourceApp: 'Paytm',
         type: 'credit',
       );
    }
    return null;
  }

  static Transaction? _parseBankApp(String title, String text) {
    // CREDIT: "₹1.00 received via UPI" / "Received Rs.1.00 from"
    // DEBIT: "₹1.00 sent via UPI" / "Debited Rs.1.00"
    final content = '$title $text'.toLowerCase();
    final isCredit = content.contains('received') || content.contains('credited') || content.contains('deposited');
    final isDebit = content.contains('sent') || content.contains('debited') || content.contains('withdrawn');
    
    // Skip debit transactions
    if (isDebit && !isCredit) return null;
    
    final amountMatch = RegExp(r'[₹Rs\.\s]+([\d.,]+)').firstMatch(title) ?? 
                        RegExp(r'[₹Rs\.\s]+([\d.,]+)').firstMatch(text);
    final upiIdMatch = RegExp(r'from\s+([a-zA-Z0-9._-]+@[a-zA-Z]+)').firstMatch(text);
    
    if (amountMatch != null) {
       final sender = upiIdMatch?.group(1) ?? 'Unknown';
       return Transaction(
         id: 'bank_${_generateId()}',
         amount: double.tryParse(amountMatch.group(1)!.replaceAll(',', '')) ?? 0.0,
         senderName: sender,
         timestamp: DateTime.now(),
         status: 'success',
         sourceApp: 'Bank App',
         type: 'credit',
       );
    }
    return null;
  }
}
