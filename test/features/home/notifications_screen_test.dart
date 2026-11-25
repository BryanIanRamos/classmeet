import 'package:classmeet/core/clock.dart';
import 'package:classmeet/core/theme/app_theme.dart';
import 'package:classmeet/core/widgets/feedback/empty_state.dart';
import 'package:classmeet/core/widgets/feedback/error_state.dart';
import 'package:classmeet/data/fakes/fake_config.dart';
import 'package:classmeet/data/providers.dart';
import 'package:classmeet/features/home/application/notifications_controller.dart';
import 'package:classmeet/features/home/presentation/screens/notifications_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

const _empty = FakeConfig(scenario: FakeScenario.empty, latency: Duration.zero);
const _error = FakeConfig(scenario: FakeScenario.error, latency: Duration.zero);

final _now = DateTime(2026, 11, 24, 19, 30);

Future<void> pump(
  WidgetTester tester, {
  FakeConfig config = FakeConfig.instant,
  Size size = const Size(428, 926),
  bool withBackStack = false,
}) async {
  await tester.binding.setSurfaceSize(size);
  addTearDown(() => tester.binding.setSurfaceSize(null));
  const screen = NotificationsScreen();
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        fakeConfigProvider.overrideWithValue(config),
        clockProvider.overrideWithValue(() => _now),
      ],
      retry: (_, _) => null,
      child: MaterialApp(
        theme: AppTheme.light,
        home: withBackStack
            ? Builder(
                builder: (context) => Scaffold(
                  body: TextButton(
                    onPressed: () => Navigator.of(
                      context,
                    ).push(MaterialPageRoute<void>(builder: (_) => screen)),
                    child: const Text('open'),
                  ),
                ),
              )
            : screen,
      ),
    ),
  );
  await tester.pumpAndSettle();
}

final _dots = find.byKey(const ValueKey('unread-dot'));

void main() {
  test('time labels and groups', () {
    expect(timeLabel(DateTime(2026, 11, 24, 23, 59), _now), 'Due at 11:59 PM');
    expect(
      timeLabel(_now.subtract(const Duration(hours: 2)), _now),
      '2hrs ago',
    );
    expect(timeLabel(_now.subtract(const Duration(hours: 1)), _now), '1hr ago');
    expect(
      timeLabel(_now.subtract(const Duration(minutes: 5)), _now),
      '5min ago',
    );
    expect(
      timeLabel(_now.subtract(const Duration(days: 1)), _now),
      'Yesterday',
    );
    expect(
      timeLabel(_now.subtract(const Duration(days: 3)), _now),
      '3 days ago',
    );
    expect(groupFor(_now, _now), NotificationGroup.today);
    expect(
      groupFor(DateTime(2026, 11, 23, 8), _now),
      NotificationGroup.yesterday,
    );
    expect(groupFor(DateTime(2026, 11, 20), _now), NotificationGroup.earlier);
  });

  testWidgets('default: grouped list with copy and times', (tester) async {
    await pump(tester);
    expect(find.text('Notifications'), findsOneWidget);
    for (final chip in ['All', 'Classes', 'Rewards', 'System']) {
      expect(find.text(chip), findsOneWidget);
    }
    expect(find.text('Today'), findsOneWidget);
    expect(find.text('Yesterday'), findsWidgets);
    expect(find.text('Quiz due tonight'), findsOneWidget);
    expect(find.text('Due at 11:59 PM'), findsOneWidget);
    expect(find.text('New class material'), findsOneWidget);
    expect(find.text('2hrs ago'), findsOneWidget);
    expect(find.text('You earned 5 Talons!'), findsOneWidget);
    expect(find.text('Mark all as read'), findsOneWidget);
    expect(_dots, findsNWidgets(3));
  });

  testWidgets('Rewards chip refetches and shows only rewards', (tester) async {
    await pump(tester);
    await tester.tap(find.text('Rewards'));
    await tester.pumpAndSettle();
    expect(find.text('You earned 5 Talons!'), findsOneWidget);
    expect(find.text('Daily login reward'), findsOneWidget);
    expect(find.text('Quiz due tonight'), findsNothing);
    expect(find.text('Welcome to ClassMeet'), findsNothing);

    await tester.tap(find.text('All'));
    await tester.pumpAndSettle();
    expect(find.text('Quiz due tonight'), findsOneWidget);
  });

  testWidgets('Mark all as read removes the unread dots', (tester) async {
    await pump(tester);
    await tester.tap(find.text('Mark all as read'));
    await tester.pumpAndSettle();
    expect(_dots, findsNothing);
    expect(find.text('Mark all as read'), findsNothing);
    expect(find.text('Quiz due tonight'), findsOneWidget);
  });

  testWidgets('empty shows the empty state', (tester) async {
    await pump(tester, config: _empty);
    expect(find.byType(EmptyState), findsOneWidget);
    expect(find.text('No notifications yet'), findsOneWidget);
    expect(find.text('Mark all as read'), findsNothing);
  });

  testWidgets('error shows the error state and retry works', (tester) async {
    await pump(tester, config: _error);
    expect(find.byType(ErrorState), findsOneWidget);
    expect(find.text('Classes'), findsOneWidget);
    await tester.tap(find.text('Try again'));
    await tester.pumpAndSettle();
    expect(find.byType(ErrorState), findsOneWidget);
  });

  testWidgets('back pops the screen', (tester) async {
    await pump(tester, withBackStack: true);
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    expect(find.byType(NotificationsScreen), findsOneWidget);
    await tester.tap(find.bySemanticsLabel('Back'));
    await tester.pumpAndSettle();
    expect(find.byType(NotificationsScreen), findsNothing);
  });

  testWidgets('no overflow at 360', (tester) async {
    await pump(tester, size: const Size(360, 640));
    expect(tester.takeException(), isNull);
    await tester.ensureVisible(find.text('Rewards'));
    await tester.tap(find.text('Rewards'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}
