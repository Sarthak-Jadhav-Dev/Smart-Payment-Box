import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../../core/theme/app_theme.dart';
import '../auth/login_screen.dart';
import 'widgets/onboarding_page.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingPageData> _pages = [
    OnboardingPageData(
      title: 'Smart Merchant Assistant',
      description: 'Your intelligent companion for tracking payments and managing transactions effortlessly.',
      lottieAsset: 'assets/lottie/welcome.json',
      gradientColors: [AppTheme.accentGreen, AppTheme.accentBlue],
    ),
    OnboardingPageData(
      title: 'Auto Payment Detection',
      description: 'Automatically detect UPI payments from GPay, PhonePe, Paytm, and bank apps through notifications.',
      lottieAsset: 'assets/lottie/payments.json',
      gradientColors: [AppTheme.accentBlue, AppTheme.accentPurple],
    ),
    OnboardingPageData(
      title: 'Real-time Sync',
      description: 'Sync payments instantly to your dashboard via MQTT cloud connectivity. Stay updated everywhere.',
      lottieAsset: 'assets/lottie/sync.json',
      gradientColors: [AppTheme.accentPurple, AppTheme.accentGreen],
    ),
    OnboardingPageData(
      title: 'Ready to Start?',
      description: 'Sign in with Google to secure your data and access your payment dashboard.',
      lottieAsset: 'assets/lottie/start.json',
      gradientColors: [AppTheme.accentGreen, AppTheme.success],
      isLastPage: true,
    ),
  ];

  void _onNextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    } else {
      _navigateToLogin();
    }
  }

  void _navigateToLogin() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => const LoginScreen(),
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      body: SafeArea(
        child: Column(
          children: [
            // Skip button
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: _currentPage < _pages.length - 1
                    ? TextButton(
                        onPressed: _navigateToLogin,
                        child: const Text(
                          'Skip',
                          style: TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 16,
                          ),
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
            ),

            // Page content
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemCount: _pages.length,
                itemBuilder: (context, index) {
                  return OnboardingPage(
                    data: _pages[index],
                  );
                },
              ),
            ),

            // Bottom section
            Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                children: [
                  // Page indicator
                  SmoothPageIndicator(
                    controller: _pageController,
                    count: _pages.length,
                    effect: const WormEffect(
                      dotWidth: 10,
                      dotHeight: 10,
                      spacing: 8,
                      dotColor: AppTheme.textMuted,
                      activeDotColor: AppTheme.accentGreen,
                    ),
                  ).animate().fadeIn(delay: 200.ms),

                  const SizedBox(height: 32),

                  // Next/Get Started button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _onNextPage,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _pages[_currentPage].gradientColors[0],
                        foregroundColor: AppTheme.darkBackground,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _currentPage == _pages.length - 1 ? 'Get Started' : 'Next',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          if (_currentPage < _pages.length - 1) ...[
                            const SizedBox(width: 8),
                            const Icon(Icons.arrow_forward, size: 20),
                          ],
                        ],
                      ),
                    ),
                  ).animate().slideY(begin: 0.5, delay: 300.ms).fadeIn(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
