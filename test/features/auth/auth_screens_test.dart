import 'dart:async';

import 'package:classmeet/app.dart';
import 'package:classmeet/core/assets/app_icons.dart';
import 'package:classmeet/core/router/app_router.dart';
import 'package:classmeet/core/router/routes.dart';
import 'package:classmeet/core/widgets/buttons/app_button.dart';
import 'package:classmeet/core/widgets/feedback/app_alert.dart';
import 'package:classmeet/core/widgets/inputs/app_text_field.dart';
import 'package:classmeet/data/fakes/fake_config.dart';
import 'package:classmeet/data/providers.dart';
import 'package:classmeet/features/auth/application/session_controller.dart';
import 'package:classmeet/features/auth/presentation/screens/forgot_password_screen.dart';
import 'package:classmeet/features/auth/presentation/screens/login_screen.dart';
import 'package:classmeet/features/auth/presentation/screens/sign_up_screen.dart';
import 'package:classmeet/features/home/presentation/screens/home_dashboard_screen.dart';
import 'package:classmeet/features/onboarding/presentation/screens/academic_profile_screen.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

const _errorConfig = FakeConfig(
  scenario: FakeScenario.error,
  latency: Duration.zero,
);

/// Opens the app signed out, then goes to [route] (pushed on top of the
/// welcome screen, so Back works).
Future<ProviderContainer> pumpAuth(
  WidgetTester tester,
  String route, {
  FakeConfig config = FakeConfig.instant,
  Size size = const Size(428, 926),
}) async {
  await tester.binding.setSurfaceSize(size);
  addTearDown(() => tester.binding.setSurfaceSize(null));
  final container = ProviderContainer(
    overrides: [
      fakeConfigProvider.overrideWithValue(config),
      initialSessionStatusProvider.overrideWithValue(SessionStatus.signedOut),
    ],
    retry: (_, _) => null,
  );
  addTearDown(container.dispose);
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: const ClassMeetApp(),
    ),
  );
  await tester.pumpAndSettle();
  unawaited(container.read(routerProvider).push(route));
  await tester.pumpAndSettle();
  return container;
}

Future<void> type(WidgetTester tester, String placeholder, String text) async {
  final input = find.descendant(
    of: find.byWidgetPredicate(
      (w) => w is AppTextField && w.placeholder == placeholder,
    ),
    matching: find.byType(EditableText),
  );
  await tester.enterText(input, text);
  await tester.pump();
}

AppButton button(WidgetTester tester, String label) =>
    tester.widget<AppButton>(find.widgetWithText(AppButton, label));

Future<void> tapSpan(WidgetTester tester, String text) async {
  final rich = find.byWidgetPredicate(
    (w) => w is RichText && w.text.toPlainText().contains(text),
  );
  final target = tester.widget<RichText>(rich.first);
  void visit(InlineSpan span) {
    if (span is TextSpan) {
      if (span.text == text && span.recognizer is TapGestureRecognizer) {
        (span.recognizer! as TapGestureRecognizer).onTap!();
      }
      span.children?.forEach(visit);
    }
  }

  visit(target.text);
  await tester.pumpAndSettle();
}

String location(ProviderContainer c) => c
    .read(routerProvider)
    .routerDelegate
    .currentConfiguration
    .last
    .matchedLocation;

