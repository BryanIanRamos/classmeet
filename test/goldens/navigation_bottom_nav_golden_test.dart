import 'package:classmeet/core/dev/galleries/navigation_gallery.dart';
import 'package:classmeet/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Golden of AppBottomNav: each selected tab and the Create-open state, on
/// 428 wide bars (frame 8 and 119). Regenerate with
/// `flutter test --update-goldens test/goldens/navigation_bottom_nav_golden_test.dart`.
void main() {
  testWidgets('AppBottomNav matrix', (tester) async {
    await tester.binding.setSurfaceSize(const Size(460, 700));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        debugShowCheckedModeBanner: false,
        home: const Scaffold(
          body: Padding(
            padding: EdgeInsets.all(16),
            child: AppBottomNavMatrix(),
          ),
        ),
      ),
    );
    await expectLater(
      find.byType(Scaffold),
      matchesGoldenFile('navigation_bottom_nav.png'),
    );
  });
}
