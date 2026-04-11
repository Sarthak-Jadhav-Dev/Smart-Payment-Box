import 'package:flutter/services.dart';

class NotificationAccessService {
  static const MethodChannel _channel =
      MethodChannel('com.merchant.assistant/settings');

  static Future<bool> isNotificationEnabled() async {
    try {
      final bool result = await _channel.invokeMethod('isNotificationEnabled');
      return result;
    } catch (e) {
      return false;
    }
  }

  static Future<void> openNotificationSettings() async {
    await _channel.invokeMethod('openNotificationSettings');
  }
}
