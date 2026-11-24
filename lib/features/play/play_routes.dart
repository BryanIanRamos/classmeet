import 'package:go_router/go_router.dart';

import '../../core/router/coming_soon_route.dart';
import '../../core/router/routes.dart';
import 'presentation/screens/mistake_bank_screen.dart';
import 'presentation/screens/play_hub_screen.dart';
import 'presentation/screens/question_screen.dart';
import 'presentation/screens/quiz_results_screen.dart';
import 'presentation/screens/quiz_setup_screen.dart';

/// The Play tab (122). Quiz setup, the question run, results and the mistake
/// bank (123–133) are nested under `/play` on the root navigator.
final playBranch = StatefulShellBranch(
  routes: [
    GoRoute(
      path: Routes.play,
      builder: (_, _) => const PlayHubScreen(),
      routes: [
        GoRoute(
          path: 'setup/:quizId',
          parentNavigatorKey: rootNavigatorKey,
          builder: (_, state) =>
              QuizSetupScreen(quizId: state.pathParameters['quizId']!),
        ),
        GoRoute(
          path: 'run/:attemptId',
          parentNavigatorKey: rootNavigatorKey,
          builder: (_, state) =>
              QuestionScreen(attemptId: state.pathParameters['attemptId']!),
        ),
        GoRoute(
          path: 'results/:attemptId',
          parentNavigatorKey: rootNavigatorKey,
          builder: (_, state) =>
              QuizResultsScreen(attemptId: state.pathParameters['attemptId']!),
        ),
        GoRoute(
          path: 'mistakes',
          parentNavigatorKey: rootNavigatorKey,
          builder: (_, _) => const MistakeBankScreen(),
        ),
        comingSoonRoute(
          'battle',
          title: 'Quiz Battle',
          gapId: 'GAP-15',
          parentNavigatorKey: rootNavigatorKey,
        ),
        comingSoonRoute(
          'leaderboard',
          title: 'Class leaderboard',
          gapId: 'GAP-19',
          parentNavigatorKey: rootNavigatorKey,
        ),
        comingSoonRoute(
          'quizzes',
          title: 'My quizzes',
          gapId: 'GAP-19',
          parentNavigatorKey: rootNavigatorKey,
        ),
      ],
    ),
  ],
);
