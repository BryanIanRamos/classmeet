import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import '../widgets/feedback/coming_soon_screen.dart';

/// A route to [ComingSoonScreen] for a path the design links to but does not
/// design yet (the gap register's GAP-* rows). [path] is relative when the
/// route is nested. Set [parentNavigatorKey] to the root key for routes under
/// a tab, so the placeholder covers the bottom nav like the other details.
GoRoute comingSoonRoute(
  String path, {
  required String title,
  required String gapId,
  GlobalKey<NavigatorState>? parentNavigatorKey,
  List<RouteBase> routes = const [],
}) {
  return GoRoute(
    path: path,
    parentNavigatorKey: parentNavigatorKey,
    builder: (_, _) => ComingSoonScreen(title: title, gapId: gapId),
    routes: routes,
  );
}
