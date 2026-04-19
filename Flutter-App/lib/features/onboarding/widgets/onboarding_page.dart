import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lottie/lottie.dart';
import '../../../core/theme/app_theme.dart';

class OnboardingPageData {
  final String title;
  final String description;
  final String lottieAsset;
  final List<Color> gradientColors;
  final bool isLastPage;

  OnboardingPageData({
    required this.title,
    required this.description,
    required this.lottieAsset,
    required this.gradientColors,
    this.isLastPage = false,
  });
}

class OnboardingPage extends StatelessWidget {
  final OnboardingPageData data;

  const OnboardingPage({
    super.key,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Lottie animation with gradient container
          Container(
            width: 280,
            height: 280,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  data.gradientColors[0].withValues(alpha: 0.2),
                  data.gradientColors[1].withValues(alpha: 0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: data.gradientColors[0].withValues(alpha: 0.3),
                width: 2,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Center(
                child: Lottie.asset(
                  data.lottieAsset,
                  width: 200,
                  height: 200,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    // Fallback icon if Lottie fails to load
                    return Icon(
                      _getIconForPage(data.title),
                      size: 100,
                      color: data.gradientColors[0],
                    );
                  },
                ),
              ),
            ),
          ).animate().scale(delay: 100.ms, duration: 600.ms).fadeIn(),

          const SizedBox(height: 40),

          // Title
          Text(
            data.title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 28,
              fontWeight: FontWeight.bold,
              height: 1.2,
            ),
          ).animate().slideY(begin: 0.3, delay: 200.ms).fadeIn(),

          const SizedBox(height: 16),

          // Description
          Text(
            data.description,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 16,
              height: 1.5,
            ),
          ).animate().slideY(begin: 0.3, delay: 300.ms).fadeIn(),
        ],
      ),
    );
  }

  IconData _getIconForPage(String title) {
    if (title.contains('Welcome') || title.contains('Smart')) {
      return Icons.wallet_rounded;
    } else if (title.contains('Payment') || title.contains('Detection')) {
      return Icons.payments_rounded;
    } else if (title.contains('Sync') || title.contains('Real-time')) {
      return Icons.cloud_sync_rounded;
    } else {
      return Icons.rocket_launch_rounded;
    }
  }
}
