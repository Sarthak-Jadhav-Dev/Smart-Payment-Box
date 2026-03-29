import '../models/transaction.dart';

class NotificationParser {
  static Transaction? parseNotification(String packageName, String title, String text) {
    final lowerPkg = packageName.toLowerCase();
    if (lowerPkg.contains('com.google.android.apps.nbu.paisa.user') || lowerPkg.contains('gpay')) {
        return _parseGPay(text);
    } else if (lowerPkg.contains('com.phonepe.app') || lowerPkg.contains('phonepe')) {
        return _parsePhonePe(text);
    } else if (lowerPkg.contains('net.one97.paytm') || lowerPkg.contains('paytm')) {
        return _parsePaytm(text);
    }
    return null;
  }

  static String _generateId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }

  static Transaction? _parseGPay(String text) {
    // Example: "₹150.00 received from Rahul"
    final amountMatch = RegExp(r'₹\s?([\d.,]+)').firstMatch(text);
    final nameMatch = RegExp(r'from\s+([A-Za-z\s]+)').firstMatch(text);
    
    if (amountMatch != null && nameMatch != null) {
       return Transaction(
         id: 'gpay_${_generateId()}',
         amount: double.tryParse(amountMatch.group(1)!.replaceAll(',', '')) ?? 0.0,
         senderName: nameMatch.group(1)!.trim(),
         timestamp: DateTime.now(),
         status: 'success',
         sourceApp: 'GPay'
       );
    }
    return null;
  }

  static Transaction? _parsePhonePe(String text) {
    // Example: "Received ₹200 from Amit"
    final amountMatch = RegExp(r'₹\s?([\d.,]+)').firstMatch(text);
    final nameMatch = RegExp(r'from\s+([A-Za-z\s]+)').firstMatch(text);
    
    if (amountMatch != null && nameMatch != null) {
       return Transaction(
         id: 'pe_${_generateId()}',
         amount: double.tryParse(amountMatch.group(1)!.replaceAll(',', '')) ?? 0.0,
         senderName: nameMatch.group(1)!.trim(),
         timestamp: DateTime.now(),
         status: 'success',
         sourceApp: 'PhonePe'
       );
    }
    return null;
  }

  static Transaction? _parsePaytm(String text) {
    // Example: "Received ₹ 50 from Suresh"
    final amountMatch = RegExp(r'₹\s?([\d.,]+)').firstMatch(text);
    final nameMatch = RegExp(r'from\s+([A-Za-z\s]+)').firstMatch(text);
    
    if (amountMatch != null && nameMatch != null) {
       return Transaction(
         id: 'ptm_${_generateId()}',
         amount: double.tryParse(amountMatch.group(1)!.replaceAll(',', '')) ?? 0.0,
         senderName: nameMatch.group(1)!.trim(),
         timestamp: DateTime.now(),
         status: 'success',
         sourceApp: 'Paytm'
       );
    }
    return null;
  }
}
