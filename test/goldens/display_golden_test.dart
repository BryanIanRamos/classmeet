import 'package:classmeet/core/dev/galleries/display_gallery.dart';
import 'package:classmeet/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Goldens of AppAvatar, AppBadge and AppChip, laid out like the DS sheets
/// (`design/ref/ds/avatar_5248-1634.png`, `badge_chip_5248-1220.png`).
/// Regenerate with
/// `flutter test --update-goldens test/goldens/display_golden_test.dart`.
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
    // Let the avatar asset decode before the capture.
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 300)),
    );
    await tester.pump();
    await expectLater(find.byType(Scaffold), matchesGoldenFile(file));
  }

  testWidgets('AppAvatar matrix', (tester) async {
    await golden(
      tester,
      const AppAvatarMatrix(),
      const Size(900, 800),
      'display_avatar.png',
    );
  });

  testWidgets('AppBadge matrix', (tester) async {
    await golden(
      tester,
      const SingleChildScrollView(child: AppBadgeMatrix()),
      const Size(1000, 1900),
      'display_badge.png',
    );
  });

  testWidgets('AppChip matrix', (tester) async {
    await golden(
      tester,
      const AppChipMatrix(),
      const Size(500, 760),
      'display_chip.png',
    );
  });
}
