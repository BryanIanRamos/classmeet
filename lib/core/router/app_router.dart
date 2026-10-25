// =============================================================================
// app_router.dart
//
// This file defines the app's entire navigation map using the go_router package.
// It answers two questions:
//   1. "What screen should show for a given URL path?"  -> the `routes` list
//   2. "Is the user ALLOWED to be on that path right now?" -> the `redirect` guard
//
// The flow it enforces:
//   Logged out              -> only /welcome, /welcome/login, /welcome/signup
//   Logged in, not set up   -> only /onboarding/... screens
//   Logged in + set up      -> the main app (bottom-nav tabs: home/study/play/friends)
//
// `appRouter` is plugged into the app via `routerConfig: appRouter` in app.dart.
// =============================================================================

// The global login/onboarding state object (a ChangeNotifier). The router reads
// it to decide redirects and listens to it so it re-checks when it changes.
import 'package:classmeet/core/session/app_session.dart';
// Auth screens shown under /welcome.
import 'package:classmeet/features/auth/login_screen.dart';
import 'package:classmeet/features/auth/signup_screen.dart';
// The four main-app tab screens.
import 'package:classmeet/features/home/friends/friend_screen.dart';
import 'package:classmeet/features/home/home_screen.dart';
import 'package:classmeet/features/home/play/play_screen.dart';
import 'package:classmeet/features/home/study/study_screen.dart';
// The onboarding (first-time setup) screens.
import 'package:classmeet/features/onboarding/privacy_consent_screen.dart';
import 'package:classmeet/features/onboarding/pick_subject.dart';
import 'package:classmeet/features/onboarding/set_profile.dart';
import 'package:classmeet/features/onboarding/study_style_screen.dart';
// The wrapper widget that draws the bottom navigation bar around the tabs.
import 'package:classmeet/features/shell/main_shell.dart';
// The first screen a logged-out user sees.
import 'package:classmeet/features/welcome/welcome_screen.dart';
// The routing package itself (GoRouter, GoRoute, StatefulShellRoute, ...).
import 'package:go_router/go_router.dart';
// Our list of path strings (e.g. Routes.home == '/home') so we never typo a path.
import 'routes.dart';

// A single, app-wide router instance. `final` = created once, never reassigned.
final appRouter = GoRouter(
  // The path the app opens on when it first launches.
  initialLocation: Routes.welcome,
  // Prints every navigation + redirect to the debug console. Great for learning;
  // turn it off (or set to kDebugMode) before release.
  debugLogDiagnostics: true,

  // GoRouter subscribes to appSession. Whenever appSession calls
  // notifyListeners() (logIn / completeOnboarding / logOut), the router
  // re-runs `redirect` below — so logging in automatically moves you forward
  // without you calling context.go() yourself.
  refreshListenable: appSession,

  // The "route guard". Runs before EVERY navigation (and on every refresh).
  // Return a path string -> send the user there instead.
  // Return null       -> allow the navigation as-is.
  redirect: (context, state) {
    // The path the user is trying to reach, e.g. '/welcome/login'.
    final loc = state.matchedLocation;
    // True for '/welcome', '/welcome/login', '/welcome/signup'.
    final inWelcome = loc.startsWith(Routes.welcome);
    // True for any '/onboarding/...' screen.
    final inOnboarding = loc.startsWith('/onboarding');

    // Rule 1: Not logged in? You may only be in the welcome/auth area.
    if (!appSession.isLoggedIn) {
      // Already there -> allow (null). Anywhere else -> kick to /welcome.
      return inWelcome ? null : Routes.welcome;
    }

    // Rule 2: Logged in but hasn't finished setup? You may only be in onboarding.
    if (!appSession.onboardingDone) {
      // Already in onboarding -> allow. Anywhere else -> start at profile setup.
      return inOnboarding ? null : Routes.setProfile;
    }

    // Rule 3: Fully set up. Don't let them go back to welcome/onboarding;
    // send them to the main app instead.
    if (inWelcome || inOnboarding) {
      return Routes.home;
    }

    // Nothing to fix — let the navigation happen.
    return null;
  },

  // The full list of screens the app knows about, and which path maps to which.
  routes: [
    // Welcome + Auth
    // Parent route: '/welcome' shows WelcomeScreen.
    GoRoute(
      path: Routes.welcome,
      // `builder` returns the widget to display for this path.
      builder: (context, state) => const WelcomeScreen(),
      // Child routes. Their paths are RELATIVE (no leading '/'), so they are
      // joined to the parent: '/welcome' + 'login' = '/welcome/login'.
      // Child screens stack ON TOP of the parent, so the back button returns
      // to WelcomeScreen.
      routes: [
        GoRoute(
          path: 'login', // -> /welcome/login (matches Routes.login)
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: 'signup', // -> /welcome/signup (matches Routes.signup)
          builder: (context, state) => const SignupScreen(),
        ),
      ],
    ),

    // Onboarding flat routes
    // "Flat" = each is its own top-level route (not nested), so moving between
    // them with context.go() REPLACES the screen rather than stacking it.
    GoRoute(
      path: Routes.setProfile, // '/onboarding/profile' — step 1
      builder: (context, state) => const SetProfileScreen(),
    ),
    GoRoute(
      path: Routes.pickSubject, // '/onboarding/subjects' — step 2
      builder: (context, state) => const SetPickSubjectScreen(),
    ),
    GoRoute(
      path: Routes.studyStyle, // '/onboarding/study-style' — step 3
      builder: (context, state) => const StudyStyleScreen(),
    ),
    GoRoute(
      path: Routes.privacyConsent, // '/onboarding/consent' — final step
      builder: (context, state) => const PrivacyConsentScreen(),
    ),

    // Main app with bottom navigation.
    // StatefulShellRoute = a persistent "shell" (the bottom nav bar) that stays
    // on screen while the content area swaps between tabs.
    // `.indexedStack` keeps every tab alive in an IndexedStack, so each tab
    // remembers its scroll position / state when you switch away and back.
    StatefulShellRoute.indexedStack(
      // Builds the shell. `navigationShell` is the currently-selected tab's
      // content; MainShell places it above the bottom nav bar and uses
      // navigationShell.goBranch(i) to switch tabs.
      builder: (context, state, navigationShell) =>
          MainShell(navigationShell: navigationShell),
      // Each branch = one tab, with its OWN navigation history. Order matters:
      // index 0 is the first tab in the bottom bar, index 1 the second, etc.
      branches: [
        // Tab 0: Home
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: Routes.home, // '/home'
              builder: (context, state) => const HomeScreen(),
            ),
          ],
        ),
        // Tab 1: Study
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: Routes.study, // '/study'
              builder: ((context, state) => const StudyScreen()),
            ),
          ],
        ),
        // Tab 2: Play
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: Routes.play, // '/play'
              builder: (context, state) => const PlayScreen(),
            ),
          ],
        ),
        // Tab 3: Friends
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: Routes.friends, // '/friends'
              builder: (context, state) => const FriendScreen(),
            ),
          ],
        ),
      ],
    ),
  ],
);
