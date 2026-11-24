import 'package:classmeet/core/theme/app_colors.dart';
import 'package:classmeet/core/theme/app_theme.dart';
import 'package:classmeet/core/widgets/buttons/app_button.dart';
import 'package:classmeet/core/widgets/feedback/app_progress_bar.dart';
import 'package:classmeet/core/widgets/layout/app_sheet.dart';
import 'package:classmeet/core/widgets/layout/screen_background.dart';
import 'package:classmeet/core/widgets/layout/step_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> pump(
  WidgetTester tester,
  Widget home, {
  Size size = const Size(428, 870),
}) async {
  await tester.binding.setSurfaceSize(size);
  addTearDown(() => tester.binding.setSurfaceSize(null));
  await tester.pumpWidget(MaterialApp(theme: AppTheme.light, home: home));
}

void main() {
  const patternKey = ValueKey('screen-background-pattern');

  group('ScreenBackground', () {
    testWidgets('draws the pattern at 5% over white', (tester) async {
      await pump(tester, const Scaffold(body: ScreenBackground()));
      final opacity = tester.widget<Opacity>(
        find.ancestor(
          of: find.byKey(patternKey),
          matching: find.byType(Opacity),
        ),
      );
      expect(opacity.opacity, 0.05);
      expect(ScreenBackground.patternOpacity, 0.05);
      final image = tester.widget<Image>(find.byKey(patternKey));
      expect(image.fit, BoxFit.cover);
      final box = tester.widget<ColoredBox>(
        find
            .descendant(
              of: find.byType(ScreenBackground),
              matching: find.byType(ColoredBox),
            )
            .first,
      );
      expect(box.color, AppColors.white);
    });

    testWidgets('pattern can be disabled', (tester) async {
      await pump(
        tester,
        const Scaffold(
          body: ScreenBackground(showPattern: false, child: Text('hi')),
        ),
      );
      expect(find.byKey(patternKey), findsNothing);
      expect(find.text('hi'), findsOneWidget);
    });
  });

  group('AppSheet', () {
    testWidgets('geometry: radius, grabber, side inset', (tester) async {
      await pump(
        tester,
        const Scaffold(
          body: Align(
            alignment: Alignment.bottomCenter,
            child: AppSheet(child: SizedBox(height: 40, child: Text('body'))),
          ),
        ),
      );
      final deco =
          tester
                  .widget<DecoratedBox>(
                    find
                        .descendant(
                          of: find.byType(AppSheet),
                          matching: find.byType(DecoratedBox),
                        )
                        .first,
                  )
                  .decoration
              as BoxDecoration;
      expect(
        deco.borderRadius,
        const BorderRadius.vertical(top: Radius.circular(24)),
      );
      expect(deco.color, AppColors.white);
      final grabber = find.byKey(const ValueKey('sheet-grabber'));
      expect(tester.getSize(grabber), const Size(74, 3));
      final grabberDeco =
          tester
                  .widget<DecoratedBox>(
                    find.descendant(
                      of: grabber,
                      matching: find.byType(DecoratedBox),
                    ),
                  )
                  .decoration
              as BoxDecoration;
      expect(grabberDeco.color, AppColors.sage300);
      expect(tester.getTopLeft(find.text('body')).dx, 28);
      expect(tester.getSize(find.byType(AppSheet)).width, 428);
    });

    testWidgets('title and close button', (tester) async {
      var closed = 0;
      await pump(
        tester,
        Scaffold(
          body: AppSheet(
            title: 'Explain simply',
            onClose: () => closed++,
            child: const Text('x'),
          ),
        ),
      );
      expect(find.text('Explain simply'), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('sheet-close')));
      expect(closed, 1);
    });

    testWidgets('long content scrolls and the footer stays', (tester) async {
      await pump(
        tester,
        Scaffold(
          body: Align(
            alignment: Alignment.bottomCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 400),
              child: AppSheet(
                footer: AppButton(label: 'Done', onPressed: () {}),
                child: Column(
                  children: [
                    for (var i = 0; i < 40; i++)
                      SizedBox(height: 40, child: Text('row $i')),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
      expect(tester.takeException(), isNull);
      final footerBefore = tester.getTopLeft(find.text('Done'));
      await tester.drag(find.text('row 0'), const Offset(0, -300));
      await tester.pump();
      expect(tester.getTopLeft(find.text('Done')), footerBefore);
      expect(tester.getSize(find.byType(AppSheet)).height, 400);
    });

    testWidgets('showAppSheet returns a value; scrim, back and drag close', (
      tester,
    ) async {
      Future<String?>? result;
      await pump(
        tester,
        Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: TextButton(
                onPressed: () => result = showAppSheet<String>(
                  context,
                  builder: (context) => AppSheet(
                    footer: AppButton(
                      label: 'Pick',
                      onPressed: () => Navigator.pop(context, 'picked'),
                    ),
                    child: const Text('sheet body'),
                  ),
                ),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      expect(find.text('sheet body'), findsOneWidget);

      await tester.tap(find.text('Pick'));
      await tester.pumpAndSettle();
      expect(await result, 'picked');
      expect(find.text('sheet body'), findsNothing);

      // Scrim tap dismisses with null.
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      await tester.tapAt(const Offset(200, 20));
      await tester.pumpAndSettle();
      expect(find.text('sheet body'), findsNothing);
      expect(await result, isNull);

      // Back key dismisses.
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(find.text('sheet body'), findsNothing);

      // Drag down dismisses.
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      await tester.fling(find.text('sheet body'), const Offset(0, 500), 2000);
      await tester.pumpAndSettle();
      expect(find.text('sheet body'), findsNothing);
    });

    testWidgets('scrim is black 30%', (tester) async {
      await pump(
        tester,
        Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () => showAppSheet<void>(
                context,
                builder: (_) => const AppSheet(child: Text('b')),
              ),
              child: const Text('open'),
            ),
          ),
        ),
      );
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      final barrier = tester.widget<ModalBarrier>(
        find.byType(ModalBarrier).last,
      );
      expect(barrier.color, AppColors.black30);
    });
  });

  group('StepScaffold', () {
    Widget scaffold({
      VoidCallback? onPrimary,
      VoidCallback? onBack,
      Widget? secondary,
      StepCtaLayout ctaLayout = StepCtaLayout.sticky,
      int items = 20,
    }) => StepScaffold(
      ctaLayout: ctaLayout,
      title: 'Your learning preferences',
      step: 3,
      totalSteps: 4,
      heading: 'How do you like to study?',
      subheading: 'Choose the methods you enjoy.',
      primaryLabel: 'Continue',
      onPrimary: onPrimary,
      onBack: onBack,
      secondary: secondary,
      child: Column(
        children: [
          for (var i = 0; i < items; i++)
            SizedBox(height: 64, child: Text('item $i')),
        ],
      ),
    );

    testWidgets('shows step text, progress, heading and subheading', (
      tester,
    ) async {
      await pump(tester, scaffold(onPrimary: () {}));
      expect(find.text('Step 3 of 4'), findsOneWidget);
      expect(find.text('Your learning preferences'), findsOneWidget);
      expect(find.text('How do you like to study?'), findsOneWidget);
      expect(find.text('Choose the methods you enjoy.'), findsOneWidget);
      final bar = tester.widget<AppProgressBar>(find.byType(AppProgressBar));
      expect(bar.value, 0.75);
      expect(bar.segments, 4);
      expect(bar.filledSegments, 3);
      expect(tester.getTopLeft(find.text('Step 3 of 4')).dx, 24);
    });

    testWidgets('CTA is disabled without onPrimary', (tester) async {
      await pump(tester, scaffold());
      final button = tester.widget<AppButton>(
        find.byKey(const ValueKey('step-primary')),
      );
      expect(button.onPressed, isNull);
      expect(button.size, AppButtonSize.giant);
      expect(button.expand, isTrue);
    });

    testWidgets('CTA and back fire', (tester) async {
      var primary = 0;
      var back = 0;
      await pump(
        tester,
        scaffold(onPrimary: () => primary++, onBack: () => back++),
      );
      await tester.tap(find.text('Continue'));
      expect(primary, 1);
      await tester.tap(find.bySemanticsLabel('Back'));
      expect(back, 1);
    });

    testWidgets('secondary widget is shown under the CTA', (tester) async {
      await pump(
        tester,
        scaffold(
          onPrimary: () {},
          secondary: AppButton(
            label: 'Edit setup',
            onPressed: () {},
            style: AppButtonStyle.outline,
            expand: true,
          ),
        ),
      );
      expect(
        tester.getTopLeft(find.text('Edit setup')).dy,
        greaterThan(tester.getTopLeft(find.text('Continue')).dy),
      );
      expect(tester.takeException(), isNull);
    });

    for (final size in const [Size(360, 800), Size(428, 870)]) {
      testWidgets('scrolls behind the CTA without overflow at $size', (
        tester,
      ) async {
        await pump(tester, scaffold(onPrimary: () {}), size: size);
        expect(tester.takeException(), isNull);
        final cta = tester.getRect(find.byKey(const ValueKey('step-primary')));
        expect(cta.width, size.width - 24);
        expect(cta.height, 56);
        expect(cta.bottom, lessThanOrEqualTo(size.height));
        await tester.drag(find.text('item 0'), const Offset(0, -3000));
        await tester.pump();
        expect(tester.takeException(), isNull);
        // The last item can scroll fully above the CTA area.
        final last = tester.getRect(find.text('item 19'));
        expect(last.bottom, lessThanOrEqualTo(cta.top));
        // The CTA stays put.
        expect(tester.getRect(find.byKey(const ValueKey('step-primary'))), cta);
      });
    }
    group('inline CTA (96, 97, 99)', () {
      testWidgets('inset 24, 80 above the bottom edge, no white band', (
        tester,
      ) async {
        await pump(
          tester,
          MediaQuery(
            data: const MediaQueryData(
              size: Size(428, 870),
              padding: EdgeInsets.only(bottom: 24),
            ),
            child: scaffold(
              onPrimary: () {},
              ctaLayout: StepCtaLayout.inline,
              items: 3,
            ),
          ),
        );
        final cta = tester.getRect(find.byKey(const ValueKey('step-primary')));
        expect(cta.left, 24);
        expect(cta.width, 428 - 48);
        expect(870 - cta.bottom, 80);
        expect(tester.takeException(), isNull);
      });

      for (final size in const [Size(360, 800), Size(428, 870)]) {
        testWidgets('long content scrolls above the CTA at $size', (
          tester,
        ) async {
          await pump(
            tester,
            scaffold(onPrimary: () {}, ctaLayout: StepCtaLayout.inline),
            size: size,
          );
          final cta = tester.getRect(
            find.byKey(const ValueKey('step-primary')),
          );
          await tester.drag(find.text('item 0'), const Offset(0, -3000));
          await tester.pump();
          expect(tester.takeException(), isNull);
          final last = tester.getRect(find.text('item 19'));
          expect(last.bottom, lessThanOrEqualTo(cta.top));
          expect(
            tester.getRect(find.byKey(const ValueKey('step-primary'))),
            cta,
          );
        });
      }
    });
  });
}
