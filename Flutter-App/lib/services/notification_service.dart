import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/notification_parser.dart';
import '../providers/payment_provider.dart';

final notificationServiceProvider = Provider((ref) => NotificationService(ref));

class NotificationService {
  final Ref ref;
  static const EventChannel _eventChannel = EventChannel('com.merchant.assistant/notifications');

  NotificationService(this.ref) {
    _eventChannel.receiveBroadcastStream().listen(_onEvent, onError: _onError);
  }

  void _onEvent(dynamic event) {
    final Map<dynamic, dynamic> data = event;
    final packageName = data['packageName'] as String;
    final title = data['title'] as String;
    final text = data['text'] as String;

    print('DEBUG: Received notification');
    print('DEBUG: packageName=$packageName');
    print('DEBUG: title=$title');
    print('DEBUG: text=$text');

    final transaction = NotificationParser.parseNotification(packageName, title, text);
    if (transaction != null) {
      print('DEBUG: Parsed transaction: ${transaction.toJson()}');
      ref.read(paymentProvider.notifier).addTransaction(transaction);
    } else {
      print('DEBUG: Failed to parse transaction');
    }
  }

  void _onError(Object error) {
    print('Notification Service Error: $error');
  }
}
