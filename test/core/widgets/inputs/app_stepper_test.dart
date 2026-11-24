import 'package:classmeet/core/assets/app_icons.dart';
import 'package:classmeet/core/theme/app_colors.dart';
import 'package:classmeet/core/theme/app_theme.dart';
import 'package:classmeet/core/widgets/inputs/app_stepper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> pumpStepper(WidgetTester tester, Widget stepper) async {
  await tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.light,
      home: Scaffold(
        body: Align(alignment: Alignment.topLeft, child: stepper),
      ),
    ),
  );
}

BoxDecoration decoration(WidgetTester tester) =>
    tester
            .widget<DecoratedBox>(
              find
                  .descendant(
                    of: find.byType(AppStepper),
                    matching: find.byType(DecoratedBox),
                  )
                  .first,
            )
            .decoration
        as BoxDecoration;

Color iconColor(WidgetTester tester, IconData icon) =>
    tester.widget<Icon>(find.byIcon(icon)).color!;

/// A stepper whose value follows the callback, as a screen would use it.
class _Host extends StatefulWidget {
  const _Host({required this.step});

  final int step;

  @override
  State<_Host> createState() => _HostState();
}

class _HostState extends State<_Host> {
  int value = 5;

  @override
  Widget build(BuildContext context) => AppStepper(
    value: value,
    max: 10,
    step: widget.step,
    onChanged: (v) => setState(() => value = v),
  );
}

void main() {
  group('geometry (DS Stepper 5248:10391)', () {
    testWidgets('bare control is 97.5 x 32 with radius 8', (tester) async {
      await pumpStepper(
        tester,
        AppStepper(value: 1, onChanged: (_) {}, showValue: false),
      );
      expect(tester.getSize(find.byType(AppStepper)), const Size(97.5, 32));
      expect(decoration(tester).borderRadius, BorderRadius.circular(8));
      expect(
        tester.getSize(find.byIcon(AppIcons.minus)),
        const Size.square(24),
      );
      expect(tester.getSize(find.byIcon(AppIcons.plus)), const Size.square(24));
      final minus = tester.getRect(find.byIcon(AppIcons.minus));
      final plus = tester.getRect(find.byIcon(AppIcons.plus));
      expect(minus.left, 12);
      expect(plus.left - minus.right, 12 + 1.5 + 12);
    });

    testWidgets('with value: stays 32 high and shows the number', (
      tester,
    ) async {
      await pumpStepper(tester, AppStepper(value: 7, onChanged: (_) {}));
      expect(tester.getSize(find.byType(AppStepper)).height, 32);
      expect(find.text('7'), findsOneWidget);
    });
  });

  group('styles', () {
    testWidgets('filled: sage-50 fill, sage-500 icons', (tester) async {
      await pumpStepper(tester, AppStepper(value: 5, onChanged: (_) {}));
      expect(decoration(tester).color, AppColors.sage50);
      expect(decoration(tester).border, isNull);
      expect(iconColor(tester, AppIcons.minus), AppColors.sage500);
      expect(iconColor(tester, AppIcons.plus), AppColors.sage500);
    });

    testWidgets('outline: white fill, grey-200 border, dark icons', (
      tester,
    ) async {
      await pumpStepper(
        tester,
        AppStepper(value: 5, onChanged: (_) {}, style: AppStepperStyle.outline),
      );
      expect(decoration(tester).color, AppColors.white);
      final side = (decoration(tester).border! as Border).top;
      expect(side.color, AppColors.grey200);
      expect(side.width, 1.5);
      expect(iconColor(tester, AppIcons.minus), AppColors.grey900);
    });
  });

  group('behaviour', () {
    testWidgets('increments and decrements by step', (tester) async {
      await pumpStepper(tester, const _Host(step: 2));
      await tester.tap(find.byKey(AppStepper.incrementKey));
      await tester.pump();
      expect(find.text('7'), findsOneWidget);
      await tester.pump();
      await tester.tap(find.byKey(AppStepper.decrementKey));
      await tester.pump();
      await tester.tap(find.byKey(AppStepper.decrementKey));
      await tester.pump();
      expect(find.text('3'), findsOneWidget);
    });

    testWidgets('clamps to max when a step overshoots', (tester) async {
      final values = <int>[];
      await pumpStepper(
        tester,
        AppStepper(value: 9, max: 10, step: 5, onChanged: values.add),
      );
      await tester.tap(find.byKey(AppStepper.incrementKey));
      expect(values, [10]);
    });

    testWidgets('at min the minus is disabled and ignores taps', (
      tester,
    ) async {
      final values = <int>[];
      await pumpStepper(tester, AppStepper(value: 0, onChanged: values.add));
      expect(iconColor(tester, AppIcons.minus), AppColors.grey300);
      expect(iconColor(tester, AppIcons.plus), AppColors.sage500);
      await tester.tap(find.byKey(AppStepper.decrementKey));
      expect(values, isEmpty);
      await tester.tap(find.byKey(AppStepper.incrementKey));
      expect(values, [1]);
    });

    testWidgets('at max the plus is disabled and ignores taps', (tester) async {
      final values = <int>[];
      await pumpStepper(
        tester,
        AppStepper(value: 10, max: 10, onChanged: values.add),
      );
      expect(iconColor(tester, AppIcons.plus), AppColors.grey300);
      await tester.tap(find.byKey(AppStepper.incrementKey));
      expect(values, isEmpty);
      await tester.tap(find.byKey(AppStepper.decrementKey));
      expect(values, [9]);
    });

    testWidgets('null onChanged disables both buttons', (tester) async {
      await pumpStepper(tester, const AppStepper(value: 5, onChanged: null));
      expect(iconColor(tester, AppIcons.minus), AppColors.grey300);
      expect(iconColor(tester, AppIcons.plus), AppColors.grey300);
      await tester.tap(find.byKey(AppStepper.incrementKey));
      await tester.tap(find.byKey(AppStepper.decrementKey));
      expect(find.text('5'), findsOneWidget);
    });

    testWidgets('buttons have semantic labels', (tester) async {
      final handle = tester.ensureSemantics();
      await pumpStepper(tester, AppStepper(value: 5, onChanged: (_) {}));
      expect(find.bySemanticsLabel('Increase'), findsOneWidget);
      expect(find.bySemanticsLabel('Decrease'), findsOneWidget);
      handle.dispose();
    });
  });
}
