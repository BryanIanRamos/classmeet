import 'package:classmeet/app.dart';
import 'package:classmeet/core/router/app_router.dart';
import 'package:classmeet/core/router/routes.dart';
import 'package:classmeet/core/widgets/buttons/app_button.dart';
import 'package:classmeet/core/widgets/feedback/empty_state.dart';
import 'package:classmeet/core/widgets/feedback/error_state.dart';
import 'package:classmeet/core/widgets/selection/app_chip.dart';
import 'package:classmeet/data/fakes/fake_config.dart';
import 'package:classmeet/data/providers.dart';
import 'package:classmeet/features/auth/application/session_controller.dart';
import 'package:classmeet/features/onboarding/presentation/screens/learning_preferences_screen.dart';
import 'package:classmeet/features/onboarding/presentation/screens/study_subjects_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// Opens the app mid-onboarding and navigates to step 97.
Future<void> pumpStep(
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
  container.read(routerProvider).go(Routes.onboardingSubjects);
  await tester.pumpAndSettle();
}

AppButton continueButton(WidgetTester tester) =>
    tester.widget<AppButton>(find.widgetWithText(AppButton, 'Continue'));

AppChip chip(WidgetTester tester, String label) => tester.widget<AppChip>(
  find.byWidgetPredicate((w) => w is AppChip && w.label == label),
);

void main() {
  testWidgets('shows the design copy and the six subject chips', (
    tester,
  ) async {
    await pumpStep(tester);
    expect(find.byType(StudySubjectsScreen), findsOneWidget);
    expect(find.text('Your study subjects'), findsOneWidget);
    expect(find.text('Step 2 of 4'), findsOneWidget);
    expect(find.text('What are you studying?'), findsOneWidget);
    expect(
      find.text('Pick your subjects to personalize your learning experience.'),
      findsOneWidget,
    );
    expect(find.text('Please select all that apply'), findsOneWidget);
    expect(find.text('Add another subject'), findsOneWidget);
    expect(find.byType(AppChip), findsNWidgets(6));
    expect(find.text('Computer Programming'), findsOneWidget);
  });

  testWidgets('chips toggle; Continue needs one, then opens preferences', (
    tester,
  ) async {
    await pumpStep(tester);
    expect(continueButton(tester).onPressed, isNull);

    await tester.tap(find.text('HCI'));
    await tester.pumpAndSettle();
    expect(chip(tester, 'HCI').selected, isTrue);
    expect(continueButton(tester).onPressed, isNotNull);

    await tester.tap(find.text('HCI'));
    await tester.pumpAndSettle();
    expect(chip(tester, 'HCI').selected, isFalse);
    expect(continueButton(tester).onPressed, isNull);

    await tester.tap(find.text('Networking I'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(AppButton, 'Continue'));
    await tester.pumpAndSettle();
    expect(find.byType(LearningPreferencesScreen), findsOneWidget);
  });

  testWidgets('adds a custom subject through the sheet, selected', (
    tester,
  ) async {
    await pumpStep(tester);
    await tester.tap(find.text('Add another subject'));
    await tester.pumpAndSettle();
    expect(find.text('Subject name'), findsOneWidget);
    expect(
      tester.widget<AppButton>(find.widgetWithText(AppButton, 'Add')).onPressed,
      isNull,
      reason: 'empty name',
    );

    await tester.enterText(find.byType(TextField), '  Operating Systems ');
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(AppButton, 'Add'));
    await tester.pumpAndSettle();

    expect(find.text('Subject name'), findsNothing);
    expect(find.byType(AppChip), findsNWidgets(7));
    expect(chip(tester, 'Operating Systems').selected, isTrue);
    expect(continueButton(tester).onPressed, isNotNull);
  });

  testWidgets('empty scenario: message, add row, Continue off', (tester) async {
    await pumpStep(
      tester,
      config: const FakeConfig(
        scenario: FakeScenario.empty,
        latency: Duration.zero,
      ),
    );
    expect(find.byType(EmptyState), findsOneWidget);
    expect(find.text('Add another subject'), findsOneWidget);
    expect(continueButton(tester).onPressed, isNull);
  });

  testWidgets('error scenario: ErrorState with a retry', (tester) async {
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
