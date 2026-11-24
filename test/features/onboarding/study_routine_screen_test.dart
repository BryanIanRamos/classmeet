import 'package:classmeet/app.dart';
import 'package:classmeet/core/router/app_router.dart';
import 'package:classmeet/core/router/routes.dart';
import 'package:classmeet/core/widgets/buttons/app_button.dart';
import 'package:classmeet/core/widgets/feedback/error_state.dart';
import 'package:classmeet/core/widgets/selection/selectable_card.dart';
import 'package:classmeet/data/fakes/fake_config.dart';
import 'package:classmeet/data/providers.dart';
import 'package:classmeet/features/auth/application/session_controller.dart';
import 'package:classmeet/features/home/presentation/screens/home_dashboard_screen.dart';
import 'package:classmeet/features/onboarding/presentation/screens/study_routine_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// Opens the app mid-onboarding and navigates to step 99.
Future<ProviderContainer> pumpStep(
  WidgetTester tester, {
  FakeConfig config = FakeConfig.instant,
  Size size = const Size(428, 926),
}) async {
  await tester.binding.setSurfaceSize(size);
  addTearDown(() => tester.binding.setSurfaceSize(null));
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        fakeConfigProvider.overrideWithValue(config),
        initialSessionStatusProvider.overrideWithValue(
          SessionStatus.onboarding,
        ),
      ],
      retry: (_, _) => null,
      child: const ClassMeetApp(),
    ),
  );
  await tester.pumpAndSettle();
  final container = ProviderScope.containerOf(
    tester.element(find.byType(ClassMeetApp)),
  );
  container.read(routerProvider).go(Routes.onboardingRoutine);
  await tester.pumpAndSettle();
  return container;
}

AppButton continueButton(WidgetTester tester) =>
    tester.widget<AppButton>(find.widgetWithText(AppButton, 'Continue'));

Future<void> pick(WidgetTester tester, String text) async {
  await tester.ensureVisible(find.text(text));
  await tester.tap(find.text(text));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('shows the design copy and every option', (tester) async {
    await pumpStep(tester);
    expect(find.byType(StudyRoutineScreen), findsOneWidget);
    expect(find.text('Your study routine'), findsOneWidget);
    expect(find.text('Step 4 of 4'), findsOneWidget);
    expect(find.text("What's your study routine?"), findsOneWidget);
    expect(
      find.text(
        'Choose a study goal and schedule that work for you. '
        'You can always change them later.',
      ),
      findsOneWidget,
    );
    expect(find.byType(SelectableCard), findsNWidgets(4));
    for (final text in [
      "What's your daily study goal?",
      '15 min',
      'A little each day',
      '30 min',
      'Stay on track',
      '40 min',
      'More progress',
      '60 min',
      'Go deeper',
      'How often do you want to study?',
      'Every day',
      'Weekdays',
      'A few days a week',
      'When should we remind you?',
      'Morning',
      'Afternoon',
      'Evening',
      'Preferred learning language',
      'English',
      'Tagalog',
      'Taglish',
      'You can change your study preferences anytime.',
    ]) {
      expect(find.text(text), findsOneWidget, reason: text);
    }
  });

  testWidgets('choosing a goal selects only that card', (tester) async {
    await pumpStep(tester);
    await pick(tester, '30 min');
    final selected = tester
        .widgetList<SelectableCard>(find.byType(SelectableCard))
        .where((c) => c.selected)
        .map((c) => c.title);
    expect(selected, ['30 min']);
    await pick(tester, '60 min');
    final again = tester
        .widgetList<SelectableCard>(find.byType(SelectableCard))
        .where((c) => c.selected)
        .map((c) => c.title);
    expect(again, ['60 min']);
  });

  testWidgets('Continue waits for all four groups', (tester) async {
    await pumpStep(tester);
    expect(continueButton(tester).onPressed, isNull);
    await pick(tester, '15 min');
    expect(continueButton(tester).onPressed, isNull);
    await pick(tester, 'Weekdays');
    expect(continueButton(tester).onPressed, isNull);
    await pick(tester, 'Morning');
    expect(continueButton(tester).onPressed, isNull, reason: 'no language');
    await pick(tester, 'Taglish');
    expect(continueButton(tester).onPressed, isNotNull);
  });

  testWidgets('Continue saves, readies the session and lands on Home', (
    tester,
  ) async {
    final container = await pumpStep(tester);
    await pick(tester, '40 min');
    await pick(tester, 'Every day');
    await pick(tester, 'Evening');
    await pick(tester, 'English');
    await tester.tap(find.widgetWithText(AppButton, 'Continue'));
    await tester.pumpAndSettle();

    expect(container.read(sessionProvider), SessionStatus.ready);
    expect(find.byType(HomeDashboardScreen), findsOneWidget);
    expect(find.byType(StudyRoutineScreen), findsNothing);
    final navigator = tester.state<NavigatorState>(
      find.byType(Navigator).first,
    );
    expect(navigator.canPop(), isFalse, reason: 'cannot go back to onboarding');
  });

  testWidgets('error: shows ErrorState with a retry', (tester) async {
    await pumpStep(
      tester,
      config: const FakeConfig(
        scenario: FakeScenario.error,
        latency: Duration.zero,
      ),
    );
    expect(find.byType(ErrorState), findsOneWidget);
    expect(find.text('Try again'), findsOneWidget);
    expect(continueButton(tester).onPressed, isNull);
  });

  for (final size in const [Size(360, 800), Size(428, 926)]) {
    testWidgets('no overflow at ${size.width.toInt()}dp', (tester) async {
      await pumpStep(tester, size: size);
      expect(tester.takeException(), isNull);
    });
  }
}
