import 'package:classmeet/core/assets/app_icons.dart';
import 'package:classmeet/core/theme/app_colors.dart';
import 'package:classmeet/core/theme/app_semantic_colors.dart';
import 'package:classmeet/core/theme/app_theme.dart';
import 'package:classmeet/core/widgets/display/app_badge.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> pumpBadge(WidgetTester tester, Widget badge) async {
  await tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.light,
      home: Scaffold(body: Center(child: badge)),
    ),
  );
}

BoxDecoration decorationOf(WidgetTester tester) =>
    tester.widget<Container>(find.byType(Container)).decoration!
        as BoxDecoration;

void main() {
  const colors = AppSemanticColors.light;

  test('measurements match the DS component', () {
    expect(
      {
        for (final s in AppBadgeSize.values)
          s.name: (s.height, s.padding, s.iconSize, s.radius),
      },
      {
        'medium': (40, 12, 24, 12),
        'small': (32, 12, 24, 8),
        'tiny': (24, 8, 16, 8),
      },
    );
  });

  for (final size in AppBadgeSize.values) {
    testWidgets('${size.name}: height, padding and icons', (tester) async {
      await pumpBadge(
        tester,
        AppBadge(
          label: 'Badge',
          size: size,
          leadingIcon: AppIcons.star,
          trailingIcon: AppIcons.x,
        ),
      );
      final text = tester.getSize(find.text('Badge'));
      final badge = tester.getSize(find.byType(Container));
      expect(badge.height, size.height);
      expect(
        badge.width,
        2 * size.padding +
            2 * size.iconSize +
            2 * size.labelPadding +
            text.width,
      );
      expect(
        tester.getSize(find.byIcon(AppIcons.star)),
        Size.square(size.iconSize),
      );
    });

    testWidgets('${size.name}: icon-only is square', (tester) async {
      await pumpBadge(
        tester,
        AppBadge.icon(icon: AppIcons.star, semanticLabel: 'Star', size: size),
      );
      expect(tester.getSize(find.byType(Container)), Size.square(size.height));
      expect(find.bySemanticsLabel('Star'), findsOneWidget);
    });
  }

  testWidgets('screens: "24 talons" is talon100 with talon900 text', (
    tester,
  ) async {
    await pumpBadge(
      tester,
      const AppBadge(label: '24 talons', tone: AppBadgeTone.warning),
    );
    expect(tester.getSize(find.byType(Container)).height, 24);
    expect(decorationOf(tester).color, AppColors.talon100);
    expect(
      tester.widget<Text>(find.text('24 talons')).style,
      isNull,
      reason: 'style comes from DefaultTextStyle',
    );
    final style = DefaultTextStyle.of(tester.element(find.text('24 talons')));
    expect(style.style.color, AppColors.talon900);
    expect(style.style.fontSize, 10);
  });

  group('colours per tone and style', () {
    const strong = {
      AppBadgeTone.neutral: AppColors.grey500,
      AppBadgeTone.accent: AppColors.sage500,
      AppBadgeTone.success: AppColors.sprout500,
      AppBadgeTone.info: AppColors.sky500,
      AppBadgeTone.warning: AppColors.talon500,
      AppBadgeTone.error: AppColors.ember500,
    };
    const tint50 = {
      AppBadgeTone.neutral: AppColors.grey50,
      AppBadgeTone.accent: AppColors.sage50,
      AppBadgeTone.success: AppColors.sprout50,
      AppBadgeTone.info: AppColors.sky50,
      AppBadgeTone.warning: AppColors.talon50,
      AppBadgeTone.error: AppColors.ember50,
    };
    const tint100 = {
      AppBadgeTone.neutral: AppColors.grey200,
      AppBadgeTone.accent: AppColors.sage100,
      AppBadgeTone.success: AppColors.sprout100,
      AppBadgeTone.info: AppColors.sky100,
      AppBadgeTone.warning: AppColors.talon100,
      AppBadgeTone.error: AppColors.ember100,
    };

    for (final tone in AppBadgeTone.values) {
      test(tone.name, () {
        AppBadge b(AppBadgeStyle s) =>
            AppBadge(label: 'x', tone: tone, style: s);
        expect(b(AppBadgeStyle.filled).background, strong[tone]);
        expect(b(AppBadgeStyle.filled).foreground(colors), Colors.white);
        expect(b(AppBadgeStyle.outline).background, tint50[tone]);
        expect(b(AppBadgeStyle.outline).foreground(colors), strong[tone]);
        expect(b(AppBadgeStyle.soft).background, tint100[tone]);
        expect(b(AppBadgeStyle.clear).background, Colors.transparent);
        expect(b(AppBadgeStyle.clear).foreground(colors), strong[tone]);
      });
    }

    testWidgets('outline draws a 1.5 border in the tone colour', (
      tester,
    ) async {
      await pumpBadge(
        tester,
        const AppBadge(
          label: 'x',
          tone: AppBadgeTone.error,
          style: AppBadgeStyle.outline,
        ),
      );
      expect(
        decorationOf(tester).border,
        Border.all(
          color: AppColors.ember500,
          width: AppBadge.outlineBorderWidth,
        ),
      );
    });
  });

  testWidgets('a long label ellipsizes at 360', (tester) async {
    await tester.binding.setSurfaceSize(const Size(360, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await pumpBadge(
      tester,
      const SizedBox(
        width: 120,
        child: AppBadge(
          label: 'A very long badge label that cannot fit at all',
          size: AppBadgeSize.medium,
          leadingIcon: AppIcons.star,
          trailingIcon: AppIcons.x,
        ),
      ),
    );
    expect(tester.takeException(), isNull);
  });
}
