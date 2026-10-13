import 'package:classmeet/core/router/routes.dart';
import 'package:classmeet/core/session/app_session.dart';
import 'package:go_router/go_router.dart';

final appRouter = GoRouter(
  intitialLocation: Routes.welcome,
  debugDiagnostics: true,

  refreshListenable: appSession,
  redirect: (context, state) {
    final loc = state.matchedLocation;
    final inWelcome = loc.startsWith(Routes.welcome);
    final inOnboarding = loc.startsWith('/onboarding');

    if (appSession.isLoggedIn) {
      return inWelcome ? null : Routes.welcome;
    }

    if (!appSession.onboardingDone) {
      return inOnboarding ? null : Routes.setProfile;
    }

    if (inWelcome || inOnboarding) return Routes.home;

    return null;
  },

  routes: [
    // Welcome + auth 
    GoRoute(
      path: Routes.welcome,
      buidler: (context, state) => const WelcomeScreen();
      routes: [
        GoRoute(
          path: 'login',
          builder: (context, state) => const LoginScreen();
        ),
        GoRoute(
          path: 'signup',
          builder: (context, state) => const SignupScreen();

        )
      ]
    )
   
  ],
);
