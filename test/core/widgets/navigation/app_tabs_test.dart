import 'dart:ui' show Tristate;
import 'package:classmeet/core/assets/app_icons.dart';
import 'package:classmeet/core/theme/app_colors.dart';
import 'package:classmeet/core/theme/app_theme.dart';
import 'package:classmeet/core/widgets/navigation/app_tabs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> pumpTabs(
  WidgetTester tester,
  Widget tabs, {
  double width = 428,
}) async {
  await tester.binding.setSurfaceSize(Size(width, 400));
  addTearDown(() => tester.binding.setSurfaceSize(null));
  await tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.light,
      home: Scaffold(
        body: Align(alignment: Alignment.topLeft, child: tabs),
      ),
    ),
  );
}

List<AppTabItem> items(int n, {int? disabled}) => [
  for (var i = 0; i < n; i++)
    AppTabItem(label: 'Tab ${i + 1}', enabled: i != disabled),
];

BoxDecoration decorationOf(WidgetTester tester, int index) {
  final box = find.descendant(
    of: find.byKey(AppTabs.itemKey(index)),
    matching: find.byType(DecoratedBox),
  );
  return tester.widget<DecoratedBox>(box.first).decoration as BoxDecoration;
}

Color? fillOf(WidgetTester tester, int index) =>
    decorationOf(tester, index).color;

Color labelColor(WidgetTester tester, String label) =>
    tester.widget<Text>(find.text(label)).style!.color!;

