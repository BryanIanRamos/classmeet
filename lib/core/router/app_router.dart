import 'package:classmeet/core/session/app_session.dart';
import 'package:classmeet/features/auth/login_screen.dart';
import 'package:classmeet/features/auth/signup_screen.dart';
import 'package:classmeet/features/home/friends/friend_screen.dart';
import 'package:classmeet/features/home/home_screen.dart';
import 'package:classmeet/features/home/play/play_screen.dart';
import 'package:classmeet/features/home/study/study_screen.dart';
import 'package:classmeet/features/onboarding/privacy_consent.dart';
import 'package:classmeet/features/onboarding/set_pick_subject.dart';
import 'package:classmeet/features/onboarding/set_profile.dart';
import 'package:classmeet/features/onboarding/study_style.dart';
import 'package:classmeet/features/shell/main_shell.dart';
import 'package:classmeet/features/welcome/welcome_screen.dart';
import 'package:go_router/go_router.dart';
import 'routes.dart';

final appRouter = GoRouter(
  initialLocation: Routes.welcome,
  debugLogDiagnostics: true,

  refreshListenable: appSession,

  redirect: (context, state) {
    final loc = state.matchedLocation;
    final inWelcome = loc.startsWith(Routes.welcome);
    final inOnboarding = loc.startsWith('/onboarding');

    if (!appSession.isLoggedIn) {
      return inWelcome ? null : Routes.welcome;
    }

    if (!appSession.onboardingDone) {
      return inOnboarding ? null : Routes.setProfile;
    }

    if (inWelcome || inOnboarding) {
      return Routes.home;
    }

    return null;
  },

  routes: [
    // Welcome + Auth
    GoRoute(
      path: Routes.welcome,
      builder: (context, state) => const WelcomeScreen(),
      routes: [
        GoRoute(
          path: 'login',
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: 'signup',
          builder: (context, state) => const SignupScreen(),
        ),
      ],
    ),

    // Onboarding flat routes
    GoRoute(
      path: Routes.setProfile,
      builder: (context, state) => const SetProfileScreen(),
    ),
    GoRoute(
      path: Routes.pickSubject,
      builder: (context, state) => const SetPickSubjectScreen(),
    ),
    GoRoute(
      path: Routes.studyStyle,
      builder: (context, state) => const StudyStyleScreen(),
    ),
    GoRoute(
      path: Routes.privacyConsent,
      builder: (context, state) => const PrivacyConsentScreen(),
    ),

    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) =>
          MainShell(navigationShell: navigationShell),
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: Routes.home,
              builder: (context, state) => const HomeScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: Routes.study,
              builder: ((context, state) => const StudyScreen()),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: Routes.play,
              builder: (context, state) => const PlayScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: Routes.friends,
              builder: (context, state) => const FriendScreen(),
            ),
          ],
        ),
      ],
    ),
  ],
);
