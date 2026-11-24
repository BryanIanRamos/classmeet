import 'package:go_router/go_router.dart';

import '../../core/router/routes.dart';
import 'presentation/screens/friends_screen.dart';

/// The Friends tab: not designed yet (GAP-06).
final friendsBranch = StatefulShellBranch(
  routes: [
    GoRoute(path: Routes.friends, builder: (_, _) => const FriendsScreen()),
  ],
);
