import 'package:classmeet/core/dev/galleries/navigation_gallery.dart';
import 'package:classmeet/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Goldens of AppNavbarTop and AppProgressBar, laid out like the DS sheets
/// (`design/ref/ds/navbar_top_5248-1785.png`, `progress_bar_5248-1858.png`).
/// Regenerate with
/// `flutter test --update-goldens test/goldens/navigation_golden_test.dart`.
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
    await expectLater(find.byType(Scaffold), matchesGoldenFile(file));
  }

  testWidgets('AppNavbarTop matrix', (tester) async {
    await golden(
      tester,
      const AppNavbarTopMatrix(),
      const Size(460, 760),
      'navigation_navbar_top.png',
    );
  });

  testWidgets('AppProgressBar matrix', (tester) async {
    await golden(
      tester,
      const AppProgressBarMatrix(),
      const Size(800, 620),
      'navigation_progress_bar.png',
    );
  });
}
