import 'package:go_router/go_router.dart';

import '../../core/router/coming_soon_route.dart';
import '../../core/router/routes.dart';
import 'presentation/screens/create_screen.dart';
import 'presentation/screens/quiz_customize_screen.dart';
import 'presentation/screens/quiz_generating_screen.dart';
import 'presentation/screens/quiz_preview_screen.dart';
import 'presentation/screens/quiz_ready_screen.dart';
import 'presentation/screens/quiz_source_screen.dart';

/// The full Create screen (121) and the quiz wizard (114–118). Top-level, so
/// they cover the shell. The "+" sheet (119/120) is an overlay in the shell,
/// not a route (task 3.2).
final createRoutes = <RouteBase>[
  GoRoute(
    path: Routes.create,
    builder: (_, _) => const CreateScreen(),
    routes: [
      GoRoute(path: 'quiz/source', builder: (_, _) => const QuizSourceScreen()),
      GoRoute(
        path: 'quiz/customize',
        builder: (_, _) => const QuizCustomizeScreen(),
      ),
      GoRoute(
        path: 'quiz/preview',
        builder: (_, _) => const QuizPreviewScreen(),
      ),
      GoRoute(
        path: 'quiz/generating',
        builder: (_, _) => const QuizGeneratingScreen(),
      ),
      GoRoute(path: 'quiz/ready', builder: (_, _) => const QuizReadyScreen()),
      comingSoonRoute('tool/:tool', title: 'Create', gapId: 'GAP-14'),
    ],
  ),
];
