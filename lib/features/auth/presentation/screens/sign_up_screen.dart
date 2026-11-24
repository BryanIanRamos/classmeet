import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/router/routes.dart';
import '../../../../core/router/screen_placeholder.dart';
import '../../../auth/application/session_controller.dart';

/// Create account (frame 3.1, 3.2). Placeholder until task 4.2 builds it.
class SignUpScreen extends StatelessWidget {
  const SignUpScreen({super.key});

  static void _signedUp(WidgetRef ref) =>
      ref.read(sessionProvider.notifier).signedUp();

  @override
  Widget build(BuildContext context) {
    return const ScreenPlaceholder(
      title: 'Create account',
      frame: '3.1, 3.2',
      task: '4.2',
      links: [
        PlaceholderLink(
          'Continue',
          Routes.onboardingAcademic,
          replace: true,
          action: _signedUp,
        ),
        PlaceholderLink('Continue with Carsu', Routes.carsuSignIn),
        PlaceholderLink('Terms', Routes.terms),
        PlaceholderLink('Privacy Policy', Routes.privacy),
      ],
    );
  }
}
