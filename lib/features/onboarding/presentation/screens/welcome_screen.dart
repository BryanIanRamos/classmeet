import 'package:flutter/material.dart';

import '../../../../core/router/routes.dart';
import '../../../../core/router/screen_placeholder.dart';

/// Get started (frame 95). Placeholder until task 4.1 builds it.
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ScreenPlaceholder(
      title: 'Get started',
      frame: '95',
      task: '4.1',
      links: [
        PlaceholderLink('Get started', Routes.signUp),
        PlaceholderLink('Continue with Carsu', Routes.carsuSignIn),
        PlaceholderLink('Log in', Routes.login),
      ],
    );
  }
}
