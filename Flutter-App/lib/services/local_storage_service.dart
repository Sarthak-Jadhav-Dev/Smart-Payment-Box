import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final localStorageProvider = Provider<LocalStorageService>((ref) => LocalStorageService());

class LocalStorageService {
  static const String _paymentsBox = 'paymentsBox';

  Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox(_paymentsBox);
  }

  Box getPaymentsBox() {
    return Hive.box(_paymentsBox);
  }

  Future<void> savePayment(Map<String, dynamic> paymentData) async {
    final box = getPaymentsBox();
    await box.add(paymentData);
  }

  List<Map<String, dynamic>> getOfflinePayments() {
    final box = getPaymentsBox();
    return box.values.map((e) => Map<String, dynamic>.from(e)).toList();
  }
  
  Future<void> clearOfflinePayments() async {
     final box = getPaymentsBox();
     await box.clear();
  }
}
