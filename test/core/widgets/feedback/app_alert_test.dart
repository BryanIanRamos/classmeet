import 'package:classmeet/core/assets/app_icons.dart';
import 'package:classmeet/core/theme/app_colors.dart';
import 'package:classmeet/core/theme/app_theme.dart';
import 'package:classmeet/core/widgets/feedback/app_alert.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _wrap(Widget child, {double width = 428}) => MaterialApp(
  theme: AppTheme.light,
  home: Scaffold(
    body: Align(
      alignment: Alignment.topLeft,
      child: SizedBox(width: width, child: child),
    ),
  ),
);

BoxDecoration _deco(WidgetTester tester) =>
    tester.widget<Container>(find.byType(Container).first).decoration!
        as BoxDecoration;

void main() {
  testWidgets('outline: tint fill, tone border, radius 12, padding 16', (
    tester,
  ) async {
    for (final tone in AppAlertTone.values) {
      await tester.pumpWidget(
        _wrap(AppAlert(tone: tone, title: 'T', message: 'M')),
      );
      final deco = _deco(tester);
      expect(deco.color, tone.tint);
      final border = deco.border! as Border;
      expect(border.top.color, tone.strong);
      expect(border.top.width, AppAlert.borderWidth);
      expect(deco.borderRadius, BorderRadius.circular(12));
    }
    expect(AppAlertTone.error.strong, AppColors.ember500);
    expect(AppAlertTone.success.strong, AppColors.sprout500);
    expect(AppAlertTone.info.strong, AppColors.sky500);
    expect(AppAlertTone.warning.strong, AppColors.talon500);
    expect(AppAlertTone.normal.strong, AppColors.sage500);
  });

  testWidgets('filled: solid tone fill, no border, white text', (tester) async {
    for (final tone in AppAlertTone.values) {
      await tester.pumpWidget(
        _wrap(
          AppAlert(
            tone: tone,
            style: AppAlertStyle.filled,
            icon: AppIcons.star,
            title: 'Title',
          ),
        ),
      );
      final deco = _deco(tester);
      expect(deco.color, tone.strong);
      expect(deco.border, isNull);
      expect(
        tester.widget<Text>(find.text('Title')).style!.color,
        AppColors.white,
      );
      expect(tester.widget<Icon>(find.byType(Icon)).color, AppColors.white);
    }
  });

  testWidgets('geometry: icon 24, 16 gap, 4 between title and message', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        const AppAlert(icon: AppIcons.star, title: 'Title', message: 'Message'),
      ),
    );
    final box = tester.getRect(find.byType(AppAlert));
    expect(box.width, 428);
    expect(tester.getSize(find.byType(Icon)), const Size(24, 24));
    expect(
      tester.getTopLeft(find.text('Title')).dx - box.left,
      AppAlert.borderWidth + 16 + 24 + 16,
    );
    expect(
      tester.getTopLeft(find.text('Message')).dy -
          tester.getBottomLeft(find.text('Title')).dy,
      4,
    );
  });

  testWidgets('close and action callbacks fire', (tester) async {
    var closed = 0, primary = 0, secondary = 0;
    await tester.pumpWidget(
      _wrap(
        AppAlert(
          title: 'T',
          onClose: () => closed++,
          actionLabel: 'Do it',
          onAction: () => primary++,
          secondaryActionLabel: 'Later',
          onSecondaryAction: () => secondary++,
        ),
      ),
    );
    await tester.tap(find.byIcon(AppIcons.x));
    await tester.tap(find.text('Do it'));
    await tester.tap(find.text('Later'));
    expect([closed, primary, secondary], [1, 1, 1]);
    expect(
      tester.widget<Text>(find.text('Do it')).style!.color,
      AppColors.sage500,
    );
    expect(
      tester.widget<Text>(find.text('Later')).style!.color,
      AppColors.grey400,
    );
  });

  testWidgets('no close or actions by default', (tester) async {
    await tester.pumpWidget(_wrap(const AppAlert(title: 'T')));
    expect(find.byIcon(AppIcons.x), findsNothing);
  });

  testWidgets('long text does not overflow at 360dp', (tester) async {
    // Tall surface: the test font is wide, so the card gets very tall.
    await tester.binding.setSurfaceSize(const Size(360, 2000));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      _wrap(
        AppAlert(
          icon: AppIcons.star,
          title: 'A rather long alert title that must wrap to several lines',
          message: 'A very long message ' * 12,
          onClose: () {},
          actionLabel: 'A long primary action',
          onAction: () {},
          secondaryActionLabel: 'A long secondary action',
          onSecondaryAction: () {},
        ),
        width: 360,
      ),
    );
    expect(tester.takeException(), isNull);
    expect(tester.getSize(find.byType(AppAlert)).width, 360);
  });
}
