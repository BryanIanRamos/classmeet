import 'package:classmeet/app.dart';
import 'package:classmeet/core/router/app_bottom_nav.dart';
import 'package:classmeet/core/router/app_router.dart';
import 'package:classmeet/core/router/not_found_screen.dart';
import 'package:classmeet/core/router/routes.dart';
import 'package:classmeet/core/widgets/buttons/app_button.dart';
import 'package:classmeet/core/widgets/inputs/app_text_field.dart';
import 'package:classmeet/features/auth/application/session_controller.dart';
import 'package:classmeet/features/auth/presentation/screens/sign_up_screen.dart';
import 'package:classmeet/features/home/presentation/screens/home_dashboard_screen.dart';
import 'package:classmeet/features/onboarding/presentation/screens/academic_profile_screen.dart';
import 'package:classmeet/features/onboarding/presentation/screens/splash_screen.dart';
import 'package:classmeet/features/onboarding/presentation/screens/study_routine_screen.dart';
import 'package:classmeet/features/onboarding/presentation/screens/welcome_screen.dart';
import 'package:classmeet/features/play/presentation/screens/play_hub_screen.dart';
import 'package:classmeet/features/study/presentation/screens/reader_screen.dart';
import 'package:classmeet/features/study/presentation/screens/study_screen.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

/// Pumps the app with the session starting at [status]. Returns the
/// container, so tests can read the router and the session.
Future<ProviderContainer> pumpApp(
  WidgetTester tester, {
  SessionStatus status = SessionStatus.ready,
}) async {
  final container = ProviderContainer(
    overrides: [initialSessionStatusProvider.overrideWithValue(status)],
  );
  addTearDown(container.dispose);
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: const ClassMeetApp(),
    ),
  );
  await tester.pumpAndSettle();
  return container;
}

GoRouter routerOf(ProviderContainer container) =>
    container.read(routerProvider);

String currentLocation(ProviderContainer container) =>
    routerOf(container).routerDelegate.currentConfiguration.uri.toString();

Future<void> goTo(
  WidgetTester tester,
  ProviderContainer container,
  String location,
) async {
  routerOf(container).go(location);
  await tester.pumpAndSettle();
}

/// Every path the app links to, with sample parameters.
final allPaths = [
  Routes.splash,
  Routes.welcome,
  Routes.signUp,
  Routes.login,
  Routes.forgotPassword,
  Routes.carsuSignIn,
  Routes.terms,
  Routes.privacy,
  Routes.onboardingAcademic,
  Routes.onboardingSubjects,
  Routes.onboardingPreferences,
  Routes.onboardingRoutine,
  Routes.home,
  Routes.notifications,
  Routes.search,
  Routes.joinClass,
  Routes.talonCredits,
  Routes.rewardsHistory,
  Routes.dailyQuiz,
  Routes.weeklySurvey,
  Routes.streak,
  Routes.studyPlan,
  Routes.study,
  Routes.studyClasses,
  Routes.addReviewer,
  Routes.downloads,
  Routes.course('ite13'),
  Routes.reader('week-1'),
  Routes.reader('week-1', tab: 'listen'),
  Routes.studyTool('flashcards'),
  Routes.create,
  Routes.quizSource,
  Routes.quizCustomize,
  Routes.quizPreview,
  Routes.quizGenerating,
  Routes.quizReady,
  Routes.createTool('flashcards'),
  Routes.play,
  Routes.mistakeBank,
  Routes.quizBattle,
  Routes.leaderboard,
  Routes.myQuizzes,
  Routes.quizSetup('intro-computing'),
  Routes.question('attempt-1'),
  Routes.quizResults('attempt-1'),
  Routes.friends,
  Routes.profile,
  Routes.settings,
];

