import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../models/transaction.dart';
import '../services/local_storage_service.dart';
import '../services/mqtt_service.dart';
import '../services/api_service.dart';
import 'dart:developer' as developer;

final paymentProvider = StateNotifierProvider<PaymentNotifier, List<Transaction>>((ref) {
  return PaymentNotifier(ref);
});

class PaymentNotifier extends StateNotifier<List<Transaction>> {
  final Ref ref;

  PaymentNotifier(this.ref) : super([]) {
    _loadOfflinePayments();
  }

  void _loadOfflinePayments() {
    final localDb = ref.read(localStorageProvider);
    final offline = localDb.getOfflinePayments();
    state = offline.map((e) => Transaction.fromJson(e)).toList();
  }

  Future<void> addTransaction(Transaction tx) async {
    // 1. Update State
    state = [tx, ...state];

    // 2. Save locally
    final localDb = ref.read(localStorageProvider);
    await localDb.savePayment(tx.toJson());

    // 3. Publish to MQTT (only credit/received payments)
    if (tx.type == 'credit') {
      final mqtt = ref.read(mqttServiceProvider);
      mqtt.publishPayment('{"amount": ${tx.amount}, "sender": "${tx.senderName}", "status": "success", "type": "${tx.type}"}');
      developer.log('Payment published to MQTT: ${tx.amount} from ${tx.senderName}', name: 'PaymentProvider');
    } else {
      developer.log('Debit payment not published to MQTT: ${tx.amount}', name: 'PaymentProvider');
    }

    // 4. Sync to Cloud
    final api = ref.read(apiServiceProvider);
    try {
      await api.post('/sync', data: {'transactions': [tx.toJson()]});
    } catch (e) {
      // It will remain in offline storage
      developer.log('Cloud sync failed for ${tx.id}', error: e);
    }
  }
}
