import 'package:classmeet/core/assets/app_icons.dart';
import 'package:classmeet/core/router/app_bottom_nav.dart';
import 'package:classmeet/core/router/app_shell.dart';
import 'package:classmeet/core/router/routes.dart';
import 'package:classmeet/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

int createdBranches = 0;

class _Branch extends StatefulWidget {
  const _Branch(this.name);
  final String name;

  @override
  State<_Branch> createState() => _BranchState();
}

class _BranchState extends State<_Branch> {
  @override
  void initState() {
    super.initState();
    if (widget.name == 'Study body') createdBranches++;
  }

  @override
  Widget build(BuildContext context) => Center(child: Text(widget.name));
}

GoRouter buildRouter() {
  StatefulShellBranch branch(String path, String name) => StatefulShellBranch(
    routes: [GoRoute(path: path, builder: (_, _) => _Branch(name))],
  );
  return GoRouter(
    initialLocation: Routes.home,
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (_, _, shell) => AppShell(navigationShell: shell),
        branches: [
          branch(Routes.home, 'Home body'),
          branch(Routes.study, 'Study body'),
          branch(Routes.play, 'Play body'),
          branch(Routes.friends, 'Friends body'),
        ],
      ),
      GoRoute(
        path: Routes.create,
        builder: (_, _) => const Text('Create page'),
      ),
      GoRoute(
        path: Routes.quizSource,
        builder: (_, _) => const Text('Quiz source page'),
      ),
    ],
  );
}

Future<GoRouter> pumpShell(WidgetTester tester, {double width = 428}) async {
  createdBranches = 0;
  await tester.binding.setSurfaceSize(Size(width, 800));
  addTearDown(() => tester.binding.setSurfaceSize(null));
  final router = buildRouter();
  addTearDown(router.dispose);
  await tester.pumpWidget(
    MaterialApp.router(theme: AppTheme.light, routerConfig: router),
  );
  await tester.pumpAndSettle();
  return router;
}

String location(GoRouter r) =>
    r.routerDelegate.currentConfiguration.uri.toString();

void main() {
  final sheetTitle = find.text('Create something');

  testWidgets('tapping a tab switches the branch', (tester) async {
    final router = await pumpShell(tester);
    await tester.tap(find.text('Play'));
    await tester.pumpAndSettle();
    expect(location(router), Routes.play);
    await tester.tap(find.text('Friends'));
    await tester.pumpAndSettle();
    expect(location(router), Routes.friends);
  });

  testWidgets('branches are built once and kept', (tester) async {
    await pumpShell(tester);
    await tester.tap(find.text('Study'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Home'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Study'));
    await tester.pumpAndSettle();
    expect(createdBranches, 1);
  });

  testWidgets('+ opens the overlay, the bar stays and shows an x', (
    tester,
  ) async {
    await pumpShell(tester);
    expect(sheetTitle, findsNothing);
    await tester.tap(find.byIcon(AppIcons.plus));
    await tester.pumpAndSettle();
    expect(sheetTitle, findsOneWidget);
    expect(find.byIcon(AppIcons.x), findsOneWidget);
    expect(find.byType(AppBottomNav), findsOneWidget);
    // The overlay ends where the bar starts.
    expect(
      tester.getBottomLeft(find.byKey(const ValueKey('create-overlay'))).dy,
      tester.getTopLeft(find.byType(AppBottomNav)).dy,
    );
  });

  testWidgets('the x closes the overlay', (tester) async {
    await pumpShell(tester);
    await tester.tap(find.byIcon(AppIcons.plus));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(AppIcons.x));
    await tester.pumpAndSettle();
    expect(sheetTitle, findsNothing);
    expect(find.byIcon(AppIcons.plus), findsOneWidget);
  });

  testWidgets('a scrim tap closes the overlay', (tester) async {
    await pumpShell(tester);
    await tester.tap(find.byIcon(AppIcons.plus));
    await tester.pumpAndSettle();
    await tester.tapAt(const Offset(200, 40));
    await tester.pumpAndSettle();
    expect(sheetTitle, findsNothing);
  });

  testWidgets('system back closes the overlay and stays on the tab', (
    tester,
  ) async {
    final router = await pumpShell(tester);
    await tester.tap(find.text('Study'));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(AppIcons.plus));
    await tester.pumpAndSettle();
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(sheetTitle, findsNothing);
    expect(location(router), Routes.study);
  });

  testWidgets('a tab tap while open closes it and switches', (tester) async {
    final router = await pumpShell(tester);
    await tester.tap(find.byIcon(AppIcons.plus));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Play'));
    await tester.pumpAndSettle();
    expect(sheetTitle, findsNothing);
    expect(location(router), Routes.play);
  });

  testWidgets('the Quizzes row closes the overlay and opens the wizard', (
    tester,
  ) async {
    await pumpShell(tester);
    await tester.tap(find.byIcon(AppIcons.plus));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Quizzes'));
    await tester.pumpAndSettle();
    expect(find.text('Quiz source page'), findsOneWidget);
  });

  testWidgets('See all tools opens the Create screen', (tester) async {
    await pumpShell(tester);
    await tester.tap(find.byIcon(AppIcons.plus));
    await tester.pumpAndSettle();
    await tester.tap(find.text('See all tools'));
    await tester.pumpAndSettle();
    expect(find.text('Create page'), findsOneWidget);
  });

  for (final width in [360.0, 428.0]) {
    testWidgets('no overflow at ${width.toInt()}dp, open', (tester) async {
      await pumpShell(tester, width: width);
      await tester.tap(find.byIcon(AppIcons.plus));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  }
}
