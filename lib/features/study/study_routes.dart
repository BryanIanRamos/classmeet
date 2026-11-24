import 'package:go_router/go_router.dart';

import '../../core/router/coming_soon_route.dart';
import '../../core/router/routes.dart';
import 'presentation/screens/add_reviewer_screen.dart';
import 'presentation/screens/course_overview_screen.dart';
import 'presentation/screens/downloads_screen.dart';
import 'presentation/screens/reader_screen.dart';
import 'presentation/screens/study_screen.dart';

/// The Study tab: My Materials and My Classes (92/93, `?tab=classes`).
/// Details (85–91) are nested under `/study` on the root navigator.
final studyBranch = StatefulShellBranch(
  routes: [
    GoRoute(
      path: Routes.study,
      builder: (_, state) => StudyScreen(tab: state.uri.queryParameters['tab']),
      routes: [
        GoRoute(
          path: 'add',
          parentNavigatorKey: rootNavigatorKey,
          builder: (_, _) => const AddReviewerScreen(),
        ),
        GoRoute(
          path: 'downloads',
          parentNavigatorKey: rootNavigatorKey,
          builder: (_, _) => const DownloadsScreen(),
        ),
        GoRoute(
          path: 'course/:courseId',
          parentNavigatorKey: rootNavigatorKey,
          builder: (_, state) =>
              CourseOverviewScreen(courseId: state.pathParameters['courseId']!),
        ),
        GoRoute(
          path: 'reader/:materialId',
          parentNavigatorKey: rootNavigatorKey,
          builder: (_, state) => ReaderScreen(
            materialId: state.pathParameters['materialId']!,
            tab: state.uri.queryParameters['tab'],
          ),
        ),
        comingSoonRoute(
          'tool/:tool',
          title: 'Study tools',
          gapId: 'GAP-12',
          parentNavigatorKey: rootNavigatorKey,
        ),
      ],
    ),
  ],
);
