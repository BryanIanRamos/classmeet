import 'package:classmeet/app.dart';
import 'package:classmeet/core/dev/frames.dart';
import 'package:classmeet/core/router/app_router.dart';
import 'package:classmeet/core/router/not_found_screen.dart';
import 'package:classmeet/features/auth/application/session_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('the registry holds the 43 Figma frames, each once', () {
    expect(devFrames, hasLength(43));
    expect(devFrames.map((f) => f.figmaId).toSet(), hasLength(43));
    expect(devFrames.map((f) => f.number).toSet(), hasLength(43));
    expect(devFrames.map((f) => f.slug).toSet(), hasLength(43));
  });

  test('state and sheet become query parameters', () {
    String locationOf(String number) =>
        devFrames.firstWhere((f) => f.number == number).location;
    expect(locationOf('3.2'), '/signup?state=focused');
    expect(locationOf('88'), '/study/reader/week-1?tab=visual');
    expect(locationOf('91'), '/study/reader/week-1?sheet=explain');
    expect(locationOf('119'), '/study?sheet=create');
    expect(locationOf('126'), '/play/run/attempt-1?state=revealed');
    expect(locationOf('133'), '/play/results/attempt-1?sheet=ranking-privacy');
    expect(locationOf('93'), '/study?tab=classes');
  });

  testWidgets('every frame location opens a screen', (tester) async {
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
    for (final frame in devFrames) {
      container.read(routerProvider).go(frame.location);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull, reason: frame.location);
      expect(find.byType(NotFoundScreen), findsNothing, reason: frame.location);
    }
  });
}
