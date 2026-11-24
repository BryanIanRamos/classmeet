import 'package:classmeet/core/theme/app_colors.dart';
import 'package:classmeet/core/theme/app_theme.dart';
import 'package:classmeet/core/theme/app_typography.dart';
import 'package:classmeet/core/widgets/display/section_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> pump(WidgetTester tester, Widget child, {double width = 360}) {
  return tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.light,
      home: Scaffold(
        body: Center(
          child: SizedBox(width: width, child: child),
        ),
      ),
    ),
  );
}

void main() {
  testWidgets('title is S1, link is B3 Sage-500 and fires onActionTap', (
    tester,
  ) async {
    var taps = 0;
    await pump(
      tester,
      SectionHeader(
        title: 'Coming up next',
        actionLabel: 'View study plan',
        onActionTap: () => taps++,
      ),
    );
    final title = tester.widget<Text>(find.text('Coming up next'));
    expect(title.style!.fontSize, AppTypography.s1.fontSize);
    expect(title.style!.height, AppTypography.s1.height);
    final link = tester.widget<Text>(find.text('View study plan'));
    expect(link.style!.fontSize, AppTypography.b3.fontSize);
    expect(link.style!.color, AppColors.sage500);
    await tester.tap(find.text('View study plan'));
    expect(taps, 1);
  });

  testWidgets('no link without a callback; subtitle shows', (tester) async {
    await pump(
      tester,
      const SectionHeader(
        title: 'Your daily quests',
        subtitle: 'Earn talons',
        actionLabel: 'View all',
      ),
    );
    expect(find.text('View all'), findsNothing);
    expect(find.text('Earn talons'), findsOneWidget);
  });

  testWidgets('long title ellipsizes without overflow at 360dp', (
    tester,
  ) async {
    await pump(
      tester,
      SectionHeader(
        title: 'A very long section title that cannot possibly fit on a line',
        actionLabel: 'View study plan',
        onActionTap: () {},
      ),
    );
    expect(tester.takeException(), isNull);
  });
}
