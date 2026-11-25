import 'package:classmeet/core/dev/galleries/selection_gallery.dart';
import 'package:classmeet/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Goldens of the selection controls, laid out like the DS sheets
/// (`design/ref/ds/radio_5248-1974.png`, `checkbox_5248-1446.png`,
/// `toggle_5248-2021.png`). Regenerate after an intended change with
/// `flutter test --update-goldens test/goldens/selection_golden_test.dart`.
void main() {
  Future<void> pump(WidgetTester tester, Widget matrix) async {
    await tester.binding.setSurfaceSize(const Size(900, 700));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          body: Padding(padding: const EdgeInsets.all(16), child: matrix),
        ),
      ),
    );
  }

  testWidgets('AppRadio matrix', (tester) async {
    await pump(tester, const AppRadioMatrix());
    await expectLater(
      find.byType(AppRadioMatrix),
      matchesGoldenFile('selection_radio.png'),
    );
  });

  testWidgets('AppCheckbox matrix', (tester) async {
    await pump(tester, const AppCheckboxMatrix());
    await expectLater(
      find.byType(AppCheckboxMatrix),
      matchesGoldenFile('selection_checkbox.png'),
    );
  });

  testWidgets('AppToggle matrix', (tester) async {
    await pump(tester, const AppToggleMatrix());
    await expectLater(
      find.byType(AppToggleMatrix),
      matchesGoldenFile('selection_toggle.png'),
    );
  });

  testWidgets('AppAnswerOption matrix', (tester) async {
    await pump(tester, const AppAnswerOptionMatrix());
    await expectLater(
      find.byType(AppAnswerOptionMatrix),
      matchesGoldenFile('selection_answer_option.png'),
    );
  });

  testWidgets('SelectableCard matrix', (tester) async {
    await pump(tester, const SelectableCardMatrix());
    await expectLater(
      find.byType(SelectableCardMatrix),
      matchesGoldenFile('selection_card.png'),
    );
  });
}
