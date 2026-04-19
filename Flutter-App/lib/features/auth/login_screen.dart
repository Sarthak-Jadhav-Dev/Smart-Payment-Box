import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lottie/lottie.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../dashboard/main_screen.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  @override
  void initState() {
    super.initState();
    // Check if already authenticated
    Future.microtask(() {
      final authState = ref.read(authProvider);
      if (authState.isAuthenticated) {
        _navigateToDashboard();
      }
    });
  }

  void _navigateToDashboard() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => const MainScreen(),
      ),
    );
  }

  Future<void> _signInAsGuest() async {
    await ref.read(authProvider.notifier).signInAsGuest();

    final authState = ref.read(authProvider);
    if (authState.isAuthenticated && mounted) {
      _navigateToDashboard();
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    // Listen to auth errors and show snackbar reactively
    ref.listen<AuthState>(authProvider, (previous, next) {
      if (next.error != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.error!),
            backgroundColor: AppTheme.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
        ref.read(authProvider.notifier).clearError();
      }
    });

    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),

              // Logo/Animation
              Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppTheme.accentGreen.withValues(alpha: 0.2),
                      AppTheme.accentBlue.withValues(alpha: 0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: AppTheme.accentGreen.withValues(alpha: 0.3),
                    width: 2,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: Center(
                    child: Lottie.asset(
                      'assets/lottie/login.json',
                      width: 150,
                      height: 150,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(
                          Icons.account_circle_rounded,
                          size: 80,
                          color: AppTheme.accentGreen,
                        );
                      },
                    ),
                  ),
                ),
              ).animate().scale(delay: 100.ms, duration: 600.ms).fadeIn(),

              const SizedBox(height: 40),

              // Title
              const Text(
                'Welcome Back!',
                style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ).animate().slideY(begin: 0.3, delay: 200.ms).fadeIn(),

              const SizedBox(height: 12),

              // Subtitle
              const Text(
                'Sign in to access your payment dashboard and track your transactions securely.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 16,
                  height: 1.5,
                ),
              ).animate().slideY(begin: 0.3, delay: 300.ms).fadeIn(),

              const Spacer(),

              // Google Sign In Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: authState.isLoading ? null : _signInAsGuest,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppTheme.darkBackground,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: authState.isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppTheme.darkBackground,
                            ),
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.person_outline,
                              color: AppTheme.darkBackground,
                            ),
                            const SizedBox(width: 12),
                            const Text(
                              'Continue as Guest',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.darkBackground,
                              ),
                            ),
                          ],
                        ),
                ),
              ).animate().slideY(begin: 0.5, delay: 400.ms).fadeIn(),

              const SizedBox(height: 24),

              // Terms text
              const Text(
                'By signing in, you agree to our Terms of Service and Privacy Policy',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppTheme.textMuted,
                  fontSize: 12,
                ),
              ).animate().fadeIn(delay: 500.ms),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
