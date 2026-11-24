import 'package:classmeet/core/dev/galleries/inputs_gallery.dart';
import 'package:classmeet/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Golden of every AppTextField style × state × size, laid out like the DS
/// sheet (`design/ref/ds/input_5248-2176.png`). Regenerate after an intended
/// change with `flutter test --update-goldens test/goldens`.
void main() {
  testWidgets('AppTextField matrix', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1000, 2800));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        debugShowCheckedModeBanner: false,
        home: const Scaffold(
          body: SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: AppTextFieldMatrix(),
          ),
        ),
      ),
    );

    await expectLater(
      find.byType(AppTextFieldMatrix),
      matchesGoldenFile('app_text_field.png'),
    );
  });
}
