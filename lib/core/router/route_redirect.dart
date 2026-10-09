/// Pure route redirect evaluation for GoRouter.
/// Guaranteed to terminate in <= 2 steps with no circular loops.
class RouteRedirect {
  static String? evaluate({
    required String location,
    required bool isSplashComplete,
    required bool hasSeenOnboarding,
    required bool isAuthenticated,
    required bool hasCompletedProfile,
    String? registrationResumeStep,
  }) {
    // 1. While splash is still running or DB is initializing, stay on splash screen
    if (!isSplashComplete) {
      if (location == '/') return null;
      return '/';
    }

    // 2. Once splash is complete, we should never stay on splash '/'
    if (location == '/') {
      if (!hasSeenOnboarding) return '/onboarding';
      if (!isAuthenticated) return '/login';
      if (!hasCompletedProfile) return registrationResumeStep ?? '/register/step1';
      return '/home';
    }

    // 3. First run onboarding guard
    if (!hasSeenOnboarding) {
      if (location == '/onboarding') return null;
      return '/onboarding';
    }

    // 4. Unauthenticated user flow
    if (!isAuthenticated) {
      final allowedAuthRoutes = [
        '/login',
        '/register',
        '/register/otp',
        '/onboarding',
      ];
      if (allowedAuthRoutes.contains(location)) return null;
      return '/login';
    }

    // 5. Authenticated but profile incomplete (Registration resume flow)
    if (!hasCompletedProfile) {
      final allowedRegRoutes = [
        '/register/step1',
        '/register/step2',
        '/register/step3',
        '/register/step4',
        '/register/step5',
        '/register/review',
        '/register/photo',
        '/register/complete',
      ];
      if (allowedRegRoutes.contains(location)) return null;
      return registrationResumeStep ?? '/register/step1';
    }

    // 6. Authenticated and profile complete
    final authAndRegRoutes = [
      '/onboarding',
      '/login',
      '/register',
      '/register/otp',
      '/register/step1',
      '/register/step2',
      '/register/step3',
      '/register/step4',
      '/register/step5',
      '/register/review',
      '/register/photo',
    ];
    if (authAndRegRoutes.contains(location)) {
      return '/home';
    }

    // Allow all other authorized routes (e.g. /home, /matches, /profile, /chat, etc.)
    return null;
  }
}
