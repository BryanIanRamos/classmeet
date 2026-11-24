import 'package:go_router/go_router.dart';

import 'token_gallery.dart';

/// Debug-only routes. The router adds them only when `kDebugMode` is true, so
/// release builds drop these routes and their pages. The `/dev` catalog and
/// the widget gallery join them in tasks 3.3 and 2.14.
final devRoutes = <RouteBase>[
  GoRoute(path: '/dev/tokens', builder: (_, _) => const TokenGallery()),
];
