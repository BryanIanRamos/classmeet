import 'package:classmeet/core/assets/app_images.dart';
import 'package:classmeet/core/theme/app_theme.dart';
import 'package:classmeet/core/widgets/feedback/empty_state.dart';
import 'package:classmeet/core/widgets/feedback/error_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _wrap(Widget child, {double width = 360}) => MaterialApp(
  theme: AppTheme.light,
  home: Scaffold(
    body: SizedBox(width: width, height: 640, child: child),
  ),
);

void main() {
  testWidgets('EmptyState shows title, message and the action fires', (
    tester,
  ) async {
    var taps = 0;
    await tester.pumpWidget(
      _wrap(
        EmptyState(
          image: AppImages.createReadyOwl,
          title: 'Nothing here',
          message: 'Add something.',
          actionLabel: 'Add',
          onAction: () => taps++,
        ),
      ),
    );
    expect(find.text('Nothing here'), findsOneWidget);
    expect(find.text('Add something.'), findsOneWidget);
    expect(find.byType(Image), findsOneWidget);
    await tester.tap(find.text('Add'));
    expect(taps, 1);
    expect(tester.takeException(), isNull);
  });

  testWidgets('EmptyState without message, image or action', (tester) async {
    await tester.pumpWidget(_wrap(const EmptyState(title: 'Empty')));
    expect(find.text('Empty'), findsOneWidget);
    expect(find.byType(Image), findsNothing);
    expect(find.byType(TextButton), findsNothing);
  });

  testWidgets('ErrorState shows defaults and retry fires', (tester) async {
    var retries = 0;
    await tester.pumpWidget(_wrap(ErrorState(onRetry: () => retries++)));
    expect(find.text('Something went wrong'), findsOneWidget);
    expect(find.text('Try again'), findsOneWidget);
    await tester.tap(find.text('Try again'));
    expect(retries, 1);
  });

  testWidgets('ErrorState without onRetry hides the button', (tester) async {
    await tester.pumpWidget(_wrap(const ErrorState()));
    expect(find.text('Try again'), findsNothing);
  });
}
