import 'package:classmeet/core/theme/app_colors.dart';
import 'package:classmeet/core/widgets/feedback/app_loader.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _wrap(Widget child) => MaterialApp(
  home: Scaffold(body: Center(child: child)),
);

void main() {
  testWidgets('sizes and stroke widths follow the DS', (tester) async {
    const expected = {
      AppLoaderSize.giant: (56.0, 6.0),
      AppLoaderSize.large: (48.0, 6.0),
      AppLoaderSize.medium: (40.0, 5.0),
      AppLoaderSize.small: (32.0, 4.0),
      AppLoaderSize.tiny: (24.0, 4.0),
    };
    for (final entry in expected.entries) {
      expect(entry.key.diameter, entry.value.$1);
      expect(entry.key.strokeWidth, entry.value.$2);
      await tester.pumpWidget(
        _wrap(AppLoader(size: entry.key, animate: false)),
      );
      expect(
        tester.getSize(find.byType(AppLoader)),
        Size.square(entry.value.$1),
      );
    }
  });

  testWidgets('default colour is sage-500', (tester) async {
    expect(const AppLoader().color, AppColors.sage500);
  });

  testWidgets('static mode does not rotate; animated mode does', (
    tester,
  ) async {
    double turns() => tester
        .widget<RotationTransition>(
          find.descendant(
            of: find.byType(AppLoader),
            matching: find.byType(RotationTransition),
          ),
        )
        .turns
        .value;

    await tester.pumpWidget(_wrap(const AppLoader(animate: false)));
    await tester.pump(const Duration(milliseconds: 300));
    expect(turns(), 0);
    // No running ticker: pumpAndSettle returns at once.
    await tester.pumpAndSettle();

    await tester.pumpWidget(_wrap(const AppLoader()));
    await tester.pump(const Duration(milliseconds: 300));
    expect(turns(), greaterThan(0));

    // Switching to static stops it.
    await tester.pumpWidget(_wrap(const AppLoader(animate: false)));
    await tester.pumpAndSettle();
    expect(turns(), 0);
  });
}
