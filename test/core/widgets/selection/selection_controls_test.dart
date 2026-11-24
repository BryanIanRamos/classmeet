import 'package:classmeet/core/assets/app_icons.dart';
import 'package:classmeet/core/theme/app_colors.dart';
import 'package:classmeet/core/theme/app_semantic_colors.dart';
import 'package:classmeet/core/theme/app_theme.dart';
import 'package:classmeet/core/widgets/selection/app_checkbox.dart';
import 'package:classmeet/core/widgets/selection/app_radio.dart';
import 'package:classmeet/core/widgets/selection/app_toggle.dart';
import 'package:classmeet/core/widgets/selection/selectable_card.dart';
import 'package:classmeet/core/widgets/selection/selection_support.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> pump(
  WidgetTester tester,
  Widget child, {
  double width = 428,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.light,
      home: Scaffold(
        body: Center(
          child: SizedBox(
            width: width,
            child: Center(child: child),
          ),
        ),
      ),
    ),
  );
}

/// The decoration of the first Container with a BoxDecoration under [of].
BoxDecoration decorationOf(WidgetTester tester, Finder of) {
  return find
      .descendant(of: of, matching: find.byType(Container))
      .evaluate()
      .map((e) => (e.widget as Container).decoration)
      .whereType<BoxDecoration>()
      .first;
}

/// The tap handler wired under [of]; null when the control is disabled.
VoidCallback? tapHandler(WidgetTester tester, Finder of) => tester
    .widget<GestureDetector>(
      find.descendant(of: of, matching: find.byType(GestureDetector)),
    )
    .onTap;

