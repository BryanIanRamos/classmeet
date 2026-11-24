import 'package:classmeet/features/onboarding/presentation/screens/splash_screen.dart';
import 'package:classmeet/features/onboarding/presentation/screens/welcome_screen.dart';
import 'package:flutter_test/flutter_test.dart';

import 'render_harness.dart';

void main() {
  testWidgets('renders 94 splash', (tester) async {
    await renderScreen(
      tester,
      'onboarding/94_splash_welcome',
      const SplashScreen(),
    );
  });

  testWidgets('renders 95 welcome', (tester) async {
    await renderScreen(
      tester,
      'onboarding/95_welcome_auth_choice',
      const WelcomeScreen(),
    );
  });
}
