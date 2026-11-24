import 'package:classmeet/app.dart';
import 'package:classmeet/core/assets/app_icons.dart';
import 'package:classmeet/core/widgets/buttons/app_button.dart';
import 'package:classmeet/core/widgets/feedback/error_state.dart';
import 'package:classmeet/core/widgets/inputs/app_dropdown.dart';
import 'package:classmeet/data/fakes/fake_config.dart';
import 'package:classmeet/data/providers.dart';
import 'package:classmeet/features/auth/application/session_controller.dart';
import 'package:classmeet/features/onboarding/presentation/screens/academic_profile_screen.dart';
import 'package:classmeet/features/onboarding/presentation/screens/study_subjects_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// Opens the app mid-onboarding: the gate sends `/` to step 96.
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
}

AppButton continueButton(WidgetTester tester) =>
    tester.widget<AppButton>(find.widgetWithText(AppButton, 'Continue'));

AppDropdown<String> dropdown(WidgetTester tester, String label) =>
    tester.widget<AppDropdown<String>>(
      find.byWidgetPredicate(
        (w) => w is AppDropdown<String> && w.label == label,
      ),
    );

Future<void> choose(WidgetTester tester, String field, String option) async {
  final box = find.descendant(
    of: find.byWidgetPredicate(
      (w) => w is AppDropdown<String> && w.label == field,
    ),
    matching: find.byKey(AppDropdown.boxKey),
  );
  await tester.ensureVisible(box);
  await tester.tap(box);
  await tester.pumpAndSettle();
  await tester.tap(find.text(option).last);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('shows the design copy, without the language row (INC-3)', (
    tester,
  ) async {
    await pumpStep(tester);
    expect(find.byType(AcademicProfileScreen), findsOneWidget);
    expect(find.text('Your academic profile'), findsOneWidget);
    expect(find.text('Step 1 of 4'), findsOneWidget);
    expect(find.text('Where do you study?'), findsOneWidget);
    expect(
      find.text('Tell us about your school, program, and year level.'),
      findsOneWidget,
    );
    expect(find.text('Caraga State University'), findsOneWidget);
    expect(find.text('Select College'), findsOneWidget);
    expect(find.text('Select Program'), findsOneWidget);
    for (final level in ['1st', '2nd', '3rd', '4th', '5th+']) {
      expect(find.text(level), findsOneWidget);
    }
    expect(find.text('Preferred learning language'), findsNothing);
  });

  testWidgets('dropdowns open in order; Continue waits for all four', (
    tester,
  ) async {
    await pumpStep(tester);
    // The saved school shows the confirmed look; college is next.
    expect(find.byIcon(AppIcons.check), findsOneWidget);
    expect(dropdown(tester, 'Program').onChanged, isNull);
    expect(continueButton(tester).onPressed, isNull);

    await choose(
      tester,
      'College',
      'College of Computing and Information Sciences',
    );
    expect(dropdown(tester, 'Program').onChanged, isNotNull);
    await choose(tester, 'Program', 'BS Information Technology');
    expect(continueButton(tester).onPressed, isNull, reason: 'no year yet');

    await tester.tap(find.text('2nd'));
    await tester.pumpAndSettle();
    expect(continueButton(tester).onPressed, isNotNull);

    await tester.tap(find.widgetWithText(AppButton, 'Continue'));
    await tester.pumpAndSettle();
    expect(find.byType(StudySubjectsScreen), findsOneWidget);
  });

  testWidgets('changing the college clears the program', (tester) async {
    await pumpStep(tester);
    await choose(
      tester,
      'College',
      'College of Computing and Information Sciences',
    );
    await choose(tester, 'Program', 'BS Computer Science');
    expect(dropdown(tester, 'Program').value, 'csu-bscs');

    await choose(tester, 'College', 'College of Engineering and Geosciences');
    expect(dropdown(tester, 'Program').value, isNull);
    expect(find.text('Select Program'), findsOneWidget);
  });

  testWidgets('empty catalog: nothing to pick, Continue stays off', (
    tester,
  ) async {
    await pumpStep(
      tester,
      config: const FakeConfig(
        scenario: FakeScenario.empty,
        latency: Duration.zero,
      ),
    );
    expect(dropdown(tester, 'School').onChanged, isNull);
    expect(dropdown(tester, 'College').onChanged, isNull);
    expect(continueButton(tester).onPressed, isNull);
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
