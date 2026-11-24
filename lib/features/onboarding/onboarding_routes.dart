import 'package:go_router/go_router.dart';

import '../../core/router/routes.dart';
import 'presentation/screens/academic_profile_screen.dart';
import 'presentation/screens/learning_preferences_screen.dart';
import 'presentation/screens/splash_screen.dart';
import 'presentation/screens/study_routine_screen.dart';
import 'presentation/screens/study_subjects_screen.dart';
import 'presentation/screens/welcome_screen.dart';

/// Splash, welcome and the four onboarding steps (94–99). Top-level routes:
/// the flow pushes each step, so back returns to the previous one.
final onboardingRoutes = <RouteBase>[
  GoRoute(path: Routes.splash, builder: (_, _) => const SplashScreen()),
  GoRoute(path: Routes.welcome, builder: (_, _) => const WelcomeScreen()),
  GoRoute(
    path: Routes.onboardingAcademic,
    builder: (_, _) => const AcademicProfileScreen(),
  ),
  GoRoute(
    path: Routes.onboardingSubjects,
    builder: (_, _) => const StudySubjectsScreen(),
  ),
  GoRoute(
    path: Routes.onboardingPreferences,
    builder: (_, _) => const LearningPreferencesScreen(),
  ),
  GoRoute(
    path: Routes.onboardingRoutine,
    builder: (_, _) => const StudyRoutineScreen(),
  ),
];
