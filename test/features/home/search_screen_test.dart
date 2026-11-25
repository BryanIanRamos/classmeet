import 'dart:async';

import 'package:classmeet/core/router/routes.dart';
import 'package:classmeet/core/theme/app_theme.dart';
import 'package:classmeet/core/widgets/feedback/empty_state.dart';
import 'package:classmeet/core/widgets/feedback/error_state.dart';
import 'package:classmeet/core/widgets/selection/app_chip.dart';
import 'package:classmeet/data/fakes/fake_config.dart';
import 'package:classmeet/data/providers.dart';
import 'package:classmeet/features/home/application/search_controller.dart';
import 'package:classmeet/features/home/presentation/screens/search_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'home_test_helpers.dart';

const _empty = FakeConfig(scenario: FakeScenario.empty, latency: Duration.zero);
const _error = FakeConfig(scenario: FakeScenario.error, latency: Duration.zero);

const _pastDebounce = Duration(milliseconds: 400);

Future<void> pumpSearch(
  WidgetTester tester, {
  FakeConfig config = FakeConfig.instant,
  Size size = const Size(428, 926),
  double keyboard = 0,
  String? initialQuery,
}) async {
  await tester.binding.setSurfaceSize(size);
  addTearDown(() => tester.binding.setSurfaceSize(null));
  tester.view.viewInsets = FakeViewPadding(bottom: keyboard * 3);
  addTearDown(tester.view.resetViewInsets);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [fakeConfigProvider.overrideWithValue(config)],
      retry: (_, _) => null,
      child: MaterialApp(
        theme: AppTheme.light,
        home: SearchScreen(initialQuery: initialQuery),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> type(WidgetTester tester, String text) async {
  await tester.enterText(find.byType(TextField), text);
  await tester.pump(_pastDebounce);
  await tester.pumpAndSettle();
}

AppChip chip(WidgetTester tester, String label) => tester.widget<AppChip>(
  find.byWidgetPredicate((w) => w is AppChip && w.label == label),
);

void main() {
  testWidgets('default: recent searches, chips and a quiet body', (
    tester,
  ) async {
    await pumpSearch(tester);
    expect(find.text('Search'), findsOneWidget);
    expect(find.text('Recent searches'), findsOneWidget);
    expect(find.text('Clear all'), findsOneWidget);
    expect(find.text('Data Structures midterm'), findsOneWidget);
    expect(find.text('Normalization'), findsOneWidget);
    expect(find.text('Networking 112'), findsOneWidget);
    expect(chip(tester, 'All').selected, isTrue);
    expect(find.text('Search results'), findsNothing);
  });

  testWidgets('typing shows the grouped results after the pause', (
    tester,
  ) async {
    await pumpSearch(tester);
    await tester.enterText(find.byType(TextField), 'i');
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('Arabela Matias'), findsNothing);
    await tester.pump(_pastDebounce);
    await tester.pumpAndSettle();

    expect(find.text('Search results'), findsOneWidget);
    expect(find.text('1 result'), findsOneWidget);
    expect(find.text('2 results'), findsOneWidget);
    expect(find.text('3 results'), findsOneWidget);
    expect(find.text('Prof. Rhea Santos'), findsOneWidget);
    expect(find.text('Created by Ara Matias'), findsOneWidget);
    expect(find.text('Arabela Matias'), findsOneWidget);
    expect(richLine('BSIT - II · Caraga State University'), findsOneWidget);
    expect(richLine('BSIT - IV · Caraga State University'), findsOneWidget);
    expect(
      richLine('BSIT - I · Father Saturnino Urios University'),
      findsOneWidget,
    );
  });

  testWidgets('empty groups are hidden', (tester) async {
    await pumpSearch(tester);
    await type(tester, 'Ara Matias');
    expect(find.text('Created by Ara Matias'), findsOneWidget);
    expect(find.text('1 result'), findsOneWidget);
    expect(find.text('2 results'), findsNothing);
    expect(find.text('3 results'), findsNothing);
  });

  testWidgets('chips filter by category', (tester) async {
    await pumpSearch(tester, initialQuery: 'i');
    expect(find.text('3 results'), findsOneWidget);

    final people = find.widgetWithText(AppChip, 'People');
    await tester.ensureVisible(people);
    await tester.tap(people);
    await tester.pumpAndSettle();
    expect(chip(tester, 'People').selected, isTrue);
    expect(find.text('3 results'), findsOneWidget);
    expect(find.text('2 results'), findsNothing);
    expect(find.text('View all'), findsNothing);

    final classes = find.widgetWithText(AppChip, 'Classes');
    await tester.ensureVisible(classes);
    await tester.tap(classes);
    await tester.pumpAndSettle();
    expect(find.text('1 result'), findsOneWidget);
    expect(find.text('Arabela Matias'), findsNothing);
  });

  testWidgets('View all selects the Materials chip', (tester) async {
    await pumpSearch(tester, initialQuery: 'i');
    await tester.tap(find.text('View all'));
    await tester.pumpAndSettle();
    expect(chip(tester, 'Materials').selected, isTrue);
    expect(chip(tester, 'All').selected, isFalse);
    expect(find.text('2 results'), findsOneWidget);
    expect(find.text('Arabela Matias'), findsNothing);
  });

  testWidgets('a recent search fills the field and runs', (tester) async {
    await pumpSearch(tester);
    await tester.tap(find.text('Normalization'));
    await tester.pumpAndSettle();
    expect(
      tester.widget<TextField>(find.byType(TextField)).controller!.text,
      'Normalization',
    );
    expect(find.text('Search results'), findsOneWidget);
    expect(find.text('No results for "Normalization"'), findsOneWidget);

    await tester.tap(find.text('Data Structures midterm'));
    await tester.pumpAndSettle();
    expect(
      find.text('No results for "Data Structures midterm"'),
      findsOneWidget,
    );
  });

  testWidgets('Clear all hides the recent searches', (tester) async {
    await pumpSearch(tester);
    await tester.tap(find.text('Clear all'));
    await tester.pumpAndSettle();
    expect(find.text('Recent searches'), findsNothing);
    expect(find.text('Normalization'), findsNothing);
  });

  testWidgets('empty scenario: no recents and a no-results message', (
    tester,
  ) async {
    await pumpSearch(tester, config: _empty);
    expect(find.text('Recent searches'), findsNothing);
    await type(tester, 'zebra');
    expect(find.byType(EmptyState), findsOneWidget);
    expect(find.text('No results for "zebra"'), findsOneWidget);
    expect(find.text('Try another word or category.'), findsOneWidget);
  });

  testWidgets('error scenario: retryable error, no recents', (tester) async {
    await pumpSearch(tester, config: _error);
    expect(find.text('Recent searches'), findsNothing);
    await type(tester, 'i');
    expect(find.byType(ErrorState), findsOneWidget);
    await tester.tap(find.text('Try again'));
    await tester.pumpAndSettle();
    expect(find.byType(ErrorState), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('the newest query wins', (tester) async {
    await pumpSearch(tester);
    await type(tester, 'i');
    await type(tester, 'Joshua');
    final container = ProviderScope.containerOf(
      tester.element(find.byType(SearchScreen)),
    );
    final state = container.read(homeSearchControllerProvider);
    expect(state.query, 'Joshua');
    expect(state.results.value!.people.length, 1);
  });

  testWidgets('class and material rows navigate; people do nothing', (
    tester,
  ) async {
    await pumpHome(tester);
    unawaited(router(tester).push(Routes.search));
    await tester.pumpAndSettle();
    expect(find.byType(SearchScreen), findsOneWidget);
    await type(tester, 'i');

    await tester.tap(find.text('Arabela Matias'));
    await tester.pumpAndSettle();
    expect(location(tester), Routes.search);

    await tester.tap(find.text('Prof. Rhea Santos'));
    await tester.pumpAndSettle();
    expect(location(tester), Routes.course('ite13'));

    router(tester).pop();
    await tester.pumpAndSettle();
    expect(location(tester), Routes.search);
    await tester.tap(find.text('Created by Ara Matias'));
    await tester.pumpAndSettle();
    expect(location(tester), Routes.reader('data-structures-algorithms'));
  });

  testWidgets('back pops to Home', (tester) async {
    await pumpHome(tester);
    unawaited(router(tester).push(Routes.search));
    await tester.pumpAndSettle();
    await tester.tap(find.bySemanticsLabel('Back'));
    await tester.pumpAndSettle();
    expect(location(tester), Routes.home);
  });

  testWidgets('the route ?q= pre-fills the field and searches it', (
    tester,
  ) async {
    await pumpHome(tester, location: '${Routes.search}?q=Arabela');
    expect(find.widgetWithText(TextField, 'Arabela'), findsOneWidget);
    expect(find.text('Search results'), findsOneWidget);
    expect(find.text('Arabela Matias'), findsOneWidget);
  });

  testWidgets('leaving while a search is in flight does not throw', (
    tester,
  ) async {
    const slow = FakeConfig(latency: Duration(seconds: 2));
    await tester.pumpWidget(
      ProviderScope(
        overrides: [fakeConfigProvider.overrideWithValue(slow)],
        retry: (_, _) => null,
        child: MaterialApp(
          theme: AppTheme.light,
          home: Builder(
            builder: (context) => Scaffold(
              body: TextButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(builder: (_) => const SearchScreen()),
                ),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pump(); // build the route; recents start loading
    await tester.pump(const Duration(seconds: 3)); // route in, recents load
    await tester.pump();
    await tester.enterText(find.byType(TextField), 'i');
    await tester.pump(_pastDebounce); // the 2 s search starts
    await tester.tap(find.bySemanticsLabel('Back'));
    await tester.pump(); // the pop starts
    await tester.pump(const Duration(seconds: 1)); // route out
    await tester.pump(); // removed; the provider is disposed
    expect(find.byType(SearchScreen), findsNothing);
    await tester.pump(const Duration(seconds: 2)); // the late answer lands
    expect(tester.takeException(), isNull);
  });

  testWidgets('no overflow at 360 dp, with the keyboard up', (tester) async {
    await pumpSearch(
      tester,
      size: const Size(360, 800),
      keyboard: 300,
      initialQuery: 'i',
    );
    expect(tester.takeException(), isNull);
    expect(find.text('Search results'), findsOneWidget);
  });
}
