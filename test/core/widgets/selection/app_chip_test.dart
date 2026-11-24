import 'package:classmeet/core/assets/app_icons.dart';
import 'package:classmeet/core/theme/app_colors.dart';
import 'package:classmeet/core/theme/app_semantic_colors.dart';
import 'package:classmeet/core/theme/app_theme.dart';
import 'package:classmeet/core/widgets/selection/app_chip.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> pumpChip(WidgetTester tester, Widget chip) async {
  await tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.light,
      home: Scaffold(body: Center(child: chip)),
    ),
  );
}

Color? painted(WidgetTester tester) => tester
    .widget<Material>(
      find.descendant(
        of: find.byType(TextButton),
        matching: find.byType(Material),
      ),
    )
    .color;

void main() {
  const colors = AppSemanticColors.light;

  group('geometry', () {
    test('measurements match the screens', () {
      expect(
        {
          for (final s in AppChipStyle.values)
            s.name: (s.height, s.padding, s.radius),
        },
        {
          'outline': (36, 16, 32),
          'tonal': (32, 12, 16),
          'neutral': (36, 16, 32),
        },
      );
    });

    for (final style in AppChipStyle.values) {
      testWidgets('${style.name}: height and horizontal padding', (
        tester,
      ) async {
        await pumpChip(
          tester,
          AppChip.filter(
            label: 'Friend',
            selected: false,
            onSelected: (_) {},
            style: style,
          ),
        );
        final size = tester.getSize(find.byType(TextButton));
        expect(size.height, style.height);
        expect(
          size.width,
          2 * style.padding + tester.getSize(find.text('Friend')).width,
        );
      });
    }
  });

  group('behaviour', () {
    testWidgets('filter toggles', (tester) async {
      final calls = <bool>[];
      await pumpChip(
        tester,
        AppChip.filter(label: 'All', selected: false, onSelected: calls.add),
      );
      await tester.tap(find.text('All'));
      await pumpChip(
        tester,
        AppChip.filter(label: 'All', selected: true, onSelected: calls.add),
      );
      await tester.tap(find.text('All'));
      expect(calls, [true, false]);
    });

    testWidgets('choice reports only when it becomes selected', (tester) async {
      final calls = <bool>[];
      await pumpChip(
        tester,
        AppChip.choice(label: 'Class', selected: true, onSelected: calls.add),
      );
      await tester.tap(find.text('Class'));
      expect(calls, isEmpty);
      await pumpChip(
        tester,
        AppChip.choice(label: 'Class', selected: false, onSelected: calls.add),
      );
      await tester.tap(find.text('Class'));
      expect(calls, [true]);
    });

    testWidgets('multi-select toggles and shows a check when selected', (
      tester,
    ) async {
      final calls = <bool>[];
      await pumpChip(
        tester,
        AppChip.multiSelect(
          label: 'Math',
          selected: false,
          onSelected: calls.add,
        ),
      );
      expect(find.byIcon(AppIcons.check), findsNothing);
      await tester.tap(find.text('Math'));
      expect(calls, [true]);
      await pumpChip(
        tester,
        AppChip.multiSelect(
          label: 'Math',
          selected: true,
          onSelected: calls.add,
        ),
      );
      expect(find.byIcon(AppIcons.check), findsOneWidget);
      await tester.tap(find.text('Math'));
      expect(calls, [true, false]);
    });

    testWidgets('a disabled chip ignores taps', (tester) async {
      await pumpChip(
        tester,
        const AppChip.filter(label: 'All', selected: false, onSelected: null),
      );
      await tester.tap(find.text('All'), warnIfMissed: false);
      expect(
        tester.widget<TextButton>(find.byType(TextButton)).enabled,
        isFalse,
      );
    });

    testWidgets('remove x calls onDeleted and not onSelected', (tester) async {
      var selects = 0;
      var deletes = 0;
      await pumpChip(
        tester,
        AppChip.filter(
          label: 'Tag',
          selected: true,
          onSelected: (_) => selects++,
          onDeleted: () => deletes++,
        ),
      );
      await tester.tap(find.byIcon(AppIcons.x));
      expect((selects, deletes), (0, 1));
    });

    testWidgets('leading icon shows', (tester) async {
      await pumpChip(
        tester,
        AppChip.filter(
          label: 'Me',
          selected: false,
          onSelected: (_) {},
          leadingIcon: AppIcons.user,
        ),
      );
      expect(find.byIcon(AppIcons.user), findsOneWidget);
    });
  });

  group('colours', () {
    ButtonStyle styleOf(
      AppChipStyle s, {
      required bool selected,
      bool disabled = false,
    }) => AppChip.filter(
      label: 'x',
      selected: selected,
      onSelected: disabled ? null : (_) {},
      style: s,
    ).buttonStyle(colors);

    test('neutral (96, 97, 99): grey outline off, sage fill on', () {
      final off = styleOf(AppChipStyle.neutral, selected: false);
      expect(off.backgroundColor!.resolve({}), AppColors.white);
      expect(off.foregroundColor!.resolve({}), AppColors.grey500);
      expect(
        off.side!.resolve({}),
        const BorderSide(color: AppColors.grey200, width: 1.5),
      );
      expect(
        off.backgroundColor!.resolve({WidgetState.pressed}),
        AppColors.grey100,
      );

      final on = styleOf(AppChipStyle.neutral, selected: true);
      expect(on.backgroundColor!.resolve({}), AppColors.sage500);
      expect(on.foregroundColor!.resolve({}), Colors.white);
      expect(on.side!.resolve({})!.color, AppColors.sage500);

      final dis = styleOf(
        AppChipStyle.neutral,
        selected: false,
        disabled: true,
      );
      expect(dis.side!.resolve({})!.color, AppColors.grey200);
    });

    test('outline: selected, unselected and disabled', () {
      final on = styleOf(AppChipStyle.outline, selected: true);
      expect(on.backgroundColor!.resolve({}), AppColors.sage500);
      expect(on.foregroundColor!.resolve({}), Colors.white);
      expect(
        on.backgroundColor!.resolve({WidgetState.hovered}),
        AppColors.sage700,
      );
      expect(
        on.backgroundColor!.resolve({WidgetState.pressed}),
        AppColors.sage900,
      );

      final off = styleOf(AppChipStyle.outline, selected: false);
      expect(off.backgroundColor!.resolve({}), Colors.transparent);
      expect(off.foregroundColor!.resolve({}), AppColors.sage500);
      expect(
        off.side!.resolve({}),
        const BorderSide(color: AppColors.sage500, width: 1.5),
      );
      expect(
        off.backgroundColor!.resolve({WidgetState.hovered}),
        AppColors.sage50,
      );
      expect(
        off.backgroundColor!.resolve({WidgetState.pressed}),
        AppColors.sage100,
      );
      expect(
        off.side!.resolve({WidgetState.focused}),
        const BorderSide(
          color: AppColors.sage300,
          width: AppChip.focusBorderWidth,
        ),
      );

      final dis = styleOf(
        AppChipStyle.outline,
        selected: false,
        disabled: true,
      );
      expect(dis.foregroundColor!.resolve({}), colors.textGrey);
      expect(
        dis.side!.resolve({}),
        const BorderSide(color: AppColors.grey200, width: 1.5),
      );
    });

    test('tonal: selected, unselected and disabled', () {
      final off = styleOf(AppChipStyle.tonal, selected: false);
      expect(off.backgroundColor!.resolve({}), AppColors.grey100);
      expect(off.foregroundColor!.resolve({}), colors.textSecondary);
      expect(off.side!.resolve({}), BorderSide.none);
      final on = styleOf(AppChipStyle.tonal, selected: true);
      expect(on.backgroundColor!.resolve({}), AppColors.sage500);
      final dis = styleOf(AppChipStyle.tonal, selected: false, disabled: true);
      expect(dis.backgroundColor!.resolve({}), AppColors.grey100);
      expect(dis.foregroundColor!.resolve({}), colors.textGrey);
    });

    testWidgets('a states controller shows hover without interaction', (
      tester,
    ) async {
      final controller = WidgetStatesController({WidgetState.hovered});
      addTearDown(controller.dispose);
      await pumpChip(
        tester,
        AppChip.filter(
          label: 'x',
          selected: true,
          onSelected: (_) {},
          statesController: controller,
        ),
      );
      expect(painted(tester), AppColors.sage700);
    });
  });

  testWidgets('a long label ellipsizes instead of overflowing at 360', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(360, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await pumpChip(
      tester,
      SizedBox(
        width: 160,
        child: AppChip.multiSelect(
          label: 'A very long chip label that cannot fit',
          selected: true,
          onSelected: (_) {},
          onDeleted: () {},
        ),
      ),
    );
    expect(tester.takeException(), isNull);
  });
}
