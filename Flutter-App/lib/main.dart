import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'features/dashboard/main_screen.dart';
import 'services/local_storage_service.dart';
import 'services/mqtt_service.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final container = ProviderContainer();
  final storageService = container.read(localStorageProvider);
  await storageService.init();

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const SmartMerchantApp(),
    ),
  );
}

class SmartMerchantApp extends ConsumerWidget {
  const SmartMerchantApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Initialize notification service
    ref.watch(notificationServiceProvider);

    // Connect to MQTT on app start
    ref.read(mqttServiceProvider).connect();

    return MaterialApp(
      title: 'Smart Merchant Assistant',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const MainScreen(),
    );
  }
}
