import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/admin/admin_screen.dart';
import '../../features/auth/providers/auth_state_provider.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/otp_verification_screen.dart';
import '../../features/auth/screens/register_screen_0.dart';
import '../../features/chat/screens/chat_conversation_screen.dart';
import '../../features/home/screens/main_shell.dart';
import '../../features/horoscope/screens/horoscope_screen.dart';
import '../../features/interests/screens/interests_screen.dart';
import '../../features/membership/screens/membership_screen.dart';
import '../../features/notifications/screens/notifications_screen.dart';
import '../../features/onboarding/onboarding_screen.dart';
import '../../features/profile/screens/profile_detail_screen.dart';
import '../../features/profile/screens/profile_edit_screen.dart';
import '../../features/registration/screens/photo_screen.dart';
import '../../features/registration/screens/registration_complete_screen.dart';
import '../../features/registration/screens/review_and_about_screen.dart';
import '../../features/registration/screens/step1_personal_screen.dart';
import '../../features/registration/screens/step2_religion_screen.dart';
import '../../features/registration/screens/step3_location_screen.dart';
import '../../features/registration/screens/step4_professional_screen.dart';
import '../../features/registration/screens/step5_additional_screen.dart';
import '../../features/settings/screens/settings_screen.dart';
import '../../features/shortlist/screens/shortlist_screen.dart';
import '../../features/splash/splash_screen.dart';
import 'route_redirect.dart';

// Helper for horizontal slide transition (300ms easeOutCubic)
CustomTransitionPage<void> buildSlidePage({
  required BuildContext context,
  required GoRouterState state,
  required Widget child,
}) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 300),
    reverseTransitionDuration: const Duration(milliseconds: 300),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final curved = CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
      return SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(1.0, 0.0),
          end: Offset.zero,
        ).animate(curved),
        child: child,
      );
    },
  );
}

// Helper for fade transition
CustomTransitionPage<void> buildFadePage({
  required BuildContext context,
  required GoRouterState state,
  required Widget child,
}) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 250),
    reverseTransitionDuration: const Duration(milliseconds: 250),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(opacity: animation, child: child);
    },
  );
}

