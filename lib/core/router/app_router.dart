import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/application/session_controller.dart';
import '../../features/auth/auth_routes.dart';
import '../../features/create/create_routes.dart';
import '../../features/friends/friends_routes.dart';
import '../../features/home/home_routes.dart';
import '../../features/onboarding/onboarding_routes.dart';
import '../../features/play/play_routes.dart';
import '../../features/profile/profile_routes.dart';
import '../../features/study/study_routes.dart';
import '../dev/dev_routes.dart';
import '../env.dart';
import 'app_shell.dart';
import 'not_found_screen.dart';
import 'onboarding_gate.dart';
import 'routes.dart';

/// The app's router.
///
/// - Tab roots (`/home`, `/study`, `/play`, `/friends`) live in a
///   [StatefulShellRoute], so each tab keeps its own stack and scroll state.
/// - Detail flows sit on the root navigator and cover the bottom nav.
/// - [onboardingGate] keeps users who are not signed in and onboarded out of
///   the tabs; it runs again whenever [sessionProvider] changes.
/// - `/dev/*` exists in debug builds only.
final routerProvider = Provider<GoRouter>((ref) {
  final session = ValueNotifier(ref.read(sessionProvider));
  ref.listen(sessionProvider, (_, next) => session.value = next);

  final router = GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: Env.initialRoute,
    refreshListenable: session,
    redirect: (_, state) => onboardingGate(session.value, state.uri),
    errorBuilder: (_, state) => NotFoundScreen(location: state.uri),
    routes: [
      ...onboardingRoutes,
      ...authRoutes,
      StatefulShellRoute.indexedStack(
        builder: (_, _, navigationShell) =>
            AppShell(navigationShell: navigationShell),
        branches: [homeBranch, studyBranch, playBranch, friendsBranch],
      ),
      ...createRoutes,
      ...profileRoutes,
      if (kDebugMode) ...devRoutes,
    ],
  );
  ref.onDispose(() {
    router.dispose();
    session.dispose();
  });
  return router;
});
