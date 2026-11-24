import 'package:classmeet/app.dart';
import 'package:classmeet/core/dev/dev_catalog.dart';
import 'package:classmeet/core/dev/frames.dart';
import 'package:classmeet/core/dev/token_gallery.dart';
import 'package:classmeet/core/router/app_router.dart';
import 'package:classmeet/features/auth/application/session_controller.dart';
import 'package:classmeet/features/auth/presentation/screens/sign_up_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

Future<ProviderContainer> pumpCatalog(
  WidgetTester tester, {
  double width = 428,
  double height = 900,
}) async {
  tester.view.physicalSize = Size(width, height);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  final container = ProviderContainer(
    overrides: [
      initialSessionStatusProvider.overrideWithValue(SessionStatus.ready),
    ],
  );
  addTearDown(container.dispose);
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: const ClassMeetApp(),
    ),
  );
  await tester.pumpAndSettle();
  container.read(routerProvider).go('/dev');
  await tester.pumpAndSettle();
  return container;
}

void main() {
  for (final width in [360.0, 428.0]) {
    testWidgets('lists every frame and gap without overflow at $width', (
      tester,
    ) async {
      // A tall view builds the whole lazy list at once.
      await pumpCatalog(tester, width: width, height: 12000);
      expect(find.byType(DevCatalog), findsOneWidget);
      expect(find.text('Tokens'), findsOneWidget);
      for (final frame in devFrames) {
        expect(
          find.text('${frame.number}  ${frame.title}'),
          findsOneWidget,
          reason: frame.number,
        );
      }
      for (final path in DevCatalog.gapPaths) {
        expect(find.text(path), findsOneWidget, reason: path);
      }
      expect(find.text('Gaps'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('tapping a row opens that location', (tester) async {
    await pumpCatalog(tester);
    await tester.tap(find.text('Tokens'));
    await tester.pumpAndSettle();
    expect(find.byType(TokenGallery), findsOneWidget);
  });

  testWidgets('a frame row pushes its host screen', (tester) async {
    await pumpCatalog(tester);
    await tester.scrollUntilVisible(
      find.text('3.1  Sign up'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('3.1  Sign up'));
    await tester.pumpAndSettle();
    expect(find.byType(SignUpScreen), findsOneWidget);
  });
}
