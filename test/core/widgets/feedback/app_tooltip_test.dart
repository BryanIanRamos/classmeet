import 'package:classmeet/core/theme/app_colors.dart';
import 'package:classmeet/core/theme/app_theme.dart';
import 'package:classmeet/core/widgets/feedback/app_tooltip.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _wrap(Widget child) => MaterialApp(
  theme: AppTheme.light,
  home: Scaffold(body: Center(child: child)),
);

void main() {
  testWidgets('bubble geometry: radius 8, fill sage, arrow 12x8', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(const AppTooltipBubble(message: 'This is a Tooltip')),
    );
    final deco =
        tester
                .widget<Container>(
                  find.descendant(
                    of: find.byType(AppTooltipBubble),
                    matching: find.byType(Container),
                  ),
                )
                .decoration!
            as BoxDecoration;
    expect(deco.color, AppColors.sage500);
    expect(deco.borderRadius, BorderRadius.circular(8));
    expect(
      tester.getSize(find.byKey(const Key('tooltip-arrow'))),
      const Size(12, 8),
    );
  });

  testWidgets('arrow sits on the edge named by the position', (tester) async {
    for (final position in AppTooltipPosition.values) {
      await tester.pumpWidget(
        _wrap(AppTooltipBubble(message: 'Tip', position: position)),
      );
      final all = tester.getRect(find.byType(AppTooltipBubble));
      final arrow = tester.getRect(find.byKey(const Key('tooltip-arrow')));
      final bubbleRect = tester.getRect(
        find
            .descendant(
              of: find.byType(AppTooltipBubble),
              matching: find.byType(Container),
            )
            .first,
      );
      switch (position) {
        case AppTooltipPosition.top:
          expect(arrow.bottom, bubbleRect.top);
          expect(arrow.top, all.top);
          expect(arrow.center.dx, bubbleRect.center.dx);
        case AppTooltipPosition.bottom:
          expect(arrow.top, bubbleRect.bottom);
          expect(arrow.center.dx, bubbleRect.center.dx);
        case AppTooltipPosition.left:
          expect(arrow.right, bubbleRect.left);
          expect(arrow.size, const Size(8, 12));
          expect(arrow.center.dy, bubbleRect.center.dy);
        case AppTooltipPosition.right:
          expect(arrow.left, bubbleRect.right);
          expect(arrow.center.dy, bubbleRect.center.dy);
      }
    }
  });

  testWidgets('wrapper shows the bubble on long-press and hides it', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(const AppTooltip(message: 'Hello tip', child: Text('Target'))),
    );
    expect(find.text('Hello tip'), findsNothing);
    await tester.longPress(find.text('Target'));
    await tester.pump();
    expect(find.text('Hello tip'), findsOneWidget);
    // Bubble is above the target (bubbleSide defaults to top).
    expect(
      tester.getBottomLeft(find.byType(AppTooltipBubble)).dy,
      lessThanOrEqualTo(tester.getTopLeft(find.text('Target')).dy),
    );
    await tester.pump(const Duration(seconds: 3));
    expect(find.text('Hello tip'), findsNothing);
  });

  testWidgets('wrapper shows on mouse hover', (tester) async {
    await tester.pumpWidget(
      _wrap(const AppTooltip(message: 'Hover tip', child: Text('Target'))),
    );
    final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await mouse.addPointer(location: Offset.zero);
    await mouse.moveTo(tester.getCenter(find.text('Target')));
    await tester.pump();
    expect(find.text('Hover tip'), findsOneWidget);
    await mouse.moveTo(const Offset(1, 1));
    await tester.pump();
    expect(find.text('Hover tip'), findsNothing);
  });
}
