import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../dev/dev_routes.dart';
import '../env.dart';

/// The app's router. Feature routes and the tab shell arrive in task 3.1.
final routerProvider = Provider<GoRouter>((ref) {
  final router = GoRouter(
    initialLocation: Env.initialRoute,
    routes: [
      GoRoute(path: '/', builder: (_, _) => const _TempHomeScreen()),
      if (kDebugMode) ...devRoutes,
    ],
  );
  ref.onDispose(router.dispose);
  return router;
});

/// Temporary landing screen until the real routes exist (task 3.1).
class _TempHomeScreen extends StatelessWidget {
  const _TempHomeScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: Text('ClassMeet')));
  }
}
