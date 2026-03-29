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

    final transaction = NotificationParser.parseNotification(packageName, title, text);
    if (transaction != null) {
      ref.read(paymentProvider.notifier).addTransaction(transaction);
    }
  }

  void _onError(Object error) {
    print('Notification Service Error: $error');
  }
}
