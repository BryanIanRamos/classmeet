import 'package:flutter/widgets.dart';

/// The root navigator. Full-screen routes (detail flows without the bottom
/// nav) set it as their `parentNavigatorKey`, so they cover the tab shell.
final rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');

/// Every app path, so screens navigate with `context.push(Routes.search)`
/// instead of string literals. Paths with parameters are functions.
///
/// The route tree itself lives in the features' `<feature>_routes.dart` files,
/// which use the matching relative segments; `test/core/router` checks that
/// every path here resolves to a screen.
abstract final class Routes {
  // Onboarding and auth (no shell).
  static const splash = '/splash';
  static const welcome = '/welcome';
  static const signUp = '/signup';
  static const login = '/login';
  static const forgotPassword = '/forgot-password';
  static const carsuSignIn = '/auth/carsu';
  static const terms = '/legal/terms';
  static const privacy = '/legal/privacy';
  static const onboardingAcademic = '/onboarding/academic';
  static const onboardingSubjects = '/onboarding/subjects';
  static const onboardingPreferences = '/onboarding/preferences';
  static const onboardingRoutine = '/onboarding/routine';

  // Home tab.
  static const home = '/home';
  static const notifications = '/home/notifications';
  static const search = '/home/search';
  static const joinClass = '/home/join';
  static const talonCredits = '/home/talons';
  static const rewardsHistory = '/home/talons/history';
  static const dailyQuiz = '/home/daily-quiz';
  static const weeklySurvey = '/home/survey';
  static const streak = '/home/streak';
  static const studyPlan = '/home/study-plan';

  // Study tab.
  static const study = '/study';
  static const studyClasses = '/study?tab=classes';
  static const addReviewer = '/study/add';
  static const downloads = '/study/downloads';
  static String course(String courseId) => '/study/course/$courseId';
  static String reader(String materialId, {String? tab}) =>
      '/study/reader/$materialId${tab == null ? '' : '?tab=$tab'}';
  static String studyTool(String tool) => '/study/tool/$tool';

  // Create (full-screen; the "+" sheet is an overlay in the shell).
  static const create = '/create';
  static const quizSource = '/create/quiz/source';
  static const quizCustomize = '/create/quiz/customize';
  static const quizPreview = '/create/quiz/preview';
  static const quizGenerating = '/create/quiz/generating';
  static const quizReady = '/create/quiz/ready';
  static String createTool(String tool) => '/create/tool/$tool';

  // Play tab.
  static const play = '/play';
  static const mistakeBank = '/play/mistakes';
  static const quizBattle = '/play/battle';
  static const leaderboard = '/play/leaderboard';
  static const myQuizzes = '/play/quizzes';
  static String quizSetup(String quizId) => '/play/setup/$quizId';
  static String question(String attemptId) => '/play/run/$attemptId';
  static String quizResults(String attemptId) => '/play/results/$attemptId';

  // Friends tab and profile.
  static const friends = '/friends';
  static const profile = '/profile';
  static const settings = '/profile/settings';

  /// Paths that need the user to be signed in and onboarded (the tab shell
  /// and every detail flow). Onboarding, auth and `/dev` stay open.
  static const gatedPrefixes = [home, study, create, play, friends, profile];
}