void main() {
  testWidgets('every app path opens a screen, without redirects', (
    tester,
  ) async {
    final container = await pumpApp(tester);
    for (final path in allPaths) {
      await goTo(tester, container, path);
      expect(tester.takeException(), isNull, reason: path);
      expect(find.byType(NotFoundScreen), findsNothing, reason: path);
      expect(currentLocation(container), path, reason: path);
    }
  });

  testWidgets('route parameters reach the screen', (tester) async {
    final container = await pumpApp(tester);
    await goTo(tester, container, Routes.reader('week-2', tab: 'visual'));
    final reader = tester.widget<ReaderScreen>(find.byType(ReaderScreen));
    expect(reader.materialId, 'week-2');
    expect(reader.tab, 'visual');

    await goTo(tester, container, Routes.studyClasses);
    expect(tester.widget<StudyScreen>(find.byType(StudyScreen)).tab, 'classes');
  });

  testWidgets('an unknown path shows the styled not-found screen', (
    tester,
  ) async {
    final container = await pumpApp(tester);
    await goTo(tester, container, '/nowhere');
    expect(find.byType(NotFoundScreen), findsOneWidget);
    expect(find.text(NotFoundScreen.title), findsOneWidget);

    await tester.tap(find.text('Go home'));
    await tester.pumpAndSettle();
    expect(find.byType(HomeDashboardScreen), findsOneWidget);
  });

  testWidgets('tab roots show the shell bar, detail flows cover it', (
    tester,
  ) async {
    final container = await pumpApp(tester);
    for (final tab in [
      Routes.home,
      Routes.study,
      Routes.play,
      Routes.friends,
    ]) {
      await goTo(tester, container, tab);
      expect(find.byType(AppBottomNav), findsOneWidget, reason: tab);
    }
    for (final detail in [
      Routes.notifications,
      Routes.course('ite13'),
      Routes.quizSetup('q1'),
      Routes.create,
      Routes.profile,
    ]) {
      await goTo(tester, container, detail);
      expect(find.byType(AppBottomNav), findsNothing, reason: detail);
    }
  });

  testWidgets('a nested detail keeps its tab root underneath', (tester) async {
    final container = await pumpApp(tester);
    await goTo(tester, container, Routes.notifications);
    expect(routerOf(container).canPop(), isTrue);

    routerOf(container).pop();
    await tester.pumpAndSettle();
    expect(find.byType(HomeDashboardScreen), findsOneWidget);
  });

  testWidgets('the shell bar switches tabs', (tester) async {
    final container = await pumpApp(tester);
    await tester.tap(find.text('Play'));
    await tester.pumpAndSettle();
    expect(find.byType(PlayHubScreen), findsOneWidget);
    expect(currentLocation(container), Routes.play);
  });

  group('onboarding gate', () {
    testWidgets('a signed-out launch opens the splash', (tester) async {
      await pumpApp(tester, status: SessionStatus.signedOut);
      expect(find.byType(SplashScreen), findsOneWidget);
    });

    testWidgets('signed-out users are sent from a tab to the splash', (
      tester,
    ) async {
      final container = await pumpApp(tester, status: SessionStatus.signedOut);
      await goTo(tester, container, Routes.play);
      expect(find.byType(SplashScreen), findsOneWidget);
    });

    testWidgets('sign-up through the routine step lands on Home', (
      tester,
    ) async {
      final container = await pumpApp(tester, status: SessionStatus.signedOut);
      Future<void> tapLink(String label) async {
        await tester.ensureVisible(find.widgetWithText(AppButton, label).first);
        await tester.tap(find.widgetWithText(AppButton, label).first);
        await tester.pumpAndSettle();
      }

      await tapLink('Get started');
      expect(find.byType(WelcomeScreen), findsOneWidget);
      await tapLink('Get started');
      expect(find.byType(SignUpScreen), findsOneWidget);
      // The real sign-up form (D-19): username, email, password.
      const form = {
        'Username': 'ollie',
        'Email': 'ollie@example.com',
        'Password': 'secret123',
      };
      for (final MapEntry(key: field, value: text) in form.entries) {
        await tester.enterText(
          find.descendant(
            of: find.byWidgetPredicate(
              (w) => w is AppTextField && w.placeholder == field,
            ),
            matching: find.byType(EditableText),
          ),
          text,
        );
      }
      await tester.pump();
      await tapLink('Continue');
      expect(find.byType(AcademicProfileScreen), findsOneWidget);
      expect(container.read(sessionProvider), SessionStatus.onboarding);

      // Mid-onboarding, the tabs are still closed.
      await goTo(tester, container, Routes.home);
      expect(find.byType(AcademicProfileScreen), findsOneWidget);

      await goTo(tester, container, Routes.onboardingRoutine);
      expect(find.byType(StudyRoutineScreen), findsOneWidget);
      // The real step 99 needs a goal, frequency, reminder and language.
      for (final option in ['15 min', 'Weekdays', 'Morning', 'Taglish']) {
        await tester.ensureVisible(find.text(option));
        await tester.tap(find.text(option));
        await tester.pumpAndSettle();
      }
      await tester.ensureVisible(find.widgetWithText(AppButton, 'Continue'));
      await tapLink('Continue');
      expect(container.read(sessionProvider), SessionStatus.ready);
      expect(find.byType(HomeDashboardScreen), findsOneWidget);
    });
  });
}
