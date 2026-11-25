import 'package:go_router/go_router.dart';

import '../../core/router/coming_soon_route.dart';
import '../../core/router/routes.dart';
import 'presentation/screens/daily_quiz_screen.dart';
import 'presentation/screens/home_dashboard_screen.dart';
import 'presentation/screens/join_class_screen.dart';
import 'presentation/screens/notifications_screen.dart';
import 'presentation/screens/search_screen.dart';
import 'presentation/screens/talon_credits_screen.dart';
import 'presentation/screens/weekly_survey_screen.dart';

/// The Home tab (8). Its details (11–16) are nested under `/home`, so a deep
/// link keeps Home underneath, but open on the root navigator: none of them
/// shows the bottom nav.
final homeBranch = StatefulShellBranch(
  routes: [
    GoRoute(
      path: Routes.home,
      builder: (_, _) => const HomeDashboardScreen(),
      routes: [
        GoRoute(
          path: 'notifications',
          parentNavigatorKey: rootNavigatorKey,
          builder: (_, _) => const NotificationsScreen(),
        ),
        GoRoute(
          path: 'search',
          parentNavigatorKey: rootNavigatorKey,
          // `?q=` pre-fills the query.
          builder: (_, state) =>
              SearchScreen(initialQuery: state.uri.queryParameters['q']),
        ),
        GoRoute(
          path: 'join',
          parentNavigatorKey: rootNavigatorKey,
          builder: (_, _) => const JoinClassScreen(),
          routes: [
            // QR scanning arrives with mobile_scanner in task 10.4.
            comingSoonRoute(
              'scan',
              title: 'Scan a class QR code',
              gapId: 'GAP-25',
              parentNavigatorKey: rootNavigatorKey,
            ),
          ],
        ),
        GoRoute(
          path: 'talons',
          parentNavigatorKey: rootNavigatorKey,
          builder: (_, _) => const TalonCreditsScreen(),
          routes: [
            comingSoonRoute(
              'history',
              title: 'Rewards history',
              gapId: 'GAP-10',
              parentNavigatorKey: rootNavigatorKey,
            ),
          ],
        ),
        GoRoute(
          path: 'daily-quiz',
          parentNavigatorKey: rootNavigatorKey,
          builder: (_, _) => const DailyQuizScreen(),
        ),
        GoRoute(
          path: 'survey',
          parentNavigatorKey: rootNavigatorKey,
          builder: (_, _) => const WeeklySurveyScreen(),
        ),
        comingSoonRoute(
          'streak',
          title: 'Study streak',
          gapId: 'GAP-08',
          parentNavigatorKey: rootNavigatorKey,
        ),
        comingSoonRoute(
          'study-plan',
          title: 'Study plan',
          gapId: 'GAP-09',
          parentNavigatorKey: rootNavigatorKey,
        ),
      ],
    ),
  ],
);
