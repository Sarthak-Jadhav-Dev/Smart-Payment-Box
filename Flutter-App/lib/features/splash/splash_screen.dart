import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lottie/lottie.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../auth/login_screen.dart';
import '../dashboard/main_screen.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    // Wait for animation to play (minimum 3 seconds)
    await Future.delayed(const Duration(seconds: 3));

    if (!mounted) return;

    // Wait for the auth provider to finish loading from SharedPreferences
    // It runs async in its constructor, so we poll until it settles
    AuthState authState = ref.read(authProvider);
    int retries = 0;
    while (authState.isLoading && retries < 10) {
      await Future.delayed(const Duration(milliseconds: 200));
      authState = ref.read(authProvider);
      retries++;
    }

    if (!mounted) return;

    if (authState.isAuthenticated) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const MainScreen()),
      );
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 250,
              height: 250,
              child: Lottie.asset(
                'assets/lottie/brand_new/Fake 3D vector coin.lottie',
                width: 250,
                height: 250,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(
                    Icons.account_balance_wallet,
                    size: 100,
                    color: AppTheme.accentGreen,
                  );
                },
              ),
            ).animate().scale(duration: 800.ms, curve: Curves.easeOutBack),
            const SizedBox(height: 30),
            const Text(
              'Smart Merchant',
              style: TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 36,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ).animate().slideY(begin: 0.5, duration: 600.ms).fadeIn(),
            const SizedBox(height: 8),
            const Text(
              'Manage your payments effortlessly',
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 16,
              ),
            ).animate().slideY(begin: 0.5, duration: 600.ms, delay: 200.ms).fadeIn(),
          ],
        ),
      ),
    );
  }
}
