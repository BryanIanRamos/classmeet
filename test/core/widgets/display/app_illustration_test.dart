import 'package:classmeet/core/assets/app_images.dart';
import 'package:classmeet/core/theme/app_colors.dart';
import 'package:classmeet/core/theme/app_theme.dart';
import 'package:classmeet/core/widgets/display/app_illustration.dart';
import 'package:classmeet/core/widgets/display/illustrated_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> pump(
  WidgetTester tester,
  Widget child, {
  double width = 428,
}) async {
  await tester.binding.setSurfaceSize(Size(width, 900));
  addTearDown(() => tester.binding.setSurfaceSize(null));
  await tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.light,
      home: Scaffold(
        body: Padding(padding: const EdgeInsets.all(16), child: child),
      ),
    ),
  );
}

void main() {
  const owl = AppImages.createReadyOwl; // 199 × 164 logical

  group('AppIllustration', () {
    testWidgets('shows the image at its logical size by default', (
      tester,
    ) async {
      await pump(tester, const Center(child: AppIllustration(owl)));
      final image = tester.widget<Image>(find.byType(Image));
      expect(image.width, owl.width);
      expect(image.height, owl.height);
      expect(image.excludeFromSemantics, isTrue);
    });

    testWidgets('one side follows the other at the aspect ratio', (
      tester,
    ) async {
      await pump(tester, const Center(child: AppIllustration(owl, width: 100)));
      final image = tester.widget<Image>(find.byType(Image));
      expect(image.width, 100);
      expect(image.height, closeTo(100 * owl.height / owl.width, 1e-9));
    });

    test('decodes only the pixels it draws', () {
      const contain = AppIllustration(owl);
      // 100 dp at DPR 2 → 200 px.
      expect(contain.decodeWidth(100, 80, 2), 200);
      // Never more than the file has (3 × logical width).
      expect(contain.decodeWidth(1000, 800, 3), (owl.width * 3).round());

      const cover = AppIllustration(owl, fit: BoxFit.cover);
      // A tall box under cover draws wider than the box.
      final drawn = 300 * owl.width / owl.height;
      expect(cover.decodeWidth(100, 300, 1), drawn.round());
    });

    testWidgets('a missing file shows the tinted placeholder', (tester) async {
      await pump(
        tester,
        const Center(
          child: AppIllustration(
            AppImage('assets/images/missing.png', width: 40, height: 30),
          ),
        ),
      );
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 200)),
      );
      await tester.pump();
      final box = tester.widget<ColoredBox>(
        find.descendant(
          of: find.byType(AppIllustration),
          matching: find.byType(ColoredBox),
        ),
      );
      expect(box.color, AppColors.sage50);
    });
  });

  group('IllustratedCard', () {
    for (final width in const [360.0, 428.0]) {
      testWidgets('fills the width at ${width.round()} dp', (tester) async {
        await pump(
          tester,
          const IllustratedCard(minHeight: 189, child: Text('You got this!')),
          width: width,
        );
        final size = tester.getSize(find.byType(IllustratedCard));
        expect(size.width, width - 32);
        expect(size.height, 189);
        expect(find.text('You got this!'), findsOneWidget);
      });
    }

    testWidgets('without art the card colour is the placeholder', (
      tester,
    ) async {
      await pump(
        tester,
        const IllustratedCard(
          color: AppColors.ember500,
          borderColor: AppColors.ember700,
          child: Text('6'),
        ),
      );
      expect(find.byType(AppIllustration), findsNothing);
      final decoration =
          tester
                  .widget<DecoratedBox>(
                    find
                        .descendant(
                          of: find.byType(IllustratedCard),
                          matching: find.byType(DecoratedBox),
                        )
                        .first,
                  )
                  .decoration
              as BoxDecoration;
      expect(decoration.color, AppColors.ember500);
      expect((decoration.border! as Border).top.color, AppColors.ember700);
    });

    testWidgets('art covers the card, anchored right, behind the text', (
      tester,
    ) async {
      await pump(
        tester,
        const IllustratedCard(art: owl, minHeight: 120, child: Text('Hi')),
      );
      final art = tester.widget<AppIllustration>(find.byType(AppIllustration));
      expect(art.fit, BoxFit.cover);
      expect(art.alignment, Alignment.centerRight);
      expect(art.placeholderColor, AppColors.sage300);
      expect(tester.getSize(find.byType(AppIllustration)).height, 120);
    });

    testWidgets('taps fire onTap; long copy does not overflow at 360', (
      tester,
    ) async {
      var taps = 0;
      await pump(
        tester,
        IllustratedCard(
          onTap: () => taps++,
          child: const Text(
            'A very long title that has to wrap onto several lines on a '
            'small phone without overflowing the card at all',
          ),
        ),
        width: 360,
      );
      await tester.tap(find.byType(IllustratedCard));
      expect(taps, 1);
      expect(tester.takeException(), isNull);
    });
  });
}