void main() {
  group('geometry', () {
    testWidgets('underline: 48 high, equal widths, 4 high line', (
      tester,
    ) async {
      await pumpTabs(
        tester,
        AppTabs(tabs: items(2), selectedIndex: 0, onChanged: (_) {}),
      );
      expect(tester.getSize(find.byType(AppTabs)), const Size(428, 48));
      expect(tester.getSize(find.byKey(AppTabs.itemKey(0))).width, 214);
      expect(tester.getSize(find.byKey(AppTabs.itemKey(1))).width, 214);
      final line = find.byKey(AppTabs.indicatorKey(0));
      expect(tester.getSize(line), const Size(198, 4));
      expect(find.byKey(AppTabs.indicatorKey(1)), findsNothing);
      final deco =
          tester.widget<DecoratedBox>(line).decoration as BoxDecoration;
      expect(deco.color, AppColors.sage500);
      expect(deco.borderRadius, BorderRadius.circular(64));
    });

    testWidgets('pill: 32 high, radius 16, 8 apart', (tester) async {
      await pumpTabs(
        tester,
        AppTabs(
          style: AppTabsStyle.pill,
          tabs: items(4),
          selectedIndex: 1,
          onChanged: (_) {},
        ),
      );
      expect(tester.getSize(find.byType(AppTabs)).height, 32);
      final a = tester.getRect(find.byKey(AppTabs.itemKey(0)));
      final b = tester.getRect(find.byKey(AppTabs.itemKey(1)));
      expect(b.left - a.right, 8);
      expect(decorationOf(tester, 0).borderRadius, BorderRadius.circular(16));
    });

    testWidgets('segment: 40 high, radius 20, hugs touching tabs', (
      tester,
    ) async {
      await pumpTabs(
        tester,
        AppTabs(
          style: AppTabsStyle.segment,
          scrollable: true,
          tabs: const [
            AppTabItem(label: 'One', icon: AppIcons.star),
            AppTabItem(label: 'Two'),
          ],
          selectedIndex: 0,
          onChanged: (_) {},
        ),
      );
      expect(tester.getSize(find.byType(AppTabs)).height, 40);
      final a = tester.getRect(find.byKey(AppTabs.itemKey(0)));
      final b = tester.getRect(find.byKey(AppTabs.itemKey(1)));
      expect(b.left, a.right);
      expect(tester.getSize(find.byIcon(AppIcons.star)), const Size.square(24));
      expect(a.width, greaterThan(b.width));
      expect(decorationOf(tester, 0).borderRadius, BorderRadius.circular(20));
    });

    for (final style in AppTabsStyle.values) {
      testWidgets('5 tabs at 360dp do not overflow (${style.name})', (
        tester,
      ) async {
        await pumpTabs(
          tester,
          SizedBox(
            width: 360,
            child: AppTabs(
              style: style,
              tabs: [
                for (var i = 0; i < 5; i++)
                  AppTabItem(label: 'Tab ${i + 1}', icon: AppIcons.star),
              ],
              selectedIndex: 0,
              onChanged: (_) {},
            ),
          ),
          width: 360,
        );
        expect(tester.takeException(), isNull);
      });
    }

    testWidgets('scrollable lets wide tabs scroll without overflow', (
      tester,
    ) async {
      await pumpTabs(
        tester,
        SizedBox(
          width: 360,
          child: AppTabs(
            style: AppTabsStyle.pill,
            scrollable: true,
            tabs: [
              for (final l in ['Everything', 'Classes', 'Materials', 'People'])
                AppTabItem(label: l),
            ],
            selectedIndex: 0,
            onChanged: (_) {},
          ),
        ),
        width: 360,
      );
      expect(tester.takeException(), isNull);
    });
  });

  group('colours', () {
    testWidgets('underline: selected sage-500, others grey-500', (
      tester,
    ) async {
      await pumpTabs(
        tester,
        AppTabs(tabs: items(2), selectedIndex: 0, onChanged: (_) {}),
      );
      expect(labelColor(tester, 'Tab 1'), AppColors.sage500);
      expect(labelColor(tester, 'Tab 2'), AppColors.grey500);
    });

    testWidgets('pill: sage-500 fill + white, others grey-100 + grey-500', (
      tester,
    ) async {
      await pumpTabs(
        tester,
        AppTabs(
          style: AppTabsStyle.pill,
          tabs: items(2),
          selectedIndex: 0,
          onChanged: (_) {},
        ),
      );
      expect(fillOf(tester, 0), AppColors.sage500);
      expect(labelColor(tester, 'Tab 1'), AppColors.white);
      expect(fillOf(tester, 1), AppColors.grey100);
      expect(labelColor(tester, 'Tab 2'), AppColors.grey500);
    });

    testWidgets('segment: states follow the DS table', (tester) async {
      final hover = WidgetStatesController({WidgetState.hovered});
      final focus = WidgetStatesController({WidgetState.focused});
      addTearDown(hover.dispose);
      addTearDown(focus.dispose);
      await pumpTabs(
        tester,
        AppTabs(
          style: AppTabsStyle.segment,
          tabs: [
            const AppTabItem(label: 'Selected'),
            AppTabItem(label: 'Hover', statesController: hover),
            AppTabItem(label: 'Focus', statesController: focus),
            const AppTabItem(label: 'Default'),
            const AppTabItem(label: 'Disabled', enabled: false),
          ],
          selectedIndex: 0,
          onChanged: (_) {},
        ),
      );
      expect(fillOf(tester, 0), AppColors.sage500);
      expect(labelColor(tester, 'Selected'), AppColors.white);
      expect(fillOf(tester, 1), AppColors.sage50);
      expect(labelColor(tester, 'Hover'), AppColors.sage500);
      expect(fillOf(tester, 2), AppColors.white);
      final shadow = decorationOf(tester, 2).boxShadow!.single;
      expect(shadow.spreadRadius, 3);
      expect(shadow.color, AppColors.sage300);
      expect(fillOf(tester, 3), Colors.transparent);
      expect(labelColor(tester, 'Default'), AppColors.sage500);
      expect(labelColor(tester, 'Disabled'), AppColors.grey400);
    });
  });

  group('behaviour', () {
    testWidgets('tapping a tab reports its index', (tester) async {
      int? tapped;
      await pumpTabs(
        tester,
        AppTabs(tabs: items(3), selectedIndex: 0, onChanged: (i) => tapped = i),
      );
      await tester.tap(find.text('Tab 3'));
      expect(tapped, 2);
    });

    testWidgets('a disabled tab ignores taps', (tester) async {
      int? tapped;
      await pumpTabs(
        tester,
        AppTabs(
          tabs: items(3, disabled: 1),
          selectedIndex: 0,
          onChanged: (i) => tapped = i,
        ),
      );
      await tester.tap(find.text('Tab 2'));
      expect(tapped, isNull);
    });

    testWidgets('null onChanged disables every tab', (tester) async {
      await pumpTabs(
        tester,
        AppTabs(tabs: items(2), selectedIndex: 0, onChanged: null),
      );
      expect(labelColor(tester, 'Tab 1'), AppColors.grey400);
      expect(labelColor(tester, 'Tab 2'), AppColors.grey400);
    });

    testWidgets('exposes selected semantics', (tester) async {
      final handle = tester.ensureSemantics();
      await pumpTabs(
        tester,
        AppTabs(tabs: items(2), selectedIndex: 1, onChanged: (_) {}),
      );
      final node = tester.getSemantics(
        find
            .descendant(
              of: find.byKey(AppTabs.itemKey(1)),
              matching: find.byType(Semantics),
            )
            .first,
      );
      expect(node.label, 'Tab 2');
      expect(
        node.getSemanticsData().flagsCollection.isSelected,
        Tristate.isTrue,
      );
      handle.dispose();
    });

    testWidgets('shows a count', (tester) async {
      await pumpTabs(
        tester,
        AppTabs(
          tabs: const [AppTabItem(label: 'Unread', count: 7)],
          selectedIndex: 0,
          onChanged: (_) {},
        ),
      );
      expect(find.text('7'), findsOneWidget);
    });
  });
}
