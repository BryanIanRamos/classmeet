import 'package:classmeet/core/theme/app_colors.dart';
import 'package:classmeet/core/theme/app_shadows.dart';
import 'package:classmeet/core/theme/app_theme.dart';
import 'package:classmeet/core/widgets/display/app_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> pump(WidgetTester tester, Widget child, {double width = 350}) {
  return tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.light,
      home: Scaffold(
        body: Align(
          alignment: Alignment.topLeft,
          child: SizedBox(width: width, child: child),
        ),
      ),
    ),
  );
}

BoxDecoration decoration(WidgetTester tester) =>
    tester
            .widget<DecoratedBox>(
              find
                  .descendant(
                    of: find.byType(AppCard),
                    matching: find.byType(DecoratedBox),
                  )
                  .first,
            )
            .decoration
        as BoxDecoration;

void main() {
  testWidgets('screen card: Grey-50 fill, Grey-300 border, r16, padding 16', (
    tester,
  ) async {
    await pump(tester, const AppCard(child: SizedBox(height: 20)));
    final d = decoration(tester);
    expect(d.color, AppColors.grey50);
    expect(d.borderRadius, BorderRadius.circular(16));
    expect((d.border! as Border).top.color, AppColors.grey300);
    // 1 border + 16 padding on each side, around the 20 child.
    expect(tester.getSize(find.byType(AppCard)), const Size(350, 54));
  });

  testWidgets('without a border the padding alone insets the child', (
    tester,
  ) async {
    await pump(
      tester,
      const AppCard(borderColor: null, child: SizedBox(height: 20)),
    );
    expect(tester.getSize(find.byType(AppCard)), const Size(350, 52));
  });

  testWidgets('onTap fires and presses flat; null onTap does not react', (
    tester,
  ) async {
    var taps = 0;
    await pump(
      tester,
      AppCard(onTap: () => taps++, child: const SizedBox(height: 20)),
    );
    await tester.tap(find.byType(AppCard));
    expect(taps, 1);
    final gesture = await tester.startGesture(
      tester.getCenter(find.byType(AppCard)),
    );
    await tester.pump();
    expect(decoration(tester).color, AppColors.grey100);
    await gesture.up();
    await tester.pump();
    expect(decoration(tester).color, AppColors.grey50);

    await pump(tester, const AppCard(child: SizedBox(height: 20)));
    final g2 = await tester.startGesture(
      tester.getCenter(find.byType(AppCard)),
    );
    await tester.pump();
    expect(decoration(tester).color, AppColors.grey50);
    await g2.up();
  });

  testWidgets('vertical: image area, 24 padding and gap, white with shadow', (
    tester,
  ) async {
    await pump(
      tester,
      AppCard.vertical(
        image: const ColoredBox(key: Key('img'), color: AppColors.sage50),
        title: 'Title',
        description: 'Short description',
        children: const [
          SizedBox(key: Key('btn'), height: 48),
          SizedBox(key: Key('btn2'), height: 48),
        ],
      ),
    );
    final d = decoration(tester);
    expect(d.color, AppColors.white);
    expect(d.boxShadow, AppShadows.s500);
    expect(tester.getSize(find.byKey(const Key('img'))), const Size(350, 200));
    expect(tester.getTopLeft(find.text('Title')).dx, 24);
    expect(tester.getTopLeft(find.text('Title')).dy, 200 + 24);
    // Buttons are 302 wide (350 - 2 * 24) with a 16 gap.
    expect(tester.getSize(find.byKey(const Key('btn'))).width, 302);
    final gap =
        tester.getTopLeft(find.byKey(const Key('btn2'))).dy -
        tester.getBottomLeft(find.byKey(const Key('btn'))).dy;
    expect(gap, 16);
  });

  testWidgets('horizontal small: 350x120 with a 120 image', (tester) async {
    await pump(
      tester,
      AppCard.horizontalSmall(
        image: const ColoredBox(key: Key('img'), color: AppColors.sage50),
        title: 'Title',
        description:
            'Keep your messages short, but make sure they cover '
            'everything you need to say.',
      ),
    );
    expect(tester.getSize(find.byType(AppCard)), const Size(350, 120));
    expect(tester.getSize(find.byKey(const Key('img'))), const Size(120, 120));
    expect(tester.getTopLeft(find.text('Title')).dx, 120 + 16);
    expect(tester.takeException(), isNull);
  });

  testWidgets('long text does not overflow at 360dp', (tester) async {
    final long = 'word ' * 60;
    await pump(
      tester,
      AppCard.horizontalSmall(
        image: const SizedBox(),
        title: long,
        description: long,
      ),
      width: 328,
    );
    expect(tester.takeException(), isNull);
  });
}
