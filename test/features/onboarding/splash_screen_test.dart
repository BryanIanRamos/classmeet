import 'package:classmeet/app.dart';
import 'package:classmeet/features/auth/application/session_controller.dart';
import 'package:classmeet/features/onboarding/presentation/screens/splash_screen.dart';
import 'package:classmeet/features/onboarding/presentation/screens/welcome_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> pumpSignedOut(WidgetTester tester, Size size) async {
  tester.view
    ..devicePixelRatio = 1
    ..physicalSize = size;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        initialSessionStatusProvider.overrideWithValue(SessionStatus.signedOut),
      ],
      child: const ClassMeetApp(),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  group('SplashScreen', () {
    testWidgets('shows the pitch and opens the welcome choice', (tester) async {
      await pumpSignedOut(tester, const Size(428, 870));
      expect(find.byType(SplashScreen), findsOneWidget);
      expect(find.text('A little wiser every day.'), findsOneWidget);
      expect(find.textContaining('quick quizzes'), findsOneWidget);

      await tester.ensureVisible(find.text('Get started'));
      await tester.tap(find.text('Get started'));
      await tester.pumpAndSettle();
      expect(find.byType(WelcomeScreen), findsOneWidget);
    });

    for (final size in const [Size(428, 870), Size(360, 800)]) {
      testWidgets('does not overflow at ${size.width}dp', (tester) async {
        await pumpSignedOut(tester, size);
        expect(tester.takeException(), isNull);
        expect(find.text('Get started'), findsOneWidget);
      });
    }
  });
}
