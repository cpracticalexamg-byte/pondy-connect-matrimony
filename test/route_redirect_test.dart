import 'package:flutter_test/flutter_test.dart';
import 'package:pondy_connect_matrimony/core/router/route_redirect.dart';

void main() {
  group('RouteRedirect Termination & Circular Loop Tests', () {
    final candidateRoutes = [
      '/',
      '/onboarding',
      '/login',
      '/register',
      '/register/otp',
      '/register/step1',
      '/register/step3',
      '/register/complete',
      '/home',
      '/matches',
      '/search',
      '/profile',
      '/admin',
    ];

    final booleanPermutations = [
      // isSplashComplete, hasSeenOnboarding, isAuthenticated, hasCompletedProfile
      [false, false, false, false],
      [false, true, true, true],
      [true, false, false, false], // New user cold start
      [true, true, false, false],  // Returning logged out user
      [true, true, true, false],   // Logged in with incomplete profile
      [true, true, true, true],    // Logged in with complete profile
    ];

    for (final perm in booleanPermutations) {
      final isSplash = perm[0];
      final hasSeenOnboarding = perm[1];
      final isAuth = perm[2];
      final hasProfile = perm[3];

      test('Terminates in <= 2 redirects for state: splash=$isSplash, onboarding=$hasSeenOnboarding, auth=$isAuth, profile=$hasProfile', () {
        for (final startRoute in candidateRoutes) {
          int redirectCount = 0;
          String currentRoute = startRoute;
          final visited = <String>{currentRoute};

          while (redirectCount < 5) {
            final nextRoute = RouteRedirect.evaluate(
              location: currentRoute,
              isSplashComplete: isSplash,
              hasSeenOnboarding: hasSeenOnboarding,
              isAuthenticated: isAuth,
              hasCompletedProfile: hasProfile,
              registrationResumeStep: '/register/step1',
            );

            if (nextRoute == null) {
              // Reached terminal route
              break;
            }

            redirectCount++;
            currentRoute = nextRoute;
            expect(visited.contains(currentRoute), isFalse,
                reason: 'Circular redirect detected from $startRoute into $currentRoute');
            visited.add(currentRoute);
          }

          expect(redirectCount, lessThanOrEqualTo(2),
              reason: 'Start route $startRoute took more than 2 redirects ($redirectCount) to settle.');
        }
      });
    }

    test('Splash redirect behaviors specifically verified', () {
      // 1. Splash not complete -> always stay on '/'
      expect(
        RouteRedirect.evaluate(
          location: '/',
          isSplashComplete: false,
          hasSeenOnboarding: false,
          isAuthenticated: false,
          hasCompletedProfile: false,
        ),
        isNull,
      );

      // 2. Splash complete, first run -> redirects to '/onboarding'
      expect(
        RouteRedirect.evaluate(
          location: '/',
          isSplashComplete: true,
          hasSeenOnboarding: false,
          isAuthenticated: false,
          hasCompletedProfile: false,
        ),
        equals('/onboarding'),
      );

      // 3. Splash complete, returning unauthenticated -> redirects to '/login'
      expect(
        RouteRedirect.evaluate(
          location: '/',
          isSplashComplete: true,
          hasSeenOnboarding: true,
          isAuthenticated: false,
          hasCompletedProfile: false,
        ),
        equals('/login'),
      );

      // 4. Splash complete, logged in incomplete profile -> redirects to resume step
      expect(
        RouteRedirect.evaluate(
          location: '/',
          isSplashComplete: true,
          hasSeenOnboarding: true,
          isAuthenticated: true,
          hasCompletedProfile: false,
          registrationResumeStep: '/register/step3',
        ),
        equals('/register/step3'),
      );

      // 5. Splash complete, logged in with complete profile -> redirects to '/home'
      expect(
        RouteRedirect.evaluate(
          location: '/',
          isSplashComplete: true,
          hasSeenOnboarding: true,
          isAuthenticated: true,
          hasCompletedProfile: true,
        ),
        equals('/home'),
      );
    });
  });
}
