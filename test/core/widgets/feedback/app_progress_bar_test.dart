import 'package:classmeet/core/theme/app_colors.dart';
import 'package:classmeet/core/theme/app_semantic_colors.dart';
import 'package:classmeet/core/theme/app_theme.dart';
import 'package:classmeet/core/theme/app_typography.dart';
import 'package:classmeet/core/widgets/feedback/app_progress_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> pumpBar(
  WidgetTester tester,
  AppProgressBar bar, {
  double width = 368,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.light,
      home: Scaffold(
        body: Align(
          alignment: Alignment.topLeft,
          child: SizedBox(width: width, child: bar),
        ),
      ),
    ),
  );
}

Finder get track => find
    .descendant(of: find.byType(ClipRRect), matching: find.byType(ColoredBox))
    .first;

Color colorOf(WidgetTester tester, Finder f) =>
    tester.widget<ColoredBox>(f).color;

/// Fill of a separate segment pill.
Color segmentColor(WidgetTester tester, Finder f) =>
    (tester.widget<DecoratedBox>(f).decoration as BoxDecoration).color!;

void main() {
  const colors = AppSemanticColors.light;

  group('linear geometry (DS 5248:1858, Home 8)', () {
    testWidgets('8 tall, radius 8, fills the width without a label', (
      tester,
    ) async {
      await pumpBar(tester, const AppProgressBar(value: 0.5));
      expect(tester.getSize(find.byType(ClipRRect)), const Size(368, 8));
      final clip = tester.widget<ClipRRect>(find.byType(ClipRRect));
      expect(clip.borderRadius, BorderRadius.circular(8));
      expect(colorOf(tester, track), AppColors.grey200);
    });

    for (final (value, expected) in [(0.0, 0.0), (0.4, 0.4), (1.0, 1.0)]) {
      testWidgets('fill width at $value', (tester) async {
        await pumpBar(tester, AppProgressBar(value: value));
        final fill = find.byKey(const ValueKey('progress-fill'));
        expect(tester.getSize(fill).width, closeTo(368 * expected, 0.01));
        if (expected > 0) {
          final deco =
              tester.widget<DecoratedBox>(fill).decoration as BoxDecoration;
          expect(deco.color, AppColors.sage500);
        }
      });
    }

    testWidgets('value is clamped to 0..1', (tester) async {
      await pumpBar(tester, const AppProgressBar(value: 1.7));
      expect(
        tester.getSize(find.byKey(const ValueKey('progress-fill'))).width,
        368,
      );
      await pumpBar(tester, const AppProgressBar(value: -3));
      expect(
        tester.getSize(find.byKey(const ValueKey('progress-fill'))).width,
        0,
      );
    });
  });

  group('segmented', () {
    testWidgets('67% in 5 segments fills 4 as one square fill (Home)', (
      tester,
    ) async {
      await pumpBar(
        tester,
        const AppProgressBar(value: 0.67, segments: 5, label: '67%'),
      );
      final fill = find.byKey(const ValueKey('progress-fill'));
      expect(
        tester.getSize(fill).width,
        closeTo(0.8 * tester.getSize(find.byType(ClipRRect)).width, 0.01),
      );
      expect(colorOf(tester, fill), AppColors.sage500);
      expect(colorOf(tester, track), AppColors.grey200);
    });

    testWidgets('with a gap: equal segments, 67% fills 4', (tester) async {
      await pumpBar(
        tester,
        const AppProgressBar(value: 0.67, segments: 5, segmentGap: 4),
      );
      final seg = [
        for (var i = 0; i < 5; i++) find.byKey(ValueKey('progress-segment-$i')),
      ];
      final rects = [for (final s in seg) tester.getRect(s)];
      for (var i = 1; i < 5; i++) {
        expect(rects[i].left - rects[i - 1].right, closeTo(4, 0.01));
        expect(rects[i].width, closeTo(rects[0].width, 0.01));
      }
      expect(segmentColor(tester, seg[3]), AppColors.sage500);
      expect(segmentColor(tester, seg[4]), AppColors.grey200);
    });

    testWidgets('separate pills: height, round ends, nothing in the gaps', (
      tester,
    ) async {
      // The question counter of 15: 5 pills, 6 tall, gap 6, Grey-300 track.
      await pumpBar(
        tester,
        const AppProgressBar(
          value: 0.4,
          segments: 5,
          segmentGap: 6,
          height: 6,
          trackColor: AppColors.grey300,
        ),
      );
      final first = find.byKey(const ValueKey('progress-segment-0'));
      expect(tester.getSize(first).height, 6);
      final d = tester.widget<DecoratedBox>(first).decoration as BoxDecoration;
      expect(d.borderRadius, const BorderRadius.all(Radius.circular(3)));
      expect(
        segmentColor(tester, find.byKey(const ValueKey('progress-segment-2'))),
        AppColors.grey300,
      );
      // No track or clip behind the pills.
      Finder inBar(Type t) => find.descendant(
        of: find.byType(AppProgressBar),
        matching: find.byType(t),
      );
      expect(inBar(ClipRRect), findsNothing);
      expect(inBar(ColoredBox), findsNothing);
    });

    testWidgets('40% fills 2 of 5, 0 fills none, 100 fills all', (
      tester,
    ) async {
      const bar = AppProgressBar(value: 0.4, segments: 5);
      expect(bar.filledSegments, 2);
      expect(const AppProgressBar(value: 0, segments: 5).filledSegments, 0);
      expect(const AppProgressBar(value: 1, segments: 5).filledSegments, 5);
      expect(const AppProgressBar(value: 0.2, segments: 5).filledSegments, 1);
      expect(const AppProgressBar(value: 9, segments: 5).filledSegments, 5);
    });

    testWidgets('segmentGap spaces the segments', (tester) async {
      await pumpBar(
        tester,
        const AppProgressBar(value: 1, segments: 4, segmentGap: 4),
      );
      final a = tester.getRect(
        find.byKey(const ValueKey('progress-segment-0')),
      );
      final b = tester.getRect(
        find.byKey(const ValueKey('progress-segment-1')),
      );
      expect(b.left - a.right, 4);
    });
  });

  group('label', () {
    testWidgets('right: 4 gap, C3 Medium, primary text', (tester) async {
      await pumpBar(tester, const AppProgressBar(value: 0.4, label: '40%'));
      final text = tester.getRect(find.text('40%'));
      final bar = tester.getRect(find.byType(ClipRRect));
      expect(text.left - bar.right, 4);
      expect(text.right, 368);
      final style = tester.widget<Text>(find.text('40%')).style!;
      expect(style.fontSize, AppTypography.c3Medium.fontSize);
      expect(style.fontWeight, AppTypography.c3Medium.fontWeight);
      expect(style.color, colors.textPrimary);
      expect(tester.getCenter(find.text('40%')).dy, 7);
      expect(tester.getCenter(find.byType(ClipRRect)).dy, 7);
    });

    testWidgets('left: label first with a 4 gap', (tester) async {
      await pumpBar(
        tester,
        const AppProgressBar(
          value: 0.4,
          label: '40%',
          labelPosition: AppProgressBarLabelPosition.left,
        ),
      );
      final text = tester.getRect(find.text('40%'));
      final bar = tester.getRect(find.byType(ClipRRect));
      expect(text.left, 0);
      expect(bar.left - text.right, 4);
      expect(bar.right, 368);
    });
  });

  group('colours', () {
    testWidgets('overrides for fill, track and label', (tester) async {
      await pumpBar(
        tester,
        const AppProgressBar(
          value: 0.5,
          label: '171/300',
          color: AppColors.talon500,
          trackColor: AppColors.talon100,
          labelColor: AppColors.talon900,
        ),
      );
      expect(colorOf(tester, track), AppColors.talon100);
      final deco =
          tester
                  .widget<DecoratedBox>(
                    find.byKey(const ValueKey('progress-fill')),
                  )
                  .decoration
              as BoxDecoration;
      expect(deco.color, AppColors.talon500);
      expect(
        tester.widget<Text>(find.text('171/300')).style!.color,
        AppColors.talon900,
      );
    });

    testWidgets('disabled uses grey-100 track and grey label', (tester) async {
      await pumpBar(
        tester,
        const AppProgressBar(value: 0, label: '0%', enabled: false),
      );
      expect(colorOf(tester, track), AppColors.grey100);
      expect(
        tester.widget<Text>(find.text('0%')).style!.color,
        colors.textGrey,
      );
    });
  });

  testWidgets('no overflow at 360 with a long label', (tester) async {
    await pumpBar(
      tester,
      const AppProgressBar(value: 0.57, segments: 5, label: '171/300'),
      width: 160,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('exposes the percentage as semantics value', (tester) async {
    final handle = tester.ensureSemantics();
    await pumpBar(tester, const AppProgressBar(value: 0.67, label: '67%'));
    expect(find.bySemanticsLabel('67%'), findsWidgets);
    handle.dispose();
  });
}
