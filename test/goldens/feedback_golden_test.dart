import 'package:classmeet/core/dev/galleries/feedback_gallery.dart';
import 'package:classmeet/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Goldens of the feedback widgets, laid out like the DS sheets
/// (`design/ref/ds/alert_5248-2071.png`, `loader_5248-1522.png`,
/// `tooltip_5248-1502.png`). Regenerate with
/// `flutter test --update-goldens test/goldens/feedback_golden_test.dart`.
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
          body: Padding(padding: const EdgeInsets.all(16), child: matrix),
        ),
      ),
    );
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 300)),
    );
    await tester.pump();
    await expectLater(find.byType(Scaffold), matchesGoldenFile(file));
  }

  testWidgets('AppAlert matrix', (tester) async {
    await golden(
      tester,
      const SingleChildScrollView(child: AppAlertMatrix()),
      const Size(1100, 1000),
      'feedback_alert.png',
    );
  });

  testWidgets('AppLoader matrix', (tester) async {
    await golden(
      tester,
      const AppLoaderMatrix(),
      const Size(400, 100),
      'feedback_loader.png',
    );
  });

  testWidgets('AppTooltip matrix', (tester) async {
    await golden(
      tester,
      const AppTooltipMatrix(),
      const Size(400, 300),
      'feedback_tooltip.png',
    );
  });

  testWidgets('Empty and error states', (tester) async {
    await golden(
      tester,
      const FeedbackStatesMatrix(),
      const Size(700, 400),
      'feedback_states.png',
    );
  });
}
