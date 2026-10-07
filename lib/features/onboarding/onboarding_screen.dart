import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/pondy_logo.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, String>> _slides = [
    {
      'title': 'Find Your Life Partner, The Pondy Way',
      'desc': 'Discover verified brides and grooms from Puducherry and Tamil Nadu with cultural alignment and trust.',
      'icon': 'favorite',
    },
    {
      'title': 'Smart Matching & 10-Porutham',
      'desc': 'Authentic horoscope compatibility, community preferences, and lifestyle matching built specifically for you.',
      'icon': 'stars',
    },
    {
      'title': '100% Privacy & Verified Profiles',
      'desc': 'You have full control over who views your photos and contact information. Safety first, always.',
      'icon': 'security',
    },
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const PondyLogo(size: 32, showText: true, isHorizontal: true),
        actions: [
          TextButton(
            onPressed: () => context.go('/register'),
            child: Text(
              'Skip',
              style: AppTypography.buttonText(color: AppColors.textMuted),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _slides.length,
                onPageChanged: (idx) => setState(() => _currentPage = idx),
                itemBuilder: (context, idx) {
                  final slide = _slides[idx];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 120,
                          height: 120,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.primaryLight,
                          ),
                          child: Icon(
                            idx == 0
                                ? Icons.favorite_rounded
                                : (idx == 1 ? Icons.auto_awesome_rounded : Icons.verified_user_rounded),
                            size: 56,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(height: 36),
                        Text(
                          slide['title']!,
                          textAlign: TextAlign.center,
                          style: AppTypography.titleLarge(),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          slide['desc']!,
                          textAlign: TextAlign.center,
                          style: AppTypography.bodyMedium(color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            // Page dots
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _slides.length,
                (i) => AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: _currentPage == i ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _currentPage == i ? AppColors.primary : Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
            // Action Buttons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  AppButton(
                    text: _currentPage == _slides.length - 1 ? 'Get Started' : 'Next',
                    onPressed: () {
                      if (_currentPage < _slides.length - 1) {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      } else {
                        context.go('/register');
                      }
                    },
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Already have an account? ',
                        style: AppTypography.bodyMedium(color: AppColors.textSecondary),
                      ),
                      InkWell(
                        onTap: () => context.go('/login'),
                        child: const Text(
                          'Login',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