final List<RouteBase> appRoutes = [
  GoRoute(
    path: '/',
    name: 'splash',
    builder: (context, state) => const SplashScreen(),
  ),

    GoRoute(
      path: '/onboarding',
      name: 'onboarding',
      pageBuilder: (context, state) => buildFadePage(
        context: context,
        state: state,
        child: const OnboardingScreen(),
      ),
    ),
    GoRoute(
      path: '/login',
      name: 'login',
      pageBuilder: (context, state) => buildSlidePage(
        context: context,
        state: state,
        child: const LoginScreen(),
      ),
    ),
    GoRoute(
      path: '/register',
      name: 'register',
      pageBuilder: (context, state) => buildSlidePage(
        context: context,
        state: state,
        child: const RegisterScreen0(),
      ),
    ),
    GoRoute(
      path: '/register/otp',
      name: 'register_otp',
      pageBuilder: (context, state) => buildSlidePage(
        context: context,
        state: state,
        child: const OtpVerificationScreen(),
      ),
    ),
    GoRoute(
      path: '/register/step1',
      name: 'register_step1',
      pageBuilder: (context, state) => buildSlidePage(
        context: context,
        state: state,
        child: const Step1PersonalScreen(),
      ),
    ),
    GoRoute(
      path: '/register/step2',
      name: 'register_step2',
      pageBuilder: (context, state) => buildSlidePage(
        context: context,
        state: state,
        child: const Step2ReligionScreen(),
      ),
    ),
    GoRoute(
      path: '/register/step3',
      name: 'register_step3',
      pageBuilder: (context, state) => buildSlidePage(
        context: context,
        state: state,
        child: const Step3LocationScreen(),
      ),
    ),
    GoRoute(
      path: '/register/step4',
      name: 'register_step4',
      pageBuilder: (context, state) => buildSlidePage(
        context: context,
        state: state,
        child: const Step4ProfessionalScreen(),
      ),
    ),
    GoRoute(
      path: '/register/step5',
      name: 'register_step5',
      pageBuilder: (context, state) => buildSlidePage(
        context: context,
        state: state,
        child: const Step5AdditionalScreen(),
      ),
    ),
    GoRoute(
      path: '/register/review',
      name: 'register_review',
      pageBuilder: (context, state) => buildSlidePage(
        context: context,
        state: state,
        child: const ReviewAndAboutScreen(),
      ),
    ),
    GoRoute(
      path: '/register/photo',
      name: 'register_photo',
      pageBuilder: (context, state) => buildSlidePage(
        context: context,
        state: state,
        child: const PhotoScreen(),
      ),
    ),
    GoRoute(
      path: '/register/complete',
      name: 'register_complete',
      pageBuilder: (context, state) => buildFadePage(
        context: context,
        state: state,
        child: const RegistrationCompleteScreen(),
      ),
    ),
    GoRoute(
      path: '/home',
      name: 'home',
      pageBuilder: (context, state) => buildFadePage(
        context: context,
        state: state,
        child: const MainShell(initialTab: 0),
      ),
    ),
    GoRoute(
      path: '/matches',
      name: 'matches',
      pageBuilder: (context, state) => buildFadePage(
        context: context,
        state: state,
        child: const MainShell(initialTab: 1),
      ),
    ),
    GoRoute(
      path: '/search',
      name: 'search',
      pageBuilder: (context, state) => buildFadePage(
        context: context,
        state: state,
        child: const MainShell(initialTab: 2),
      ),
    ),
    GoRoute(
      path: '/inbox',
      name: 'inbox',
      pageBuilder: (context, state) => buildFadePage(
        context: context,
        state: state,
        child: const MainShell(initialTab: 3),
      ),
    ),
    GoRoute(
      path: '/profile',
      name: 'profile',
      pageBuilder: (context, state) => buildFadePage(
        context: context,
        state: state,
        child: const MainShell(initialTab: 4),
      ),
    ),
    GoRoute(
      path: '/profile-detail/:id',
      name: 'profile_detail',
      pageBuilder: (context, state) {
        final profileId = state.pathParameters['id'] ?? '';
        return buildSlidePage(
          context: context,
          state: state,
          child: ProfileDetailScreen(profileId: profileId),
        );
      },
    ),
    GoRoute(
      path: '/profile-edit',
      name: 'profile_edit',
      pageBuilder: (context, state) => buildSlidePage(
        context: context,
        state: state,
        child: const ProfileEditScreen(),
      ),
    ),
    GoRoute(
      path: '/interests',
      name: 'interests',
      pageBuilder: (context, state) => buildSlidePage(
        context: context,
        state: state,
        child: const InterestsScreen(),
      ),
    ),
    GoRoute(
      path: '/shortlist',
      name: 'shortlist',
      pageBuilder: (context, state) => buildSlidePage(
        context: context,
        state: state,
        child: const ShortlistScreen(),
      ),
    ),
    GoRoute(
      path: '/notifications',
      name: 'notifications',
      pageBuilder: (context, state) => buildSlidePage(
        context: context,
        state: state,
        child: const NotificationsScreen(),
      ),
    ),
    GoRoute(
      path: '/chat/:partnerId',
      name: 'chat_conversation',
      pageBuilder: (context, state) {
        final pid = state.pathParameters['partnerId'] ?? '';
        return buildSlidePage(
          context: context,
          state: state,
          child: ChatConversationScreen(partnerProfileId: pid),
        );
      },
    ),
    GoRoute(
      path: '/membership',
      name: 'membership',
      pageBuilder: (context, state) => buildSlidePage(
        context: context,
        state: state,
        child: MembershipScreen(
          source: state.uri.queryParameters['source'],
          field: state.uri.queryParameters['field'],
          profileId: state.uri.queryParameters['profile'],
        ),
      ),
    ),
    GoRoute(
      path: '/upgrade',
      name: 'upgrade',
      pageBuilder: (context, state) => buildSlidePage(
        context: context,
        state: state,
        child: MembershipScreen(
          source: state.uri.queryParameters['source'],
          field: state.uri.queryParameters['field'],
          profileId: state.uri.queryParameters['profile'],
        ),
      ),
    ),
    GoRoute(
      path: '/horoscope',
      name: 'horoscope',
      pageBuilder: (context, state) {
        final cid = state.uri.queryParameters['candidateId'];
        return buildSlidePage(
          context: context,
          state: state,
          child: HoroscopeScreen(candidateId: cid),
        );
      },
    ),
    GoRoute(
      path: '/settings',
      name: 'settings',
      pageBuilder: (context, state) => buildSlidePage(
        context: context,
        state: state,
        child: const SettingsScreen(),
      ),
    ),
    GoRoute(
      path: '/admin',
      name: 'admin',
      pageBuilder: (context, state) => buildSlidePage(
        context: context,
        state: state,
        child: const AdminScreen(),
      ),
    ),
  ];

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: appRoutes,
    redirect: (context, state) {
      final isSplash = ref.read(splashCompletedProvider);
      final auth = ref.read(authStateProvider);
      final hasProfile = auth.profile != null && auth.profile!.profileId.isNotEmpty;

      return RouteRedirect.evaluate(
        location: state.matchedLocation,
        isSplashComplete: isSplash,
        hasSeenOnboarding: true, // evaluated by splash after reading prefs
        isAuthenticated: auth.isAuthenticated,
        hasCompletedProfile: hasProfile,
        registrationResumeStep: '/register/step1',
      );
    },
  );
});

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: appRoutes,
  redirect: (context, state) {
    return null;
  },
);

