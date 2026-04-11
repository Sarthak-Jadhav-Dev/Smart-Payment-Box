import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/login_screen.dart';
import 'features/dashboard/main_screen.dart';
import 'features/onboarding/onboarding_screen.dart';
import 'providers/auth_provider.dart';
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
    // Connect to MQTT after auth check
    Future.microtask(() async {
      final authState = ref.read(authProvider);
      if (authState.isAuthenticated) {
        ref.read(mqttServiceProvider).connect();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Initialize notification service
    ref.watch(notificationServiceProvider);
    
    // Watch auth state to determine initial route
    final authState = ref.watch(authProvider);
    
    // Determine home screen based on auth state
    Widget homeScreen;
    if (authState.isLoading) {
      homeScreen = const Scaffold(
        body: Center(
          child: CircularProgressIndicator(
            color: AppTheme.accentGreen,
          ),
        ),
      );
    } else if (authState.isFirstTime) {
      homeScreen = const OnboardingScreen();
    } else if (!authState.isAuthenticated) {
      homeScreen = const LoginScreen();
    } else {
      homeScreen = const MainScreen();
    }
    
    return MaterialApp(
      title: 'Smart Merchant Assistant',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: homeScreen,
    );
  }
}
