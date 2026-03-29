import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'payment_provider.dart';

class DashboardState {
  final double totalSales;
  final int transactionCount;
  final double latestPayment;

  DashboardState({
    required this.totalSales,
    required this.transactionCount,
    required this.latestPayment,
  });
}

final dashboardProvider = Provider<DashboardState>((ref) {
  final transactions = ref.watch(paymentProvider);
  
  final now = DateTime.now();
  final todaysTransactions = transactions.where((t) {
    return t.timestamp.year == now.year &&
           t.timestamp.month == now.month &&
           t.timestamp.day == now.day;
  }).toList();

  final totalSales = todaysTransactions.fold<double>(0, (sum, item) => sum + item.amount);
  final count = todaysTransactions.length;
  final latest = transactions.isNotEmpty ? transactions.first.amount : 0.0;

  return DashboardState(
    totalSales: totalSales,
    transactionCount: count,
    latestPayment: latest,
  );
});
