import 'package:classmeet/core/router/routes.dart';
import 'package:classmeet/core/session/app_session.dart';
import 'package:classmeet/shared/widgets/dispose.logger.dart';
import 'package:classmeet/shared/widgets/placeholder.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  void _onLogin(BuildContext context) {
    appSession.logIn();
    context.go(Routes.setProfile);
  }

  @override
  Widget build(BuildContext context) {
    return DisposeLogger(
      name: 'Login',
      child: Scaffold(
        appBar: AppBar(title: const Text('Log in')),
        body: PlaceholderBody(
          title: 'Login',
          actions: [
            FilledButton(
              onPressed: () => _onLogin(context),
              child: const Text("Log in"),
            ),
            TextButton(
              onPressed: () => context.go(Routes.signup),
              child: const Text("Don't have an account? Sign up."),
            ),
          ],
        ),
      ),
    );
  }
}
