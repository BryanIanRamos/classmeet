import 'package:classmeet/core/assets/app_icons.dart';
import 'package:classmeet/core/theme/app_colors.dart';
import 'package:classmeet/core/theme/app_theme.dart';
import 'package:classmeet/core/theme/app_typography.dart';
import 'package:classmeet/core/widgets/display/app_avatar.dart';
import 'package:classmeet/core/widgets/display/app_badge.dart';
import 'package:classmeet/core/widgets/display/app_list_row.dart';
import 'package:classmeet/core/widgets/feedback/app_progress_bar.dart';
import 'package:classmeet/core/widgets/selection/app_checkbox.dart';
import 'package:classmeet/core/widgets/selection/app_radio.dart';
import 'package:classmeet/core/widgets/selection/app_toggle.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> pump(WidgetTester tester, Widget child, {double width = 394}) {
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

BoxDecoration firstDecoration(WidgetTester tester) =>
    tester
            .widget<DecoratedBox>(
              find
                  .descendant(
                    of: find.byType(AppListRow),
                    matching: find.byType(DecoratedBox),
                  )
                  .first,
            )
            .decoration
        as BoxDecoration;

void main() {
  testWidgets('card row matches the Home "Coming up next" card', (
    tester,
  ) async {
    await pump(
      tester,
      const AppListRow(
        leadingIcon: AppIcons.calendarDays,
        title: 'IT109 Midterm',
        subtitle: '3 activities left',
        showChevron: true,
        bottom: AppProgressBar(value: 0.67, label: '67%'),
      ),
    );
    final origin = tester.getTopLeft(find.byType(AppListRow));
    final slot = tester.getRect(find.byKey(const ValueKey('list-row-leading')));
    expect(slot.size, const Size(40, 40));
    // Padding 16 (the border sits inside the box, no extra inset).
    expect(slot.topLeft - origin, const Offset(16, 16));
    final title = tester.widget<Text>(find.text('IT109 Midterm'));
    expect(title.style!.fontSize, AppTypography.s1.fontSize);
    final sub = tester.widget<Text>(find.text('3 activities left'));
    expect(sub.style!.fontSize, AppTypography.c1.fontSize);
    expect(sub.style!.color, AppColors.grey500);
    // 10 gap between the slot and the text.
    expect(tester.getTopLeft(find.text('IT109 Midterm')).dx, slot.right + 10);
    final chevron = tester.getRect(find.byIcon(AppIcons.chevronRight));
    expect(chevron.size, const Size(24, 24));
    expect(chevron.right, 394 - 16);
    // The chevron is centred on the 28 title line.
    expect(chevron.center.dy, origin.dy + 16 + 14);
    final d = firstDecoration(tester);
    expect(d.color, AppColors.grey50);
    expect(d.borderRadius, BorderRadius.circular(16));
  });

  testWidgets('plain row is at least 56 high with a B1 title', (tester) async {
    await pump(
      tester,
      const AppListRow(style: AppListRowStyle.plain, title: 'Title'),
      width: 350,
    );
    expect(tester.getSize(find.byType(AppListRow)), const Size(350, 56));
    final title = tester.widget<Text>(find.text('Title'));
    expect(title.style!.fontSize, AppTypography.b1.fontSize);
    expect(tester.getTopLeft(find.text('Title')).dx, 12);
  });

  testWidgets('avatar leading slot', (tester) async {
    await pump(
      tester,
      const AppListRow(
        style: AppListRowStyle.plain,
        title: 'Name',
        leading: AppAvatar.letter(letter: 'A'),
      ),
    );
    expect(tester.getSize(find.byType(AppAvatar)), const Size(32, 32));
  });

  testWidgets('trailing text, chevron and badge render', (tester) async {
    await pump(
      tester,
      const AppListRow(
        style: AppListRowStyle.plain,
        title: 'Title',
        trailingText: 'Details',
        trailing: AppBadge(label: '5'),
        showChevron: true,
      ),
    );
    expect(find.text('Details'), findsOneWidget);
    expect(find.byType(AppBadge), findsOneWidget);
    expect(find.byIcon(AppIcons.chevronRight), findsOneWidget);
    expect(
      tester.widget<Icon>(find.byIcon(AppIcons.chevronRight)).color,
      AppColors.grey400,
    );
  });

  testWidgets('checkbox, radio and toggle trailing callbacks fire', (
    tester,
  ) async {
    bool? checked;
    int? radio;
    bool? toggled;
    await pump(
      tester,
      Column(
        children: [
          AppListRow(
            style: AppListRowStyle.plain,
            title: 'Checkbox',
            trailing: AppCheckbox(value: false, onChanged: (v) => checked = v),
          ),
          AppListRow(
            style: AppListRowStyle.plain,
            title: 'Radio',
            trailing: AppRadio<int>(
              value: 1,
              groupValue: null,
              onChanged: (v) => radio = v,
            ),
          ),
          AppListRow(
            style: AppListRowStyle.plain,
            title: 'Toggle',
            trailing: AppToggle(value: false, onChanged: (v) => toggled = v),
          ),
        ],
      ),
    );
    await tester.tap(find.byType(AppCheckbox));
    await tester.tap(find.byType(AppRadio<int>));
    await tester.tap(find.byType(AppToggle));
    expect(checked, true);
    expect(radio, 1);
    expect(toggled, true);
  });

  testWidgets('tap fires and shows a flat pressed fill; null is inert', (
    tester,
  ) async {
    var taps = 0;
    await pump(tester, AppListRow(title: 'Row', onTap: () => taps++));
    await tester.tap(find.text('Row'));
    expect(taps, 1);
    final g = await tester.startGesture(tester.getCenter(find.text('Row')));
    await tester.pump();
    expect(firstDecoration(tester).color, AppColors.grey100);
    await g.up();

    await pump(tester, const AppListRow(title: 'Row'));
    expect(find.byType(GestureDetector), findsNothing);
  });

  testWidgets('divider draws a bottom line', (tester) async {
    await pump(
      tester,
      const AppListRow(
        style: AppListRowStyle.plain,
        title: 'Row',
        showDivider: true,
      ),
    );
    final border = firstDecoration(tester).border! as Border;
    expect(border.bottom.color, AppColors.grey200);
  });

  for (final style in AppListRowStyle.values) {
    testWidgets('long texts ellipsize without overflow at 360dp ($style)', (
      tester,
    ) async {
      final long = 'long ' * 40;
      await pump(
        tester,
        AppListRow(
          style: style,
          leadingIcon: AppIcons.fileText,
          title: long,
          subtitle: long,
          trailingText: long,
          trailing: const AppBadge(label: 'New'),
          showChevron: true,
        ),
        width: 360,
      );
      expect(tester.takeException(), isNull);
    });
  }
}
