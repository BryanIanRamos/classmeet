import 'package:classmeet/core/theme/app_theme.dart';
import 'package:classmeet/core/widgets/feedback/coming_soon_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('shows the title, the note and the gap id in debug', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: const ComingSoonScreen(title: 'Friends', gapId: 'GAP-06'),
      ),
    );
    expect(find.text('Friends'), findsOneWidget);
    expect(find.text('Coming soon'), findsOneWidget);
    expect(find.text(ComingSoonScreen.defaultMessage), findsOneWidget);
    expect(find.text('GAP-06'), findsOneWidget); // tests run in debug mode
    expect(find.bySemanticsLabel('Back'), findsNothing); // nothing to pop
  });

  testWidgets('back pops when the screen was pushed', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const ComingSoonScreen(title: 'Profile'),
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
    expect(find.text('Profile'), findsOneWidget);

    await tester.tap(find.bySemanticsLabel('Back'));
    await tester.pumpAndSettle();
    expect(find.text('Profile'), findsNothing);
  });

  testWidgets('fits a 360 × 640 screen without overflow', (tester) async {
    await tester.binding.setSurfaceSize(const Size(360, 640));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: const ComingSoonScreen(title: 'Streak details'),
      ),
    );
    expect(tester.takeException(), isNull);
  });
}
