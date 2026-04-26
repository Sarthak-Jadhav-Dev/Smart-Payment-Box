import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lottie/lottie.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../../core/theme/app_theme.dart';
import '../dashboard/main_screen.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  bool isLastPage = false;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goToDashboard() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const MainScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.only(bottom: 80),
        child: PageView(
          controller: _pageController,
          onPageChanged: (index) {
            setState(() => isLastPage = index == 2);
          },
          children: [
            _buildSlide(
              title: 'Welcome to Smart Merchant',
              subtitle: 'The best way to track and manage your business payments in one place.',
              lottieAsset: 'assets/lottie/welcome.json', // changed to welcome since login might not look good
            ),
            _buildSlide(
              title: 'Real-time Sync',
              subtitle: 'Your transactions are automatically synced and securely backed up to the cloud.',
              lottieAsset: 'assets/lottie/sync.json',
            ),
            _buildSlide(
              title: 'Fast Payments',
              subtitle: 'Monitor all your incoming UPI payments instantly with voice alerts.',
              lottieAsset: 'assets/lottie/payments.json',
            ),
          ],
        ),
      ),
      bottomSheet: Container(
        color: AppTheme.darkBackground,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        height: 80,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Skip/Previous Button
            TextButton(
              onPressed: () => _pageController.jumpToPage(2),
              child: const Text('SKIP'),
            ),
            
            // Dot Indicator
            SmoothPageIndicator(
              controller: _pageController,
              count: 3,
              effect: const WormEffect(
                spacing: 16,
                dotColor: AppTheme.darkCard,
                activeDotColor: AppTheme.accentGreen,
              ),
              onDotClicked: (index) => _pageController.animateToPage(
                index,
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeIn,
              ),
            ),
            
            // Next/Get Started Button
            isLastPage
                ? ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    ),
                    onPressed: _goToDashboard,
                    child: const Text('START', style: TextStyle(color: Colors.black)),
                  )
                : TextButton(
                    onPressed: () => _pageController.nextPage(
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.easeInOut,
                    ),
                    child: const Text('NEXT'),
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildSlide({
    required String title,
    required String subtitle,
    required String lottieAsset,
  }) {
    return Container(
      color: AppTheme.darkBackground,
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Lottie.asset(
            lottieAsset,
            width: 300,
            height: 300,
            fit: BoxFit.contain,
          ),
          const SizedBox(height: 40),
          Text(
            title,
            style: Theme.of(context).textTheme.displaySmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: AppTheme.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
