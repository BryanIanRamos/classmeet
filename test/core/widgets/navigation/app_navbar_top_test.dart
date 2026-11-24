import 'package:classmeet/core/assets/app_icons.dart';
import 'package:classmeet/core/theme/app_colors.dart';
import 'package:classmeet/core/theme/app_semantic_colors.dart';
import 'package:classmeet/core/theme/app_theme.dart';
import 'package:classmeet/core/theme/app_typography.dart';
import 'package:classmeet/core/widgets/display/app_avatar.dart';
import 'package:classmeet/core/widgets/navigation/app_navbar_item.dart';
import 'package:classmeet/core/widgets/navigation/app_navbar_top.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> pumpBar(
  WidgetTester tester,
  Widget bar, {
  double width = 428,
}) async {
  await tester.binding.setSurfaceSize(Size(width, 800));
  addTearDown(() => tester.binding.setSurfaceSize(null));
  await tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.light,
      home: Scaffold(
        body: Align(alignment: Alignment.topCenter, child: bar),
      ),
    ),
  );
}

void main() {
  const colors = AppSemanticColors.light;

  group('geometry (screens 11, 14; DS 5248:1785)', () {
    testWidgets('title bar is 48 tall and full width', (tester) async {
      await pumpBar(tester, AppNavbarTop(title: 'Title', onBack: () {}));
      final size = tester.getSize(find.byType(AppNavbarTop));
      expect(size, const Size(428, AppNavbarTop.height));
      expect(AppNavbarTop.height, 48);
    });

    testWidgets('back chevron is 24 and 16 from the left edge', (tester) async {
      await pumpBar(tester, AppNavbarTop(title: 'Title', onBack: () {}));
      final icon = find.byIcon(AppIcons.chevronLeft);
      expect(tester.getSize(icon), const Size.square(24));
      expect(tester.getTopLeft(icon).dx, 16);
      expect(tester.getCenter(icon).dy, 24);
    });

    testWidgets('right icons are 16 from the edge with a 16 gap', (
      tester,
    ) async {
      await pumpBar(
        tester,
        AppNavbarTop(
          title: 'Title',
          trailing: [
            for (var i = 0; i < 2; i++)
              AppNavbarItem.icon(
                key: ValueKey('i$i'),
                icon: AppIcons.star,
                semanticLabel: 'Star $i',
                onTap: () {},
              ),
          ],
        ),
      );
      final first = tester.getRect(find.byIcon(AppIcons.star).first);
      final second = tester.getRect(find.byIcon(AppIcons.star).last);
      expect(428 - second.right, 16);
      expect(second.left - first.right, 16);
    });

    testWidgets('title is B2 centered; subtitle is Inter C1', (tester) async {
      await pumpBar(
        tester,
        AppNavbarTop(title: 'Title', subtitle: 'Secondary', onBack: () {}),
      );
      final title = tester.widget<Text>(find.text('Title'));
      expect(title.style!.fontSize, AppTypography.b2.fontSize);
      expect(title.style!.fontWeight, AppTypography.b2.fontWeight);
      expect(title.style!.color, colors.textPrimary);
      final sub = tester.widget<Text>(find.text('Secondary'));
      expect(sub.style!.fontFamily, AppTypography.interC1.fontFamily);
      expect(sub.style!.fontSize, AppTypography.interC1.fontSize);
      // The title block is centered in the bar even with only a back item.
      expect(tester.getCenter(find.text('Title')).dx, 214);
      // Title 24 + subtitle 16 stack is centered vertically in 48.
      final top = tester.getTopLeft(find.text('Title')).dy;
      final bottom = tester.getBottomLeft(find.text('Secondary')).dy;
      expect(top, 4);
      expect(bottom, 44);
    });

    testWidgets('text + icon item: 4 gap between chevron and label', (
      tester,
    ) async {
      await pumpBar(
        tester,
        AppNavbarTop(
          title: 'Title',
          leading: [
            AppNavbarItem.text(
              label: 'Label',
              icon: AppIcons.chevronLeft,
              onTap: () {},
            ),
          ],
        ),
      );
      final icon = tester.getRect(find.byIcon(AppIcons.chevronLeft));
      final label = tester.getRect(find.text('Label'));
      expect(label.left - icon.right, 4);
      expect(tester.getTopLeft(find.byIcon(AppIcons.chevronLeft)).dx, 16);
      final style = tester.widget<Text>(find.text('Label')).style!;
      expect(style.fontSize, AppTypography.b1.fontSize);
    });

    testWidgets('text-only left item starts 16 from the edge', (tester) async {
      await pumpBar(
        tester,
        AppNavbarTop(
          title: 'Title',
          leading: [AppNavbarItem.text(label: 'Label', onTap: () {})],
        ),
      );
      expect(tester.getTopLeft(find.text('Label')).dx, 16);
    });

    testWidgets('trailing text + chevron item', (tester) async {
      await pumpBar(
        tester,
        AppNavbarTop(
          title: 'Title',
          trailing: [
            AppNavbarItem.text(
              label: 'Label',
              trailingIcon: AppIcons.chevronRight,
              onTap: () {},
            ),
          ],
        ),
      );
      final icon = tester.getRect(find.byIcon(AppIcons.chevronRight));
      expect(428 - icon.right, 16);
      expect(tester.getRect(find.text('Label')).right, icon.left - 4);
    });

    testWidgets('home header: avatar 32, gap 10, 16 padding, start title', (
      tester,
    ) async {
      await pumpBar(
        tester,
        AppNavbarTop(
          showBottomBorder: true,
          avatar: const AppAvatar.letter(letter: 'B'),
          title: 'Good evening, Bryan!',
          subtitle: 'BSIT 2A · CSU',
          trailing: [
            AppNavbarItem.icon(
              icon: AppIcons.bell,
              semanticLabel: 'Notifications',
              onTap: () {},
            ),
          ],
        ),
      );
      final avatar = tester.getRect(find.byType(AppAvatar));
      expect(avatar.size, const Size.square(32));
      expect(avatar.left, 16);
      expect(tester.getTopLeft(find.text('Good evening, Bryan!')).dx, 58);
      expect(tester.getRect(find.byIcon(AppIcons.bell)).right, 428 - 16);
      final sub = tester.widget<Text>(find.text('BSIT 2A · CSU')).style!;
      expect(sub.color, colors.textPrimary);
    });

    testWidgets('bottom border is 1 grey-100 only when asked', (tester) async {
      await pumpBar(
        tester,
        const AppNavbarTop(title: 'Title', showBottomBorder: true),
      );
      var deco =
          tester
                  .widget<DecoratedBox>(find.byType(DecoratedBox).first)
                  .decoration
              as BoxDecoration;
      expect(deco.border!.bottom.color, AppColors.grey100);
      expect(deco.border!.bottom.width, 1);
      expect(deco.color, colors.surfaceWhite);

      await pumpBar(tester, const AppNavbarTop(title: 'Title'));
      deco =
          tester
                  .widget<DecoratedBox>(find.byType(DecoratedBox).first)
                  .decoration
              as BoxDecoration;
      expect(deco.border, isNull);
    });

    testWidgets('can be stacked as two rows', (tester) async {
      await pumpBar(
        tester,
        const Column(
          children: [
            AppNavbarTop(title: 'One'),
            AppNavbarTop(title: 'Two'),
          ],
        ),
      );
      expect(tester.getSize(find.byType(AppNavbarTop).last).height, 48);
      expect(tester.getTopLeft(find.byType(AppNavbarTop).last).dy, 48);
    });
  });

  group('interaction', () {
    testWidgets('back and icon taps fire; icons have semantic labels', (
      tester,
    ) async {
      var back = 0;
      var star = 0;
      await pumpBar(
        tester,
        AppNavbarTop(
          title: 'Title',
          onBack: () => back++,
          trailing: [
            AppNavbarItem.icon(
              icon: AppIcons.star,
              semanticLabel: 'Favorite',
              onTap: () => star++,
            ),
          ],
        ),
      );
      await tester.tap(find.byIcon(AppIcons.chevronLeft));
      await tester.tap(find.byIcon(AppIcons.star));
      expect(back, 1);
      expect(star, 1);
      expect(find.bySemanticsLabel('Back'), findsOneWidget);
      expect(find.bySemanticsLabel('Favorite'), findsOneWidget);
    });

    testWidgets('text item tap fires', (tester) async {
      var taps = 0;
      await pumpBar(
        tester,
        AppNavbarTop(
          title: 'Title',
          trailing: [AppNavbarItem.text(label: 'Done', onTap: () => taps++)],
        ),
      );
      await tester.tap(find.text('Done'));
      expect(taps, 1);
    });
  });

  group('overflow', () {
    testWidgets('long title ellipsizes at 360 without overflow', (
      tester,
    ) async {
      await pumpBar(
        tester,
        AppNavbarTop(
          title: 'A very long screen title that cannot possibly fit here',
          subtitle: 'And an equally long secondary line for the bar header',
          onBack: () {},
          trailing: [
            for (var i = 0; i < 3; i++)
              AppNavbarItem.icon(
                icon: AppIcons.star,
                semanticLabel: 'Star $i',
                onTap: () {},
              ),
          ],
        ),
        width: 360,
      );
      expect(tester.takeException(), isNull);
      final title = tester.widget<Text>(find.textContaining('A very long'));
      expect(title.overflow, TextOverflow.ellipsis);
      expect(tester.getSize(find.byType(AppNavbarTop)).width, 360);
    });

    testWidgets('long home header ellipsizes at 360', (tester) async {
      await pumpBar(
        tester,
        AppNavbarTop(
          avatar: const AppAvatar.letter(letter: 'B'),
          title: 'Good evening, Bartholomew Maximilian Fitzgerald!',
          subtitle: 'BSIT 2A · Caraga State University Main Campus',
          trailing: [
            AppNavbarItem.icon(
              icon: AppIcons.bell,
              semanticLabel: 'Notifications',
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