void main() {
  group('sign up', () {
    testWidgets('shows the design copy with a Username field (D-19)', (
      tester,
    ) async {
      await pumpAuth(tester, Routes.signUp);
      expect(find.byType(SignUpScreen), findsOneWidget);
      expect(find.text('Create account'), findsOneWidget);
      expect(
        find.text('Sign up to get you ready for your next study session.'),
        findsOneWidget,
      );
      expect(find.text('Username'), findsOneWidget);
      expect(find.text('Full name'), findsNothing);
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
      expect(find.text('Or'), findsOneWidget);
      expect(
        find.text(
          'Use your school account to easily find your peers in '
          'seconds.',
        ),
        findsOneWidget,
      );
      expect(find.text('Continue with Carsu'), findsOneWidget);
      expect(
        find.textContaining('By signing up you agree to the'),
        findsOneWidget,
      );
    });

    testWidgets('Continue waits until all three fields are filled', (
      tester,
    ) async {
      await pumpAuth(tester, Routes.signUp);
      expect(button(tester, 'Continue').onPressed, isNull);
      await type(tester, 'Username', 'ollie');
      await type(tester, 'Email', 'ollie@example.com');
      expect(button(tester, 'Continue').onPressed, isNull);
      await type(tester, 'Password', 'secret123');
      expect(button(tester, 'Continue').onPressed, isNotNull);
    });

    testWidgets('a submit shows the validation errors', (tester) async {
      await pumpAuth(tester, Routes.signUp);
      await type(tester, 'Username', 'ab');
      await type(tester, 'Email', 'nope');
      await type(tester, 'Password', 'short');
      await tester.tap(find.widgetWithText(AppButton, 'Continue'));
      await tester.pumpAndSettle();
      expect(find.text('Username needs at least 3 characters'), findsOneWidget);
      expect(find.text('Enter a valid email address'), findsOneWidget);
      expect(find.text('Password needs at least 8 characters'), findsOneWidget);
      expect(find.byType(SignUpScreen), findsOneWidget);
    });

    testWidgets('success: onboarding session, step 96 with no back', (
      tester,
    ) async {
      final container = await pumpAuth(tester, Routes.signUp);
      await type(tester, 'Username', 'ollie');
      await type(tester, 'Email', 'ollie@example.com');
      await type(tester, 'Password', 'secret123');
      await tester.tap(find.widgetWithText(AppButton, 'Continue'));
      await tester.pumpAndSettle();
      expect(container.read(sessionProvider), SessionStatus.onboarding);
      expect(find.byType(AcademicProfileScreen), findsOneWidget);
      expect(location(container), Routes.onboardingAcademic);
      expect(find.byIcon(AppIcons.chevronLeft), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('error scenario: alert above the button, stays here', (
      tester,
    ) async {
      final container = await pumpAuth(
        tester,
        Routes.signUp,
        config: _errorConfig,
      );
      await type(tester, 'Username', 'ollie');
      await type(tester, 'Email', 'ollie@example.com');
      await type(tester, 'Password', 'secret123');
      await tester.tap(find.widgetWithText(AppButton, 'Continue'));
      await tester.pumpAndSettle();
      expect(find.byType(AppAlert), findsOneWidget);
      expect(find.text('Could not create your account'), findsOneWidget);
      expect(find.byType(SignUpScreen), findsOneWidget);
      expect(container.read(sessionProvider), SessionStatus.signedOut);
      expect(button(tester, 'Continue').onPressed, isNotNull);
    });

    testWidgets('Carsu, Terms and Privacy open their placeholders', (
      tester,
    ) async {
      final container = await pumpAuth(tester, Routes.signUp);
      await tester.tap(find.widgetWithText(AppButton, 'Continue with Carsu'));
      await tester.pumpAndSettle();
      expect(location(container), Routes.carsuSignIn);
      container.read(routerProvider).pop();
      await tester.pumpAndSettle();
      await tapSpan(tester, 'Terms');
      expect(location(container), Routes.terms);
      container.read(routerProvider).pop();
      await tester.pumpAndSettle();
      await tapSpan(tester, 'Privacy Policy');
      expect(location(container), Routes.privacy);
    });

    testWidgets('back returns to the previous screen', (tester) async {
      await pumpAuth(tester, Routes.signUp);
      await tester.tap(find.byIcon(AppIcons.chevronLeft).first);
      await tester.pumpAndSettle();
      expect(find.byType(SignUpScreen), findsNothing);
    });
  });

  group('log in', () {
    testWidgets('success goes Home with the session ready', (tester) async {
      final container = await pumpAuth(tester, Routes.login);
      expect(find.text('Log in'), findsWidgets);
      expect(button(tester, 'Log in').onPressed, isNull);
      await type(tester, 'Email', 'ollie@example.com');
      await type(tester, 'Password', 'secret123');
      await tester.tap(find.widgetWithText(AppButton, 'Log in'));
      await tester.pumpAndSettle();
      expect(container.read(sessionProvider), SessionStatus.ready);
      expect(find.byType(HomeDashboardScreen), findsOneWidget);
    });

    testWidgets('an invalid email shows an error', (tester) async {
      await pumpAuth(tester, Routes.login);
      await type(tester, 'Email', 'nope');
      await type(tester, 'Password', 'secret123');
      await tester.tap(find.widgetWithText(AppButton, 'Log in'));
      await tester.pumpAndSettle();
      expect(find.text('Enter a valid email address'), findsOneWidget);
      expect(find.byType(LoginScreen), findsOneWidget);
    });

    testWidgets('error scenario shows the alert', (tester) async {
      final container = await pumpAuth(
        tester,
        Routes.login,
        config: _errorConfig,
      );
      await type(tester, 'Email', 'ollie@example.com');
      await type(tester, 'Password', 'secret123');
      await tester.tap(find.widgetWithText(AppButton, 'Log in'));
      await tester.pumpAndSettle();
      expect(find.text('Could not log you in'), findsOneWidget);
      expect(container.read(sessionProvider), SessionStatus.signedOut);
    });

    testWidgets('the forgot link opens Forgot password', (tester) async {
      final container = await pumpAuth(tester, Routes.login);
      await tapSpan(tester, 'Forgot password?');
      expect(location(container), Routes.forgotPassword);
      expect(find.byType(ForgotPasswordScreen), findsOneWidget);
    });
  });

  group('forgot password', () {
    testWidgets('success alert, the user stays', (tester) async {
      await pumpAuth(tester, Routes.forgotPassword);
      expect(button(tester, 'Send reset link').onPressed, isNull);
      await type(tester, 'Email', 'ollie@example.com');
      await tester.tap(find.widgetWithText(AppButton, 'Send reset link'));
      await tester.pumpAndSettle();
      expect(find.text('Check your email'), findsOneWidget);
      expect(find.byType(ForgotPasswordScreen), findsOneWidget);
    });

    testWidgets('error scenario shows the alert', (tester) async {
      await pumpAuth(tester, Routes.forgotPassword, config: _errorConfig);
      await type(tester, 'Email', 'ollie@example.com');
      await tester.tap(find.widgetWithText(AppButton, 'Send reset link'));
      await tester.pumpAndSettle();
      expect(find.text('Could not send the link'), findsOneWidget);
      expect(find.text('Check your email'), findsNothing);
    });
  });

  group('no overflow', () {
    for (final route in [Routes.signUp, Routes.login, Routes.forgotPassword]) {
      for (final size in const [Size(360, 800), Size(428, 926)]) {
        testWidgets('$route at ${size.width.toInt()}dp', (tester) async {
          await pumpAuth(tester, route, size: size);
          expect(tester.takeException(), isNull);
        });
      }
    }

    testWidgets('sign up scrolls with the keyboard area', (tester) async {
      await pumpAuth(tester, Routes.signUp, size: const Size(360, 800));
      tester.view.viewInsets = const FakeViewPadding(bottom: 600);
      addTearDown(tester.view.resetViewInsets);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await tester.drag(find.byType(CustomScrollView), const Offset(0, -300));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  });
}
