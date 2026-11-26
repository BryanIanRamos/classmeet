import 'package:classmeet/data/fakes/fake_class_repository.dart';
import 'package:classmeet/data/fakes/fake_config.dart';
import 'package:classmeet/data/providers.dart';
import 'package:classmeet/features/home/presentation/screens/join_class_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'render_harness.dart';

/// Types the sample class code and taps Join, so the confirmation sheet is up.
Future<void> openSheet(WidgetTester tester) async {
  await tester.enterText(find.byType(TextField), 'ITE16-2026');
  await tester.tap(find.text('Join'));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('13.1 join a class', (tester) async {
    await renderScreen(
      tester,
      'home/13.1_join_class',
      const JoinClassScreen(),
      overrides: [fakeConfigProvider.overrideWithValue(FakeConfig.instant)],
      fullPage: true,
    );
  });

  // The confirmation sheet has no design yet (GAP-20): these renders are for
  // reviewing the provisional look, there is no reference to compare with.
  testWidgets('13.1 confirmation sheet', (tester) async {
    await renderScreen(
      tester,
      'home/13.1_join_class_sheet',
      const JoinClassScreen(),
      overrides: [fakeConfigProvider.overrideWithValue(FakeConfig.instant)],
      prepare: openSheet,
    );
  });

  testWidgets('13.1 confirmation sheet, already joined', (tester) async {
    final classes = FakeClassRepository(FakeConfig.instant);
    await classes.joinClass('ITE16-2026');
    await renderScreen(
      tester,
      'home/13.1_join_class_sheet_already',
      const JoinClassScreen(),
      overrides: [
        fakeConfigProvider.overrideWithValue(FakeConfig.instant),
        classRepositoryProvider.overrideWithValue(classes),
      ],
      prepare: openSheet,
    );
  });

  testWidgets('13.1 with the error message', (tester) async {
    await renderScreen(
      tester,
      'home/13.1_join_class_error',
      const JoinClassScreen(),
      overrides: [fakeConfigProvider.overrideWithValue(FakeConfig.instant)],
      prepare: (tester) async {
        await tester.enterText(find.byType(TextField), 'NOPE-0000');
        await tester.tap(find.text('Join'));
        await tester.pumpAndSettle();
      },
    );
  });
}