void main() {
  const colors = AppSemanticColors.light;
  const noStates = <WidgetState>{};
  const hover = {WidgetState.hovered};
  const focus = {WidgetState.focused};
  const disabled = {WidgetState.disabled};

  group('AppRadio', () {
    testWidgets('is 24x24 with a 12 dot when selected', (tester) async {
      await pump(
        tester,
        AppRadio<int>(value: 1, groupValue: 1, onChanged: (_) {}),
      );
      expect(tester.getSize(find.byType(AppRadio<int>)), const Size(24, 24));
      expect(
        tester.getSize(find.byKey(const ValueKey('radio-dot'))),
        const Size(12, 12),
      );
      final box = decorationOf(tester, find.byType(AppRadio<int>));
      expect(box.shape, BoxShape.circle);
      expect((box.border! as Border).top.width, 1.5);
      expect((box.border! as Border).top.color, AppColors.sage500);
    });

    testWidgets('unselected has no dot', (tester) async {
      await pump(
        tester,
        AppRadio<int>(value: 1, groupValue: 2, onChanged: (_) {}),
      );
      expect(find.byKey(const ValueKey('radio-dot')), findsNothing);
    });

    test('colours per state', () {
      final radio = AppRadio<int>(value: 1, groupValue: 0, onChanged: (_) {});
      expect(radio.fillColor(noStates), Colors.transparent);
      expect(radio.fillColor(hover), AppColors.sage50);
      expect(radio.fillColor(focus), AppColors.white);
      expect(radio.borderColor(noStates), AppColors.sage500);
      expect(radio.borderColor(disabled), AppColors.grey200);
    });

    testWidgets('focus shows a 3px Sage-300 ring', (tester) async {
      final controller = WidgetStatesController({WidgetState.focused});
      addTearDown(controller.dispose);
      await pump(
        tester,
        AppRadio<int>(
          value: 1,
          groupValue: 0,
          onChanged: (_) {},
          statesController: controller,
        ),
      );
      final shadow = decorationOf(
        tester,
        find.byType(AppRadio<int>),
      ).boxShadow!.single;
      expect(shadow.spreadRadius, 3);
      expect(shadow.blurRadius, 0);
      expect(shadow.color, AppColors.sage300);
    });

    testWidgets('radio group: tapping selects, selected tap is ignored', (
      tester,
    ) async {
      var group = 'a';
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) => Column(
                children: [
                  for (final v in ['a', 'b'])
                    AppRadio<String>(
                      key: ValueKey(v),
                      value: v,
                      groupValue: group,
                      label: v,
                      onChanged: (x) => setState(() => group = x),
                    ),
                ],
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.byKey(const ValueKey('b')));
      await tester.pump();
      expect(group, 'b');
      expect(
        find.descendant(
          of: find.byKey(const ValueKey('b')),
          matching: find.byKey(const ValueKey('radio-dot')),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byKey(const ValueKey('a')),
          matching: find.byKey(const ValueKey('radio-dot')),
        ),
        findsNothing,
      );
    });

    testWidgets('disabled ignores taps', (tester) async {
      await pump(
        tester,
        const AppRadio<int>(value: 1, groupValue: 0, onChanged: null),
      );
      expect(tapHandler(tester, find.byType(AppRadio<int>)), isNull);
      await tester.tap(find.byType(AppRadio<int>));
      expect(tester.takeException(), isNull);
    });

    testWidgets('activeColor recolours border and dot', (tester) async {
      await pump(
        tester,
        AppRadio<int>(
          value: 1,
          groupValue: 1,
          onChanged: (_) {},
          activeColor: AppColors.sprout500,
        ),
      );
      final box = decorationOf(tester, find.byType(AppRadio<int>));
      expect((box.border! as Border).top.color, AppColors.sprout500);
    });

    testWidgets('text side left: control then 16 gap then text', (
      tester,
    ) async {
      await pump(
        tester,
        AppRadio<int>(
          value: 1,
          groupValue: 0,
          onChanged: (_) {},
          label: 'Placeholder',
        ),
      );
      final radio = tester.getRect(find.byType(Container).first);
      final text = tester.getRect(find.text('Placeholder'));
      expect(radio.left, lessThan(text.left));
      expect(text.left - radio.right, 16);
      expect(tester.getSize(find.byType(AppRadio<int>)).height, 24);
    });

    testWidgets('text side right: text then control', (tester) async {
      await pump(
        tester,
        AppRadio<int>(
          value: 1,
          groupValue: 0,
          onChanged: (_) {},
          label: 'Placeholder',
          textSide: AppTextSide.right,
        ),
      );
      final radio = tester.getRect(find.byType(Container).first);
      final text = tester.getRect(find.text('Placeholder'));
      expect(text.left, lessThan(radio.left));
      expect(radio.left - text.right, 16);
    });

    testWidgets('label colours: primary, grey when disabled', (tester) async {
      await pump(
        tester,
        AppRadio<int>(
          value: 1,
          groupValue: 0,
          onChanged: (_) {},
          label: 'Placeholder',
        ),
      );
      expect(
        tester.widget<Text>(find.text('Placeholder')).style!.color,
        colors.textPrimary,
      );
      await pump(
        tester,
        const AppRadio<int>(
          value: 1,
          groupValue: 0,
          onChanged: null,
          label: 'Placeholder',
        ),
      );
      expect(
        tester.widget<Text>(find.text('Placeholder')).style!.color,
        colors.textGrey,
      );
    });

    testWidgets('tapping the label selects', (tester) async {
      int? picked;
      await pump(
        tester,
        AppRadio<int>(
          value: 7,
          groupValue: 0,
          onChanged: (v) => picked = v,
          label: 'Seven',
        ),
      );
      await tester.tap(find.text('Seven'));
      expect(picked, 7);
    });
  });

  group('AppCheckbox', () {
    test('size table matches the DS box', () {
      expect(AppCheckboxSize.medium.box, 24);
      expect(AppCheckboxSize.medium.radius, 8);
      expect(AppCheckboxSize.medium.iconSize, 20);
    });

    for (final size in AppCheckboxSize.values) {
      testWidgets('${size.name}: box geometry', (tester) async {
        await pump(
          tester,
          AppCheckbox(value: false, onChanged: (_) {}, size: size),
        );
        expect(tester.getSize(find.byType(AppCheckbox)), Size.square(size.box));
        final box = decorationOf(tester, find.byType(AppCheckbox));
        expect(box.borderRadius, BorderRadius.circular(size.radius));
      });
    }

    testWidgets('checked shows a 20px white check on a Sage-500 fill', (
      tester,
    ) async {
      await pump(tester, AppCheckbox(value: true, onChanged: (_) {}));
      final icon = tester.widget<Icon>(find.byIcon(AppIcons.check));
      expect(icon.size, 20);
      expect(icon.color, AppColors.white);
      expect(
        decorationOf(tester, find.byType(AppCheckbox)).color,
        AppColors.sage500,
      );
    });

    testWidgets('indeterminate shows a minus', (tester) async {
      await pump(tester, AppCheckbox(value: null, onChanged: (_) {}));
      expect(find.byIcon(AppIcons.minus), findsOneWidget);
      expect(find.byIcon(AppIcons.check), findsNothing);
    });

    testWidgets('unchecked shows no mark', (tester) async {
      await pump(tester, AppCheckbox(value: false, onChanged: (_) {}));
      expect(find.byIcon(AppIcons.check), findsNothing);
      expect(find.byIcon(AppIcons.minus), findsNothing);
    });

    test('colours per state', () {
      final off = AppCheckbox(value: false, onChanged: (_) {});
      expect(off.fillColor(noStates), Colors.transparent);
      expect(off.fillColor(hover), AppColors.sage50);
      expect(off.fillColor(focus), AppColors.white);
      expect(off.borderColor(noStates), AppColors.sage500);
      expect(off.borderColor(disabled), AppColors.grey200);
      final on = AppCheckbox(value: true, onChanged: (_) {});
      expect(on.fillColor(noStates), AppColors.sage500);
      expect(on.fillColor(disabled), AppColors.grey200);
    });

    testWidgets('tri-state tap: false/null become true, true becomes false', (
      tester,
    ) async {
      final calls = <bool>[];
      for (final value in <bool?>[false, null, true]) {
        await pump(tester, AppCheckbox(value: value, onChanged: calls.add));
        await tester.tap(find.byType(AppCheckbox));
      }
      expect(calls, [true, true, false]);
    });

    testWidgets('disabled ignores taps', (tester) async {
      await pump(
        tester,
        const AppCheckbox(value: false, onChanged: null, label: 'Disabled'),
      );
      expect(tapHandler(tester, find.byType(AppCheckbox)), isNull);
      await tester.tap(find.text('Disabled'));
      expect(
        tester.widget<Text>(find.text('Disabled')).style!.color,
        colors.textGrey,
      );
    });

    testWidgets('text side left and right', (tester) async {
      await pump(
        tester,
        AppCheckbox(value: false, onChanged: (_) {}, label: 'Placeholder'),
      );
      var box = tester.getRect(find.byType(Container).first);
      var text = tester.getRect(find.text('Placeholder'));
      expect(text.left - box.right, 16);
      await pump(
        tester,
        AppCheckbox(
          value: false,
          onChanged: (_) {},
          label: 'Placeholder',
          textSide: AppTextSide.right,
        ),
      );
      box = tester.getRect(find.byType(Container).first);
      text = tester.getRect(find.text('Placeholder'));
      expect(box.left - text.right, 16);
    });
  });

  group('AppToggle', () {
    testWidgets('is 44x24 with a 20 white knob', (tester) async {
      await pump(tester, AppToggle(value: false, onChanged: (_) {}));
      expect(tester.getSize(find.byType(AppToggle)), const Size(44, 24));
      final knob = find.byKey(const ValueKey('toggle-knob'));
      expect(tester.getSize(knob), const Size(20, 20));
      expect(
        tester.getTopLeft(knob) - tester.getTopLeft(find.byType(AppToggle)),
        const Offset(2, 2),
      );
    });

    testWidgets('knob moves to the right when on', (tester) async {
      await pump(tester, AppToggle(value: true, onChanged: (_) {}));
      final knob = find.byKey(const ValueKey('toggle-knob'));
      expect(
        tester.getTopRight(find.byType(AppToggle)).dx -
            tester.getTopRight(knob).dx,
        2,
      );
    });

    test('track colours per state', () {
      final off = AppToggle(value: false, onChanged: (_) {});
      expect(off.trackColor(noStates), AppColors.grey200);
      expect(off.trackColor(hover), AppColors.grey300);
      expect(off.trackColor(focus), AppColors.grey200);
      expect(off.trackColor(disabled), AppColors.grey100);
      final on = AppToggle(value: true, onChanged: (_) {});
      expect(on.trackColor(noStates), AppColors.plume500);
      expect(on.trackColor(disabled), AppColors.plume50);
    });

    testWidgets('tap flips the value', (tester) async {
      bool? result;
      await pump(tester, AppToggle(value: false, onChanged: (v) => result = v));
      await tester.tap(find.byType(AppToggle));
      expect(result, true);
      await pump(tester, AppToggle(value: true, onChanged: (v) => result = v));
      await tester.tap(find.byType(AppToggle));
      expect(result, false);
    });

    testWidgets('disabled ignores taps and greys the label', (tester) async {
      await pump(
        tester,
        const AppToggle(value: false, onChanged: null, label: 'Placeholder'),
      );
      expect(tapHandler(tester, find.byType(AppToggle)), isNull);
      await tester.tap(find.text('Placeholder'));
      expect(
        tester.widget<Text>(find.text('Placeholder')).style!.color,
        colors.textGrey,
      );
    });

    testWidgets('text side left and right', (tester) async {
      await pump(
        tester,
        AppToggle(value: false, onChanged: (_) {}, label: 'Placeholder'),
      );
      var box = tester.getRect(find.byType(Container).first);
      var text = tester.getRect(find.text('Placeholder'));
      expect(text.left - box.right, 16);
      await pump(
        tester,
        AppToggle(
          value: false,
          onChanged: (_) {},
          label: 'Placeholder',
          textSide: AppTextSide.right,
        ),
      );
      box = tester.getRect(find.byType(Container).first);
      text = tester.getRect(find.text('Placeholder'));
      expect(box.left - text.right, 16);
    });
  });

  group('SelectableCard', () {
    testWidgets('selected is Sage-500 with white text and a check', (
      tester,
    ) async {
      await pump(
        tester,
        SelectableCard(
          title: '15 min',
          description: 'A little each day',
          selected: true,
          onTap: () {},
        ),
      );
      final deco = decorationOf(tester, find.byType(SelectableCard));
      expect(deco.color, AppColors.sage500);
      expect(deco.borderRadius, BorderRadius.circular(16));
      expect(
        tester.widget<Text>(find.text('15 min')).style!.color,
        colors.textPrimaryWhite,
      );
      expect(
        tester.widget<Text>(find.text('A little each day')).style!.color,
        colors.textSecondaryWhite,
      );
      expect(find.byIcon(AppIcons.check), findsOneWidget);
    });

    testWidgets('unselected is Sage-50 with dark text and no check', (
      tester,
    ) async {
      await pump(
        tester,
        SelectableCard(
          title: '30 min',
          description: 'Stay on track',
          selected: false,
          onTap: () {},
        ),
      );
      expect(
        decorationOf(tester, find.byType(SelectableCard)).color,
        AppColors.sage50,
      );
      expect(
        tester.widget<Text>(find.text('30 min')).style!.color,
        colors.textPrimary,
      );
      expect(find.byIcon(AppIcons.check), findsNothing);
      final indicator = tester.getSize(
        find.byKey(const ValueKey('card-indicator')),
      );
      expect(indicator, const Size(24, 24));
    });

    testWidgets('radio indicator shows a dot instead of a check', (
      tester,
    ) async {
      await pump(
        tester,
        SelectableCard(
          title: 'x',
          selected: true,
          onTap: () {},
          indicator: SelectableCardIndicator.radio,
        ),
      );
      expect(find.byIcon(AppIcons.check), findsNothing);
      expect(
        decorationOf(
          tester,
          find.byKey(const ValueKey('card-indicator')),
        ).shape,
        BoxShape.circle,
      );
    });

    testWidgets('tap calls onTap; null onTap ignores taps', (tester) async {
      var taps = 0;
      await pump(
        tester,
        SelectableCard(title: 'a', selected: false, onTap: () => taps++),
      );
      await tester.tap(find.text('a'));
      expect(taps, 1);
      await pump(
        tester,
        const SelectableCard(title: 'a', selected: false, onTap: null),
      );
      await tester.tap(find.text('a'));
      expect(taps, 1);
      expect(
        decorationOf(tester, find.byType(SelectableCard)).color,
        AppColors.grey50,
      );
    });
  });

  group('no overflow at 360dp', () {
    testWidgets('long labels wrap inside every control and the card', (
      tester,
    ) async {
      const long =
          'A very long label that should wrap rather than overflow the row';
      await pump(
        tester,
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppRadio<int>(
              value: 1,
              groupValue: 1,
              onChanged: (_) {},
              label: long,
            ),
            AppCheckbox(value: true, onChanged: (_) {}, label: long),
            AppToggle(
              value: true,
              onChanged: (_) {},
              label: long,
              textSide: AppTextSide.right,
            ),
            SelectableCard(
              title: long,
              description: long,
              selected: true,
              onTap: () {},
            ),
          ],
        ),
        width: 360,
      );
      expect(tester.takeException(), isNull);
    });
  });
}
