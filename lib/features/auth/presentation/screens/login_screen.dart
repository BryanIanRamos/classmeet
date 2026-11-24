import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/router/routes.dart';
import '../../../../core/router/screen_placeholder.dart';
import '../../../auth/application/session_controller.dart';

/// Log in (frame GAP-01). Placeholder until task 4.2 builds it.
class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  static void _signedIn(WidgetRef ref) =>
      ref.read(sessionProvider.notifier).signedIn();

  @override
  Widget build(BuildContext context) {
    return const ScreenPlaceholder(
      title: 'Log in',
      frame: 'GAP-01',
      task: '4.2',
      links: [
        PlaceholderLink(
          'Log in',
          Routes.home,
          replace: true,
          action: _signedIn,
        ),
        PlaceholderLink('Forgot password', Routes.forgotPassword),
      ],
    );
  }
}
