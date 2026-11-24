import 'package:classmeet/core/assets/app_icons.dart';
import 'package:classmeet/core/router/app_bottom_nav.dart';
import 'package:classmeet/core/theme/app_colors.dart';
import 'package:classmeet/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> pumpNav(
  WidgetTester tester, {
  int index = 0,
  bool open = false,
  ValueChanged<int>? onTab,
  VoidCallback? onCreate,
  double width = 428,
}) async {
  await tester.binding.setSurfaceSize(Size(width, 400));
  addTearDown(() => tester.binding.setSurfaceSize(null));
  await tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.light,
      home: Scaffold(
        body: Align(
          alignment: Alignment.bottomCenter,
          child: AppBottomNav(
            currentIndex: index,
            onTabSelected: onTab ?? (_) {},
            createOpen: open,
            onCreatePressed: onCreate ?? () {},
          ),
        ),
      ),
    ),
  );
}

Color? selectorColor(WidgetTester tester, String tab) {
  final box = tester.widget<DecoratedBox>(
    find.byKey(ValueKey('nav-selector-$tab')),
  );
  return (box.decoration as BoxDecoration).color;
}

Color? labelColor(WidgetTester tester, String label) =>
    tester.widget<Text>(find.text(label)).style?.color;

void main() {
  testWidgets('geometry: 58 items, 95 tall with the indicator area', (
    tester,
  ) async {
    await pumpNav(tester);
    expect(tester.getSize(find.byType(AppBottomNav)).height, 95);
    expect(tester.getSize(find.byType(AppBottomNav)).width, 428);
  });

  for (final (i, name) in ['home', 'study', 'play', 'friends'].indexed) {
    testWidgets('only $name is styled selected at index $i', (tester) async {
      await pumpNav(tester, index: i);
      for (final (j, other) in ['home', 'study', 'play', 'friends'].indexed) {
        final label = AppBottomNavTab.values[j].label;
        if (j == i) {
          expect(selectorColor(tester, other), AppColors.plume300);
          expect(labelColor(tester, label), AppColors.plume500);
        } else {
          expect(selectorColor(tester, other), Colors.transparent);
          expect(labelColor(tester, label), AppColors.grey200);
        }
      }
    });
  }

  testWidgets('taps map slots to branch indexes', (tester) async {
    final taps = <int>[];
    await pumpNav(tester, onTab: taps.add);
    for (final label in ['Home', 'Study', 'Play', 'Friends']) {
      await tester.tap(find.text(label));
    }
    expect(taps, [0, 1, 2, 3]);
  });

  testWidgets('the + calls onCreatePressed and shows an x when open', (
    tester,
  ) async {
    var created = 0;
    await pumpNav(tester, onCreate: () => created++);
    expect(find.byIcon(AppIcons.plus), findsOneWidget);
    expect(find.byIcon(AppIcons.x), findsNothing);
    await tester.tap(find.byIcon(AppIcons.plus));
    expect(created, 1);

    await pumpNav(tester, open: true);
    expect(find.byIcon(AppIcons.x), findsOneWidget);
    expect(find.byIcon(AppIcons.plus), findsNothing);
  });

  testWidgets('the + is Plume-500 (8), the open x Sage-500 (119)', (
    tester,
  ) async {
    Color? fabColor(String key) {
      final box = tester.widget<DecoratedBox>(
        find
            .ancestor(
              of: find.byKey(ValueKey(key)),
              matching: find.byType(DecoratedBox),
            )
            .first,
      );
      return (box.decoration as BoxDecoration).color;
    }

    await pumpNav(tester);
    expect(fabColor('nav-create-open'), AppColors.plume500);
    await pumpNav(tester, open: true);
    expect(fabColor('nav-create-close'), AppColors.sage500);
  });

  testWidgets('semantics: labels and the create toggle', (tester) async {
    final handle = tester.ensureSemantics();
    await pumpNav(tester);
    expect(find.bySemanticsLabel('Create'), findsOneWidget);
    for (final label in ['Home', 'Study', 'Play', 'Friends']) {
      expect(find.bySemanticsLabel(label), findsOneWidget);
    }
    await pumpNav(tester, open: true);
    expect(find.bySemanticsLabel('Close create menu'), findsOneWidget);
    handle.dispose();
  });

  testWidgets('the bottom inset grows the bar', (tester) async {
    await tester.binding.setSurfaceSize(const Size(428, 400));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: MediaQuery(
          data: const MediaQueryData(viewPadding: EdgeInsets.only(bottom: 34)),
          child: Align(
            alignment: Alignment.bottomCenter,
            child: AppBottomNav(
              currentIndex: 0,
              onTabSelected: (_) {},
              createOpen: false,
              onCreatePressed: () {},
            ),
          ),
        ),
      ),
    );
    expect(tester.getSize(find.byType(AppBottomNav)).height, 58 + 12 + 34 + 1);
  });

  for (final width in [360.0, 428.0]) {
    testWidgets('no overflow at ${width.toInt()}dp', (tester) async {
      await pumpNav(tester, width: width, open: true);
      expect(tester.takeException(), isNull);
      expect(tester.getSize(find.byType(AppBottomNav)).width, width);
    });
  }
}
