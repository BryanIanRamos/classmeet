import 'dart:ui' show CheckedState;

import 'package:classmeet/core/assets/app_icons.dart';
import 'package:classmeet/core/theme/app_colors.dart';
import 'package:classmeet/core/theme/app_theme.dart';
import 'package:classmeet/core/theme/app_typography.dart';
import 'package:classmeet/core/widgets/selection/app_answer_option.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> pump(WidgetTester tester, Widget option, {double width = 370}) {
  return tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.light,
      home: Scaffold(
        body: Align(
          alignment: Alignment.topLeft,
          child: SizedBox(width: width, child: option),
        ),
      ),
    ),
  );
}

BoxDecoration card(WidgetTester tester) =>
    tester
            .widget<DecoratedBox>(
              find
                  .descendant(
                    of: find.byType(AppAnswerOption),
                    matching: find.byType(DecoratedBox),
                  )
                  .first,
            )
            .decoration
        as BoxDecoration;

BoxDecoration ring(WidgetTester tester) =>
    tester
            .widget<Container>(find.byKey(const ValueKey('answer-radio')))
            .decoration!
        as BoxDecoration;

void main() {
  testWidgets('one line is 50 tall: 1 border + 12 + 24 radio + 12 + 1', (
    tester,
  ) async {
    await pump(
      tester,
      const AppAnswerOption(
        label: 'Monitor',
        state: AppAnswerOptionState.idle,
        onTap: null,
      ),
    );
    expect(tester.getSize(find.byType(AppAnswerOption)), const Size(370, 50));
    final origin = tester.getTopLeft(find.byType(AppAnswerOption));
    final radio = tester.getRect(find.byKey(const ValueKey('answer-radio')));
    expect(radio.size, const Size(24, 24));
    expect(radio.topLeft - origin, const Offset(13, 13));
    expect(tester.getTopLeft(find.text('Monitor')).dx, radio.right + 16);
    final text = tester.widget<Text>(find.text('Monitor'));
    expect(text.style!.fontSize, AppTypography.b1.fontSize);
  });

  for (final (state, fill, border, labelColor, dot, trailing)
      in <(AppAnswerOptionState, Color, Color, Color, bool, IconData?)>[
        (
          AppAnswerOptionState.idle,
          AppColors.grey50,
          AppColors.sage500,
          AppColors.grey900,
          false,
          null,
        ),
        (
          AppAnswerOptionState.selected,
          AppColors.sage500,
          AppColors.sage500,
          AppColors.white,
          true,
          null,
        ),
        (
          AppAnswerOptionState.correct,
          AppColors.sprout50,
          AppColors.sprout500,
          AppColors.grey900,
          true,
          AppIcons.circleCheck,
        ),
        (
          AppAnswerOptionState.wrong,
          AppColors.talon50,
          AppColors.talon500,
          AppColors.grey900,
          true,
          AppIcons.circleX,
        ),
      ]) {
    testWidgets('${state.name}: fill, border, label, radio and trailing', (
      tester,
    ) async {
      await pump(
        tester,
        AppAnswerOption(label: 'Option', state: state, onTap: () {}),
      );
      final d = card(tester);
      expect(d.color, fill);
      expect((d.border! as Border).top.color, border);
      expect(d.borderRadius, BorderRadius.circular(16));
      expect(tester.widget<Text>(find.text('Option')).style!.color, labelColor);
      expect((ring(tester).border! as Border).top.color, state.ring);
      expect(
        find.byKey(const ValueKey('answer-radio-dot')),
        dot ? findsOneWidget : findsNothing,
      );
      if (trailing == null) {
        expect(find.byIcon(AppIcons.circleCheck), findsNothing);
        expect(find.byIcon(AppIcons.circleX), findsNothing);
      } else {
        final icon = tester.widget<Icon>(find.byIcon(trailing));
        expect(icon.size, 16);
        expect(icon.color, state.ring);
      }
      // Choosing an option never changes its height.
      expect(tester.getSize(find.byType(AppAnswerOption)).height, 50);
    });
  }

  testWidgets('taps reach onTap; a null onTap ignores them', (tester) async {
    var taps = 0;
    await pump(
      tester,
      AppAnswerOption(
        label: 'A',
        state: AppAnswerOptionState.idle,
        onTap: () => taps++,
      ),
    );
    await tester.tap(find.byType(AppAnswerOption));
    expect(taps, 1);

    await pump(
      tester,
      const AppAnswerOption(
        label: 'A',
        state: AppAnswerOptionState.correct,
        onTap: null,
      ),
    );
    await tester.tap(find.byType(AppAnswerOption));
    expect(taps, 1);
  });

  testWidgets('a long answer wraps with the radio on the first line', (
    tester,
  ) async {
    await pump(
      tester,
      const AppAnswerOption(
        label: 'An answer long enough to need a second line here',
        state: AppAnswerOptionState.idle,
        onTap: null,
      ),
      width: 240,
    );
    expect(tester.takeException(), isNull);
    final size = tester.getSize(find.byType(AppAnswerOption));
    expect(size.height, greaterThan(50));
    final radio = tester.getRect(find.byKey(const ValueKey('answer-radio')));
    expect(radio.top - tester.getTopLeft(find.byType(AppAnswerOption)).dy, 13);
  });

  testWidgets('semantics: a radio in a group, with the check result', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await pump(
      tester,
      AppAnswerOption(
        label: 'Monitor',
        state: AppAnswerOptionState.wrong,
        onTap: () {},
      ),
    );
    final data = tester
        .getSemantics(find.byType(AppAnswerOption))
        .getSemanticsData();
    expect(data.label, 'Monitor, your answer, incorrect');
    expect(data.flagsCollection.isInMutuallyExclusiveGroup, isTrue);
    expect(data.flagsCollection.isChecked, CheckedState.isTrue);
    handle.dispose();
  });
}
