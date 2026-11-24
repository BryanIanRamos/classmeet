import 'package:classmeet/core/assets/app_icons.dart';
import 'package:classmeet/core/theme/app_colors.dart';
import 'package:classmeet/core/theme/app_theme.dart';
import 'package:classmeet/core/widgets/inputs/app_dropdown.dart';
import 'package:classmeet/core/widgets/inputs/app_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

const items = [
  AppDropdownItem(value: 1, label: 'Option 1', icon: AppIcons.star),
  AppDropdownItem(value: 2, label: 'Option 2', icon: AppIcons.star),
  AppDropdownItem(value: 3, label: 'Option 3', enabled: false),
];

Future<void> pumpDropdown(
  WidgetTester tester,
  AppDropdown<int> dropdown, {
  double width = 350,
  Alignment alignment = Alignment.topLeft,
}) async {
  await tester.binding.setSurfaceSize(const Size(428, 800));
  addTearDown(() => tester.binding.setSurfaceSize(null));
  await tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.light,
      home: Scaffold(
        body: Align(
          alignment: alignment,
          child: SizedBox(width: width, child: dropdown),
        ),
      ),
    ),
  );
}

BoxDecoration boxDecoration(WidgetTester tester) =>
    tester.widget<DecoratedBox>(find.byKey(AppDropdown.boxKey)).decoration
        as BoxDecoration;

Color borderColor(WidgetTester tester) =>
    (boxDecoration(tester).border! as Border).top.color;

