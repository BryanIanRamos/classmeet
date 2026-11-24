import 'package:classmeet/data/fakes/fake_config.dart';
import 'package:classmeet/data/providers.dart';
import 'package:classmeet/features/auth/presentation/screens/forgot_password_screen.dart';
import 'package:classmeet/features/auth/presentation/screens/login_screen.dart';
import 'package:classmeet/features/auth/presentation/screens/sign_up_screen.dart';
import 'package:flutter_test/flutter_test.dart';

import 'render_harness.dart';

void main() {
  final overrides = [fakeConfigProvider.overrideWithValue(FakeConfig.instant)];

  testWidgets('3.1 sign up', (tester) async {
    await renderScreen(
      tester,
      'onboarding/3.1_sign_up',
      const SignUpScreen(),
      overrides: overrides,
    );
  });

  testWidgets('GAP-01 log in', (tester) async {
    await renderScreen(
      tester,
      'onboarding/GAP-01_login',
      const LoginScreen(),
      overrides: overrides,
    );
  });

  testWidgets('GAP-02 forgot password', (tester) async {
    await renderScreen(
      tester,
      'onboarding/GAP-02_forgot_password',
      const ForgotPasswordScreen(),
      overrides: overrides,
    );
  });
}
