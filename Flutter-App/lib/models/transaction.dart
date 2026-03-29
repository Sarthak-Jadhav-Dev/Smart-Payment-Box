class Transaction {
  final String id;
  final double amount;
  final String senderName;
  final DateTime timestamp;
  final String status;
  final String sourceApp;

  Transaction({
    required this.id,
    required this.amount,
    required this.senderName,
    required this.timestamp,
    required this.status,
    required this.sourceApp,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'] as String? ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      senderName: json['senderName'] as String? ?? 'Unknown',
      timestamp: json['timestamp'] != null ? DateTime.tryParse(json['timestamp']) ?? DateTime.now() : DateTime.now(),
      status: json['status'] as String? ?? 'Pending',
      sourceApp: json['sourceApp'] as String? ?? 'Unknown',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'amount': amount,
      'senderName': senderName,
      'timestamp': timestamp.toIso8601String(),
      'status': status,
      'sourceApp': sourceApp,
    };
  }
}
