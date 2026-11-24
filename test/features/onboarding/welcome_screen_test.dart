import 'package:classmeet/app.dart';
import 'package:classmeet/core/widgets/feedback/coming_soon_screen.dart';
import 'package:classmeet/features/auth/application/session_controller.dart';
import 'package:classmeet/features/auth/presentation/screens/login_screen.dart';
import 'package:classmeet/features/auth/presentation/screens/sign_up_screen.dart';
import 'package:classmeet/features/onboarding/presentation/screens/welcome_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> pumpWelcome(WidgetTester tester, Size size) async {
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
  await tester.ensureVisible(find.text('Get started'));
  await tester.tap(find.text('Get started'));
  await tester.pumpAndSettle();
  expect(find.byType(WelcomeScreen), findsOneWidget);
}

void main() {
  testWidgets('shows the headline and the three actions', (tester) async {
    await pumpWelcome(tester, const Size(428, 870));
    expect(find.text('Your learning adventure starts here!'), findsOneWidget);
    expect(find.text('Get started'), findsOneWidget);
    expect(find.text('Or'), findsOneWidget);
    expect(find.text('Continue with Carsu'), findsOneWidget);
    expect(find.textContaining('Already have an account?'), findsOneWidget);
  });

  testWidgets('Get started opens sign up', (tester) async {
    await pumpWelcome(tester, const Size(428, 870));
    await tester.ensureVisible(find.text('Get started'));
    await tester.tap(find.text('Get started'));
    await tester.pumpAndSettle();
    expect(find.byType(SignUpScreen), findsOneWidget);
  });

  testWidgets('Continue with Carsu opens the coming-soon screen', (
    tester,
  ) async {
    await pumpWelcome(tester, const Size(428, 870));
    await tester.ensureVisible(find.text('Continue with Carsu'));
    await tester.tap(find.text('Continue with Carsu'));
    await tester.pumpAndSettle();
    expect(find.byType(ComingSoonScreen), findsOneWidget);
  });

  testWidgets('Log In opens the login screen', (tester) async {
    await pumpWelcome(tester, const Size(428, 870));
    await tester.ensureVisible(find.textContaining('Already have'));
    await tester.pumpAndSettle();
    await tester.tapOnText(find.textRange.ofSubstring('Log In'));
    await tester.pumpAndSettle();
    expect(find.byType(LoginScreen), findsOneWidget);
  });

  for (final size in const [Size(428, 870), Size(360, 800)]) {
    testWidgets('does not overflow at ${size.width}dp', (tester) async {
      await pumpWelcome(tester, size);
      expect(tester.takeException(), isNull);
      expect(find.text('Continue with Carsu'), findsOneWidget);
    });
  }
}
