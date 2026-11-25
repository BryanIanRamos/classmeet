import 'package:classmeet/app.dart';
import 'package:classmeet/core/clock.dart';
import 'package:classmeet/core/router/app_router.dart';
import 'package:classmeet/core/router/routes.dart';
import 'package:classmeet/core/widgets/feedback/coming_soon_screen.dart';
import 'package:classmeet/core/widgets/feedback/error_state.dart';
import 'package:classmeet/data/fakes/fake_config.dart';
import 'package:classmeet/data/providers.dart';
import 'package:classmeet/features/auth/application/session_controller.dart';
import 'package:classmeet/features/home/application/home_providers.dart';
import 'package:classmeet/features/home/presentation/screens/home_dashboard_screen.dart';
import 'package:classmeet/features/home/presentation/screens/notifications_screen.dart';
import 'package:classmeet/features/home/presentation/screens/talon_credits_screen.dart';
import 'package:classmeet/features/home/presentation/widgets/home_stat_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

const _empty = FakeConfig(scenario: FakeScenario.empty, latency: Duration.zero);
const _error = FakeConfig(scenario: FakeScenario.error, latency: Duration.zero);

/// The design's "Good evening".
final _evening = DateTime(2026, 11, 24, 19, 30);

/// Opens the signed-in app on Home.
Future<void> pumpHome(
  WidgetTester tester, {
  FakeConfig config = FakeConfig.instant,
  Size size = const Size(428, 926),
}) async {
  await tester.binding.setSurfaceSize(size);
  addTearDown(() => tester.binding.setSurfaceSize(null));
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        fakeConfigProvider.overrideWithValue(config),
        initialSessionStatusProvider.overrideWithValue(SessionStatus.ready),
        clockProvider.overrideWithValue(() => _evening),
      ],
      retry: (_, _) => null,
      child: const ClassMeetApp(),
    ),
  );
  await tester.pumpAndSettle();
  router(tester).go(Routes.home);
  await tester.pumpAndSettle();
}

ProviderContainer container(WidgetTester tester) =>
    ProviderScope.containerOf(tester.element(find.byType(ClassMeetApp)));

/// The top-most location, pushed routes included.
String location(WidgetTester tester) => router(tester).state.uri.toString();

GoRouter router(WidgetTester tester) => container(tester).read(routerProvider);

Finder statCard(String title) =>
    find.byWidgetPredicate((w) => w is HomeStatCard && w.title == title);

void main() {
  testWidgets('shows the header, hero card and stat cards from the fakes', (
    tester,
  ) async {
    await pumpHome(tester);
    expect(find.byType(HomeDashboardScreen), findsOneWidget);

    // Header: username greeting (D-19) and program · school.
    expect(find.text('Good evening, Bryan!'), findsOneWidget);
    expect(find.text('BSIT 2A · CSU'), findsOneWidget);

    // Hero card.
    expect(find.text('YOUR DAILY PROGRESS'), findsOneWidget);
    expect(find.text('You got this!'), findsOneWidget);
    expect(find.text('3 activities remaining'), findsOneWidget);
    expect(find.text('Continue studying'), findsOneWidget);

    // Stat cards: streak 6 / 1 freeze, wallet 24 talons (INC-5).
    final streak = tester.widget<HomeStatCard>(statCard('Study streak'));
    expect((streak.value, streak.unit), ('6', 'days'));
    expect(streak.caption, '1 streak freeze left');
    expect(streak.linkLabel, 'View streak');
    final talons = tester.widget<HomeStatCard>(statCard('Talon credits'));
    expect((talons.value, talons.unit), ('24', 'talons'));
    expect(talons.caption, 'Earn by studying');
    expect(talons.linkLabel, 'View credits');
    expect(find.text('24'), findsOneWidget);
    expect(find.text('View credits'), findsOneWidget);
  });

  testWidgets('bell opens notifications', (tester) async {
    await pumpHome(tester);
    await tester.tap(find.bySemanticsLabel('Notifications'));
    await tester.pumpAndSettle();
    expect(find.byType(NotificationsScreen), findsOneWidget);
    expect(location(tester), Routes.notifications);
  });

  testWidgets('avatar opens the profile', (tester) async {
    await pumpHome(tester);
    await tester.tap(find.bySemanticsLabel('Profile'));
    await tester.pumpAndSettle();
    expect(location(tester), Routes.profile);
  });

  testWidgets('Continue studying opens the in-progress reviewer', (
    tester,
  ) async {
    await pumpHome(tester);
    await tester.tap(find.text('Continue studying'));
    await tester.pumpAndSettle();
    expect(location(tester), Routes.reader('data-structure-reviewer'));
  });

  testWidgets('streak card opens the streak gap, talon card the credits', (
    tester,
  ) async {
    await pumpHome(tester);
    await tester.tap(statCard('Study streak'));
    await tester.pumpAndSettle();
    expect(location(tester), Routes.streak);
    expect(find.byType(ComingSoonScreen), findsOneWidget);

    router(tester).go(Routes.home);
    await tester.pumpAndSettle();
    await tester.tap(statCard('Talon credits'));
    await tester.pumpAndSettle();
    expect(location(tester), Routes.talonCredits);
    expect(find.byType(TalonCreditsScreen), findsOneWidget);
  });

  testWidgets('empty scenario: nothing planned today, Continue opens Study', (
    tester,
  ) async {
    await pumpHome(tester, config: _empty);
    expect(find.text('All done for today'), findsOneWidget);
    expect(find.textContaining('remaining'), findsNothing);
    await tester.tap(find.text('Continue studying'));
    await tester.pumpAndSettle();
    expect(location(tester), Routes.study);
  });

  testWidgets('error scenario: nameless greeting and a retryable error', (
    tester,
  ) async {
    await pumpHome(tester, config: _error);
    expect(find.text('Good evening!'), findsOneWidget);
    expect(find.text('BSIT 2A · CSU'), findsNothing);
    expect(find.byType(ErrorState), findsOneWidget);
    expect(find.text('You got this!'), findsNothing);

    await tester.tap(find.text('Try again'));
    await tester.pumpAndSettle();
    expect(find.byType(ErrorState), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('no overflow at 360 dp', (tester) async {
    await pumpHome(tester, size: const Size(360, 800));
    expect(tester.takeException(), isNull);
    expect(find.text('Earn by studying'), findsOneWidget);
  });

  group('greetingFor', () {
    test('morning before noon, afternoon until 6 PM, then evening', () {
      expect(greetingFor(DateTime(2026, 1, 1, 0, 5)), 'Good morning');
      expect(greetingFor(DateTime(2026, 1, 1, 11, 59)), 'Good morning');
      expect(greetingFor(DateTime(2026, 1, 1, 12)), 'Good afternoon');
      expect(greetingFor(DateTime(2026, 1, 1, 17, 59)), 'Good afternoon');
      expect(greetingFor(DateTime(2026, 1, 1, 18)), 'Good evening');
    });
  });

  group('countLabel', () {
    test('singular for 1, plural otherwise', () {
      expect(countLabel(1, 'day'), 'day');
      expect(countLabel(0, 'day'), 'days');
      expect(countLabel(6, 'day'), 'days');
      expect(countLabel(2, 'activity', 'activities'), 'activities');
    });
  });
}
