import 'package:classmeet/core/dev/galleries/layout_gallery.dart';
import 'package:classmeet/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Goldens of ScreenBackground, AppSheet and StepScaffold. The step golden
/// reproduces frame 98 (`design/ref/onboarding/98_learning_preferences.png`)
/// with placeholder rows. Regenerate with
/// `flutter test --update-goldens test/goldens/layout_golden_test.dart`.
void main() {
  Future<void> golden(
    WidgetTester tester,
    Widget content,
    Size size,
    String file, {
    EdgeInsets padding = EdgeInsets.zero,
    bool scroll = true,
  }) async {
    await tester.binding.setSurfaceSize(size);
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        debugShowCheckedModeBanner: false,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context).copyWith(padding: padding),
          child: child!,
        ),
        home: Scaffold(
          body: scroll
              ? SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: content,
                  ),
                )
              : content,
        ),
      ),
    );
    await expectLater(find.byType(Scaffold), matchesGoldenFile(file));
  }

  testWidgets('ScreenBackground', (tester) async {
    await golden(
      tester,
      const ScreenBackgroundMatrix(),
      const Size(480, 500),
      'layout_screen_background.png',
    );
  });

  testWidgets('AppSheet', (tester) async {
    await golden(
      tester,
      const AppSheetMatrix(),
      const Size(460, 1100),
      'layout_sheet.png',
    );
  });

  testWidgets('StepScaffold (frame 98)', (tester) async {
    await golden(
      tester,
      const StepScaffoldExample(height: 870),
      const Size(428, 870),
      'layout_step_scaffold.png',
      padding: const EdgeInsets.only(top: 62, bottom: 34),
      scroll: false,
    );
  });
}
