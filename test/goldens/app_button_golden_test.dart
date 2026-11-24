import 'package:classmeet/core/dev/widget_gallery.dart';
import 'package:classmeet/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Golden of every AppButton style × state × size, laid out like the DS
/// sheet (`design/ref/ds/button_5248-660.png`). Regenerate after an intended
/// change with `flutter test --update-goldens test/goldens`.
void main() {
  testWidgets('AppButton matrix', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1400, 1600));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        debugShowCheckedModeBanner: false,
        home: const Scaffold(
          body: Padding(padding: EdgeInsets.all(16), child: AppButtonMatrix()),
        ),
      ),
    );

    await expectLater(
      find.byType(AppButtonMatrix),
      matchesGoldenFile('app_button.png'),
    );
  });
}