void main() {
  group('field (matches AppTextField)', () {
    testWidgets('large: 48 high, radius 12, 1.5 grey-200 border', (
      tester,
    ) async {
      await pumpDropdown(
        tester,
        AppDropdown<int>(
          placeholder: 'Select',
          items: items,
          value: null,
          onChanged: (_) {},
        ),
      );
      expect(
        tester.getSize(find.byKey(AppDropdown.boxKey)),
        const Size(350, 48),
      );
      expect(boxDecoration(tester).borderRadius, BorderRadius.circular(12));
      expect(borderColor(tester), AppColors.grey200);
      expect(find.text('Select'), findsOneWidget);
      expect(
        tester.getSize(find.byIcon(AppIcons.chevronDown)),
        const Size.square(24),
      );
    });

    testWidgets('medium: 40 high, radius 8', (tester) async {
      await pumpDropdown(
        tester,
        AppDropdown<int>(
          size: AppTextFieldSize.medium,
          items: items,
          value: 1,
          onChanged: (_) {},
        ),
      );
      expect(tester.getSize(find.byKey(AppDropdown.boxKey)).height, 40);
      expect(boxDecoration(tester).borderRadius, BorderRadius.circular(8));
    });

    testWidgets('shows the label, helper, and the selected item', (
      tester,
    ) async {
      await pumpDropdown(
        tester,
        AppDropdown<int>(
          label: 'School',
          helperText: 'Pick one',
          items: items,
          value: 2,
          onChanged: (_) {},
        ),
      );
      expect(find.text('School'), findsOneWidget);
      expect(find.text('Pick one'), findsOneWidget);
      expect(find.text('Option 2'), findsOneWidget);
      expect(find.byIcon(AppIcons.star), findsOneWidget);
    });

    testWidgets('error text replaces helper, border is ember-500', (
      tester,
    ) async {
      await pumpDropdown(
        tester,
        AppDropdown<int>(
          helperText: 'Pick one',
          errorText: 'Required',
          items: items,
          value: null,
          onChanged: (_) {},
        ),
      );
      expect(find.text('Required'), findsOneWidget);
      expect(find.text('Pick one'), findsNothing);
      expect(borderColor(tester), AppColors.ember500);
      expect(
        tester.widget<Text>(find.text('Required')).style!.color,
        AppColors.ember500,
      );
    });

    testWidgets('accent colour tints the idle border', (tester) async {
      await pumpDropdown(
        tester,
        AppDropdown<int>(
          accentColor: AppColors.plume300,
          items: items,
          value: null,
          onChanged: (_) {},
        ),
      );
      expect(borderColor(tester), AppColors.plume300);
    });

    testWidgets('hover state darkens the border to grey-400', (tester) async {
      final states = WidgetStatesController({WidgetState.hovered});
      addTearDown(states.dispose);
      await pumpDropdown(
        tester,
        AppDropdown<int>(
          items: items,
          value: null,
          onChanged: (_) {},
          statesController: states,
        ),
      );
      expect(borderColor(tester), AppColors.grey400);
    });
  });

  group('confirmSelection (96 School)', () {
    testWidgets('a selected value shows a grey-900 border and a check', (
      tester,
    ) async {
      await pumpDropdown(
        tester,
        AppDropdown<int>(
          items: items,
          value: 1,
          onChanged: (_) {},
          accentColor: AppColors.plume500,
          confirmSelection: true,
        ),
      );
      expect(borderColor(tester), AppColors.grey900);
      expect(find.byIcon(AppIcons.check), findsOneWidget);
      expect(find.byIcon(AppIcons.chevronDown), findsNothing);
    });

    testWidgets('without a value it keeps the accent and the chevron', (
      tester,
    ) async {
      await pumpDropdown(
        tester,
        AppDropdown<int>(
          items: items,
          value: null,
          placeholder: 'Select College',
          onChanged: (_) {},
          accentColor: AppColors.plume500,
          confirmSelection: true,
        ),
      );
      expect(borderColor(tester), AppColors.plume500);
      expect(find.byIcon(AppIcons.chevronDown), findsOneWidget);
    });

    testWidgets('off by default: a selected value keeps the chevron', (
      tester,
    ) async {
      await pumpDropdown(
        tester,
        AppDropdown<int>(items: items, value: 1, onChanged: (_) {}),
      );
      expect(find.byIcon(AppIcons.chevronDown), findsOneWidget);
      expect(borderColor(tester), isNot(AppColors.grey900));
    });
  });

  group('menu', () {
    testWidgets('opens on tap, shows the rows, selecting closes it', (
      tester,
    ) async {
      int? picked;
      await pumpDropdown(
        tester,
        AppDropdown<int>(
          placeholder: 'Select',
          items: items,
          value: null,
          onChanged: (v) => picked = v,
        ),
      );
      expect(find.byKey(AppDropdownMenu.menuKey), findsNothing);
      await tester.tap(find.byKey(AppDropdown.boxKey));
      await tester.pumpAndSettle();
      expect(find.byKey(AppDropdownMenu.menuKey), findsOneWidget);
      expect(find.text('Option 1'), findsOneWidget);
      expect(find.text('Option 3'), findsOneWidget);

      // Expanded state: sage-500 border with a 3 wide sage-300 ring.
      expect(borderColor(tester), AppColors.sage500);
      final ring = boxDecoration(tester).boxShadow!.single;
      expect(ring.spreadRadius, 3);
      expect(ring.color, AppColors.sage300);

      await tester.tap(find.text('Option 2'));
      await tester.pumpAndSettle();
      expect(picked, 2);
      expect(find.byKey(AppDropdownMenu.menuKey), findsNothing);
    });

    testWidgets('menu geometry: width of field, 8 gap, rows 48 high', (
      tester,
    ) async {
      await pumpDropdown(
        tester,
        AppDropdown<int>(items: items, value: 1, onChanged: (_) {}),
      );
      await tester.tap(find.byKey(AppDropdown.boxKey));
      await tester.pumpAndSettle();
      final field = tester.getRect(find.byKey(AppDropdown.boxKey));
      final menu = tester.getRect(find.byKey(AppDropdownMenu.menuKey));
      expect(menu.left, field.left);
      expect(menu.width, field.width);
      expect(menu.top - field.bottom, 8);
      expect(tester.getSize(find.byKey(AppDropdownMenu.rowKey(0))).height, 48);
      // 8 + 3 rows of 48 + 2 gaps of 8 + 8
      expect(menu.height, 8 + 3 * 48 + 2 * 8 + 8);
    });

    testWidgets('the selected row shows a check', (tester) async {
      await pumpDropdown(
        tester,
        AppDropdown<int>(items: items, value: 2, onChanged: (_) {}),
      );
      await tester.tap(find.byKey(AppDropdown.boxKey));
      await tester.pumpAndSettle();
      expect(
        find.descendant(
          of: find.byKey(AppDropdownMenu.rowKey(1)),
          matching: find.byIcon(AppIcons.check),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byKey(AppDropdownMenu.rowKey(0)),
          matching: find.byIcon(AppIcons.check),
        ),
        findsNothing,
      );
    });

    testWidgets('a disabled row ignores taps', (tester) async {
      int? picked;
      await pumpDropdown(
        tester,
        AppDropdown<int>(
          items: items,
          value: null,
          onChanged: (v) => picked = v,
        ),
      );
      await tester.tap(find.byKey(AppDropdown.boxKey));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Option 3'));
      await tester.pumpAndSettle();
      expect(picked, isNull);
      expect(find.byKey(AppDropdownMenu.menuKey), findsOneWidget);
    });

    testWidgets('tapping outside closes without selecting', (tester) async {
      int? picked;
      await pumpDropdown(
        tester,
        AppDropdown<int>(
          items: items,
          value: null,
          onChanged: (v) => picked = v,
        ),
      );
      await tester.tap(find.byKey(AppDropdown.boxKey));
      await tester.pumpAndSettle();
      await tester.tapAt(const Offset(400, 700));
      await tester.pumpAndSettle();
      expect(find.byKey(AppDropdownMenu.menuKey), findsNothing);
      expect(picked, isNull);
    });

    testWidgets('opens above when there is no room below', (tester) async {
      await pumpDropdown(
        tester,
        AppDropdown<int>(items: items, value: null, onChanged: (_) {}),
        alignment: Alignment.bottomLeft,
      );
      await tester.tap(find.byKey(AppDropdown.boxKey));
      await tester.pumpAndSettle();
      final field = tester.getRect(find.byKey(AppDropdown.boxKey));
      final menu = tester.getRect(find.byKey(AppDropdownMenu.menuKey));
      expect(field.top - menu.bottom, 8);
    });

    testWidgets('disabled dropdown cannot open', (tester) async {
      await pumpDropdown(
        tester,
        const AppDropdown<int>(
          placeholder: 'Select',
          items: items,
          value: null,
          onChanged: null,
        ),
      );
      expect(borderColor(tester), AppColors.grey200);
      await tester.tap(find.byKey(AppDropdown.boxKey));
      await tester.pumpAndSettle();
      expect(find.byKey(AppDropdownMenu.menuKey), findsNothing);
    });

    testWidgets('no overflow at 360dp with a long label', (tester) async {
      await tester.binding.setSurfaceSize(const Size(360, 800));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await pumpDropdown(
        tester,
        AppDropdown<int>(
          items: const [
            AppDropdownItem(
              value: 1,
              label: 'A very long option name that cannot possibly fit here',
              icon: AppIcons.star,
            ),
          ],
          value: 1,
          onChanged: (_) {},
        ),
        width: 320,
      );
      await tester.tap(find.byKey(AppDropdown.boxKey));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  });
}
