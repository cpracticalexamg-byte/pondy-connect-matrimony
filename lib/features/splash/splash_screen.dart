import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/router/route_redirect.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/app_logger.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/pondy_logo.dart';
import '../../data/csv/csv_store.dart';
import '../auth/providers/auth_state_provider.dart';

/// Cold-start splash state notifier tracking whether the splash phase has completed.
final splashCompletedProvider = StateProvider<bool>((ref) => false);

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  late final Animation<double> _logoFade;
  late final Animation<double> _logoScale;
  late final Animation<double> _ringPulse;
  late final Animation<double> _nameSlide;
  late final Animation<double> _matrimonyFade;
  late final Animation<double> _taglineFade;

  int _tapCount = 0;
  bool _hasInitError = false;
  String _errorMessage = '';
  bool _hasAttemptedRetry = false;

  @override
  void initState() {
    super.initState();

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    );

    // 0-500 ms: Logo fades in and scales with easeOutBack
    _logoFade = CurvedAnimation(
      parent: _animController,
      curve: const Interval(0.0, 0.23, curve: Curves.easeIn),
    );
    _logoScale = CurvedAnimation(
      parent: _animController,
      curve: const Interval(0.0, 0.23, curve: Curves.easeOutBack),
    );

    // Subtle ring/glow pulse once around 350-750 ms
    _ringPulse = TweenSequence<double>([
      TweenSequenceItem(tween: Tween<double>(begin: 1.0, end: 1.06).chain(CurveTween(curve: Curves.easeOut)), weight: 50),
      TweenSequenceItem(tween: Tween<double>(begin: 1.06, end: 1.0).chain(CurveTween(curve: Curves.easeIn)), weight: 50),
    ]).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.16, 0.35),
      ),
    );

    // 400-1100 ms: "Pondy Connect" masked slide-up
    _nameSlide = CurvedAnimation(
      parent: _animController,
      curve: const Interval(0.18, 0.50, curve: Curves.easeOutCubic),
    );

    // 900-1500 ms: "MATRIMONY" fade in
    _matrimonyFade = CurvedAnimation(
      parent: _animController,
      curve: const Interval(0.40, 0.70, curve: Curves.easeIn),
    );

    // 1300-1950 ms: Tagline fade in
    _taglineFade = CurvedAnimation(
      parent: _animController,
      curve: const Interval(0.60, 0.90, curve: Curves.easeIn),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _startSplashSequence();
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Respect accessibility reduce motion setting
    final reduceMotion = MediaQuery.of(context).disableAnimations;
    if (reduceMotion && _animController.status == AnimationStatus.forward) {
      _animController.value = 1.0;
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Future<void> _startSplashSequence() async {
    setState(() {
      _hasInitError = false;
      _errorMessage = '';
    });

    final reduceMotion = MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    if (reduceMotion) {
      _animController.value = 1.0;
    } else {
      _animController.forward(from: 0.0);
    }

    // Minimum display time 1.8 seconds for branding appreciation
    final minDisplayFuture = Future.delayed(const Duration(milliseconds: 1800));

    try {
      await Future.wait([
        minDisplayFuture,
        _initializeCoreServices(),
      ]).timeout(const Duration(seconds: 6));

      if (mounted) {
        _navigateAfterSplash();
      }
    } catch (e, stack) {
      AppLogger.error('Splash initialization failed', tag: 'SplashScreen', error: e, stackTrace: stack);
      if (mounted) {
        setState(() {
          _hasInitError = true;
          _errorMessage = 'Could not initialize data safely. Please tap retry to reload.';
        });
      }
    }
  }

  Future<void> _initializeCoreServices() async {
    // 1. Initialize local database and verify integrity
    await CsvStore.instance.initialize();
    await CsvStore.instance.verifyDatabaseIntegrity();

    // 2. Check current authenticated user session
    await ref.read(authStateProvider.notifier).checkCurrentUser();

    // 3. Cache SharedPreferences
    await SharedPreferences.getInstance();
  }

  Future<void> _navigateAfterSplash() async {
    final prefs = await SharedPreferences.getInstance();
    final hasSeenOnboarding = prefs.getBool('has_seen_onboarding') ?? false;
    final authState = ref.read(authStateProvider);

    final isAuthenticated = authState.isAuthenticated;
    final hasProfile = authState.profile != null && authState.profile!.profileId.isNotEmpty;

    ref.read(splashCompletedProvider.notifier).state = true;

    if (!mounted) return;

    final targetRoute = RouteRedirect.evaluate(
      location: '/',
      isSplashComplete: true,
      hasSeenOnboarding: hasSeenOnboarding,
      isAuthenticated: isAuthenticated,
      hasCompletedProfile: hasProfile,
      registrationResumeStep: '/register/step1',
    );

    if (targetRoute != null && mounted) {
      context.go(targetRoute);
    }
  }

  void _retryInit() {
    if (_hasAttemptedRetry) {
      // Direct emergency fallback to onboarding to avoid trapping user
      ref.read(splashCompletedProvider.notifier).state = true;
      context.go('/onboarding');
      return;
    }
    _hasAttemptedRetry = true;
    _startSplashSequence();
  }

  void _onLogoTapped() {
    _tapCount++;
    if (_tapCount >= 7) {
      _tapCount = 0;
      context.push('/admin');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFBF7),
      body: SafeArea(
        child: Stack(
          children: [
            // Background subtle gradient glow
            Positioned.fill(
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFFFFFBF7),
                      Color(0xFFFFF4EC),
                      Color(0xFFFFFBF7),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ),

            if (!_hasInitError)
              Center(
                child: AnimatedBuilder(
                  animation: _animController,
                  builder: (context, _) {
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Animated Logo with Scale, Fade and Pulse
                        FadeTransition(
                          opacity: _logoFade,
                          child: ScaleTransition(
                            scale: _logoScale,
                            child: Transform.scale(
                              scale: _ringPulse.value,
                              child: PondyLogo(
                                size: 120,
                                showText: false,
                                onTap: _onLogoTapped,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Masked Slide-up for App Name "Pondy Connect"
                        ClipRect(
                          child: SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(0.0, 0.6),
                              end: Offset.zero,
                            ).animate(_nameSlide),
                            child: FadeTransition(
                              opacity: _nameSlide,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'Pondy ',
                                    style: AppTypography.titleLarge(color: AppColors.primary).copyWith(
                                      fontSize: 26,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  Text(
                                    'Connect',
                                    style: AppTypography.titleLarge(color: AppColors.chipSelectedStart).copyWith(
                                      fontSize: 26,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),

                        // "MATRIMONY" with wide tracking
                        FadeTransition(
                          opacity: _matrimonyFade,
                          child: const Text(
                            'MATRIMONY',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 3.5,
                              color: AppColors.textMuted,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Tagline
                        FadeTransition(
                          opacity: _taglineFade,
                          child: const Text(
                            'Find your life partner, the Pondy way.',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w400,
                              color: AppColors.textSecondary,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),

            // Error Fallback Screen with Single Retry Button
            if (_hasInitError)
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.cloud_off_rounded,
                        size: 54,
                        color: AppColors.errorRed,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Initialization Failed',
                        style: AppTypography.titleLarge(color: AppColors.textPrimary),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _errorMessage,
                        textAlign: TextAlign.center,
                        style: AppTypography.bodyMedium(color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 24),
                      AppButton(
                        text: _hasAttemptedRetry ? 'Continue to App' : 'Retry',
                        onPressed: _retryInit,
                      ),
                    ],
                  ),
                ),
              ),

            // Bottom subtle branding footer
            Positioned(
              bottom: 24,
              left: 0,
              right: 0,
              child: Center(
                child: FadeTransition(
                  opacity: _taglineFade,
                  child: const Text(
                    'Puducherry & Tamil Nadu • Version 2.0.0',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFFB0A8A0),
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
