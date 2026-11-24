import 'dart:async';

import 'package:classmeet/app.dart';
import 'package:classmeet/core/router/routes.dart';
import 'package:classmeet/core/widgets/buttons/app_button.dart';
import 'package:classmeet/core/widgets/feedback/error_state.dart';
import 'package:classmeet/core/widgets/selection/selectable_card.dart';
import 'package:classmeet/data/fakes/fake_config.dart';
import 'package:classmeet/data/models/onboarding_prefs.dart';
import 'package:classmeet/data/providers.dart';
import 'package:classmeet/features/auth/application/session_controller.dart';
import 'package:classmeet/features/onboarding/presentation/screens/learning_preferences_screen.dart';
import 'package:classmeet/features/onboarding/presentation/screens/study_routine_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

/// Opens the app mid-onboarding, then goes to step 98.
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
  final context = tester.element(find.byType(Navigator).first);
  unawaited(GoRouter.of(context).push(Routes.onboardingPreferences));
  await tester.pumpAndSettle();
}

AppButton continueButton(WidgetTester tester) =>
    tester.widget<AppButton>(find.widgetWithText(AppButton, 'Continue'));

Future<void> tapCard(WidgetTester tester, StudyMethod method) async {
  final card = find.widgetWithText(SelectableCard, method.label);
  await tester.ensureVisible(card);
  await tester.tap(card);
  await tester.pumpAndSettle();
}

bool isSelected(WidgetTester tester, StudyMethod method) => tester
    .widget<SelectableCard>(find.widgetWithText(SelectableCard, method.label))
    .selected;

void main() {
  testWidgets('shows the design copy and all six cards', (tester) async {
    await pumpStep(tester);
    expect(find.byType(LearningPreferencesScreen), findsOneWidget);
    expect(find.text('Your learning preferences'), findsOneWidget);
    expect(find.text('Step 3 of 4'), findsOneWidget);
    expect(find.text('How do you like to study?'), findsOneWidget);
    expect(
      find.text(
        "Choose the methods you enjoy. We'll tailor your study sessions to you.",
      ),
      findsOneWidget,
    );
    expect(find.text('Preferred study methods'), findsOneWidget);
    expect(find.text('0 of 3 selected'), findsOneWidget);
    expect(find.byType(SelectableCard, skipOffstage: false), findsNWidgets(6));
    for (final method in StudyMethod.values) {
      expect(
        find.text(method.label, skipOffstage: false),
        findsOneWidget,
        reason: method.label,
      );
    }
  });

  testWidgets('selects up to three, ignores a fourth, and deselects', (
    tester,
  ) async {
    await pumpStep(tester);
    await tapCard(tester, StudyMethod.flashcards);
    expect(find.text('1 of 3 selected'), findsOneWidget);
    await tapCard(tester, StudyMethod.studyParty);
    await tapCard(tester, StudyMethod.readingSummaries);
    expect(find.text('3 of 3 selected'), findsOneWidget);

    await tapCard(tester, StudyMethod.stepByStep);
    expect(find.text('3 of 3 selected'), findsOneWidget);
    expect(isSelected(tester, StudyMethod.stepByStep), isFalse);

    await tapCard(tester, StudyMethod.studyParty);
    expect(find.text('2 of 3 selected'), findsOneWidget);
    expect(isSelected(tester, StudyMethod.studyParty), isFalse);
    await tapCard(tester, StudyMethod.stepByStep);
    expect(isSelected(tester, StudyMethod.stepByStep), isTrue);
  });

  testWidgets('Continue is off at 0 and opens the routine step', (
    tester,
  ) async {
    await pumpStep(tester);
    expect(continueButton(tester).onPressed, isNull);

    await tapCard(tester, StudyMethod.flashcards);
    expect(continueButton(tester).onPressed, isNotNull);
    await tapCard(tester, StudyMethod.flashcards);
    expect(continueButton(tester).onPressed, isNull);

    await tapCard(tester, StudyMethod.practiceQuizzes);
    await tester.tap(find.widgetWithText(AppButton, 'Continue'));
    await tester.pumpAndSettle();
    expect(find.byType(StudyRoutineScreen), findsOneWidget);
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
    testWidgets('no overflow at ${size.width.toInt()}dp, list scrolls', (
      tester,
    ) async {
      await pumpStep(tester, size: size);
      expect(tester.takeException(), isNull);
      await tester.drag(find.byType(Scrollable).first, const Offset(0, -400));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  }
}
