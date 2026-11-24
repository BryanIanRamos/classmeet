import 'package:go_router/go_router.dart';

import '../../core/router/routes.dart';
import 'presentation/screens/profile_screen.dart';
import 'presentation/screens/settings_screen.dart';

/// Profile and settings, opened from the avatar (GAP-07, task 9.2).
final profileRoutes = <RouteBase>[
  GoRoute(
    path: Routes.profile,
    builder: (_, _) => const ProfileScreen(),
    routes: [
      GoRoute(path: 'settings', builder: (_, _) => const SettingsScreen()),
    ],
  ),
];
