import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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

class SmartMerchantApp extends ConsumerStatefulWidget {
  const SmartMerchantApp({super.key});

  @override
  ConsumerState<SmartMerchantApp> createState() => _SmartMerchantAppState();
}

class _SmartMerchantAppState extends ConsumerState<SmartMerchantApp> {
  @override
  void initState() {
    super.initState();
    // Connect to MQTT
    Future.microtask(() => ref.read(mqttServiceProvider).connect());
  }

  @override
  Widget build(BuildContext context) {
    // Initialize notification service
    ref.watch(notificationServiceProvider);
    
    return MaterialApp(
      title: 'Smart Merchant Assistant',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF00FF9D),
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: const Color(0xFF16213E),
      ),
      home: const MainScreen(),
    );
  }
}
