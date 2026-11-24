import 'package:classmeet/core/dev/galleries/lists_gallery.dart';
import 'package:classmeet/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Goldens of AppListRow, AppCard and SectionHeader, laid out like the DS
/// sheets (`design/ref/ds/list_5248-10403.png`, `card_5248-10244.png`).
/// Regenerate with
/// `flutter test --update-goldens test/goldens/lists_golden_test.dart`.
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
            child: Padding(padding: const EdgeInsets.all(16), child: matrix),
          ),
        ),
      ),
    );
    await expectLater(find.byType(Scaffold), matchesGoldenFile(file));
  }

  testWidgets('AppListRow matrix', (tester) async {
    await golden(
      tester,
      const AppListRowMatrix(),
      const Size(400, 1000),
      'lists_list_row.png',
    );
  });

  testWidgets('AppCard matrix', (tester) async {
    await golden(
      tester,
      const AppCardMatrix(),
      const Size(400, 1000),
      'lists_card.png',
    );
  });

  testWidgets('SectionHeader matrix', (tester) async {
    await golden(
      tester,
      const SectionHeaderMatrix(),
      const Size(400, 200),
      'lists_section_header.png',
    );
  });
}
