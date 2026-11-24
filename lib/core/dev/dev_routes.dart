import 'package:go_router/go_router.dart';

import 'dev_catalog.dart';
import 'token_gallery.dart';
import 'widget_gallery.dart';

/// Debug-only routes. The router adds them only when `kDebugMode` is true, so
/// release builds drop these routes and their pages. The `/dev` catalog joins
/// these galleries.
final devRoutes = <RouteBase>[
  GoRoute(path: '/dev', builder: (_, _) => const DevCatalog()),
  GoRoute(path: '/dev/tokens', builder: (_, _) => const TokenGallery()),
  GoRoute(path: '/dev/widgets', builder: (_, _) => const WidgetGallery()),
];
