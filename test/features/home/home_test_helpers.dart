/// Shared helpers for the Home feature tests: open the signed-in app on a
/// Home route with fake data and a pinned clock, and read where it is.
library;

import 'dart:async';

import 'package:classmeet/app.dart';
import 'package:classmeet/core/clock.dart';
import 'package:classmeet/core/router/app_router.dart';
import 'package:classmeet/core/router/routes.dart';
import 'package:classmeet/data/fakes/fake_config.dart';
import 'package:classmeet/data/providers.dart';
import 'package:classmeet/features/auth/application/session_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

const emptyConfig = FakeConfig(
  scenario: FakeScenario.empty,
  latency: Duration.zero,
);
const errorConfig = FakeConfig(
  scenario: FakeScenario.error,
  latency: Duration.zero,
);

/// The design's "Good evening" (Tuesday 2026-11-24, 7:30 PM); every Home
/// test and render pins the clock here.
final evening = DateTime(2026, 11, 24, 19, 30);

/// Opens the signed-in app on [location] (Home by default) at [size].
Future<void> pumpHome(
  WidgetTester tester, {
  FakeConfig config = FakeConfig.instant,
  Size size = const Size(428, 926),
  String location = Routes.home,
  List<Override> overrides = const [],
}) async {
  await tester.binding.setSurfaceSize(size);
  addTearDown(() => tester.binding.setSurfaceSize(null));
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        fakeConfigProvider.overrideWithValue(config),
        initialSessionStatusProvider.overrideWithValue(SessionStatus.ready),
        clockProvider.overrideWithValue(() => evening),
        ...overrides,
      ],
      retry: (_, _) => null,
      child: const ClassMeetApp(),
    ),
  );
  await tester.pumpAndSettle();
  router(tester).go(Routes.home);
  await tester.pumpAndSettle();
  if (location != Routes.home) {
    // push completes only when the route pops.
    unawaited(router(tester).push(location));
    await tester.pumpAndSettle();
  }
}

ProviderContainer container(WidgetTester tester) =>
    ProviderScope.containerOf(tester.element(find.byType(ClassMeetApp)));

GoRouter router(WidgetTester tester) => container(tester).read(routerProvider);

/// The top-most location, pushed routes included.
String location(WidgetTester tester) => router(tester).state.uri.toString();

/// What an inline widget (WidgetSpan) contributes to a span's plain text:
/// U+FFFC, the object replacement character.
final _placeholder = String.fromCharCode(0xFFFC);

/// A one-line rich text by its visible text, with inline gaps (WidgetSpan
/// placeholders) read as spaces, e.g. a Home card meta line.
Finder richLine(String text) => find.byWidgetPredicate(
  (w) =>
      w is RichText &&
      w.text
              .toPlainText(includeSemanticsLabels: false)
              .replaceAll(_placeholder, ' ') ==
          text,
);

/// Scrolls the first scrollable until [finder] is built and on screen.
Future<void> reveal(WidgetTester tester, Finder finder) async {
  await tester.scrollUntilVisible(
    finder,
    200,
    scrollable: find.byType(Scrollable).first,
  );
  await tester.pumpAndSettle();
}
