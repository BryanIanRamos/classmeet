import 'package:classmeet/core/dev/galleries/controls_gallery.dart';
import 'package:classmeet/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Goldens of AppTabs, AppDropdown and AppStepper, laid out like the DS
/// sheets (`design/ref/ds/tab_5248-10271.png`, `dropdown_5248-10319.png`,
/// `stepper_5248-10391.png`). Regenerate with
/// `flutter test --update-goldens test/goldens/controls_golden_test.dart`.
void main() {
  Future<void> golden(
    WidgetTester tester,
    Widget matrix,
    Size size,
    String file,
  ) async {
    await tester.binding.setSurfaceSize(size);
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: matrix,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await expectLater(find.byType(MaterialApp), matchesGoldenFile(file));
  }

  testWidgets('AppTabs matrix', (tester) async {
    await golden(
      tester,
      const AppTabsMatrix(),
      const Size(520, 1480),
      'controls_tabs.png',
    );
  });

  testWidgets('AppDropdown matrix', (tester) async {
    await golden(
      tester,
      const AppDropdownMatrix(),
      const Size(520, 1640),
      'controls_dropdown.png',
    );
  });

  testWidgets('AppStepper matrix', (tester) async {
    await golden(
      tester,
      const AppStepperMatrix(),
      const Size(420, 640),
      'controls_stepper.png',
    );
  });
}
