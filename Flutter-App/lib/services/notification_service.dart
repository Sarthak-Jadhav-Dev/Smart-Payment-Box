import 'dart:developer' as developer;
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

    developer.log('Notification received: pkg=$packageName', name: 'NotificationService');
    developer.log('title=$title', name: 'NotificationService');
    developer.log('text=$text', name: 'NotificationService');

    final transaction = NotificationParser.parseNotification(packageName, title, text);
    if (transaction != null) {
      developer.log('Parsed transaction: ${transaction.toJson()}', name: 'NotificationService');
      ref.read(paymentProvider.notifier).addTransaction(transaction);
    } else {
      developer.log('Failed to parse transaction', name: 'NotificationService');
    }
  }

  void _onError(Object error) {
    developer.log('Notification Service Error: $error', name: 'NotificationService', error: error);
  }
}
