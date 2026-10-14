import 'package:classmeet/core/router/routes.dart';
import 'package:classmeet/core/session/app_session.dart';
import 'package:classmeet/shared/widgets/dispose.logger.dart';
import 'package:classmeet/shared/widgets/placeholder.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SignupScreen extends StatelessWidget {
  const SignupScreen({super.key});

  void _onSignup(BuildContext context) {
    appSession.logIn();
    context.go(Routes.setProfile);
  }

  @override
  Widget build(BuildContext context) {
    return DisposeLogger(
      name: 'Signup',
      child: Scaffold(
        appBar: AppBar(title: const Text('Sign up')),
        body: PlaceholderBody(
          title: 'Signup',
          actions: [
            FilledButton(
              onPressed: () => _onSignup(context),
              child: const Text("Create Account"),
            ),
            TextButton(
              onPressed: () => context.go(Routes.login),
              child: const Text('Already have an account? Log in'),
            ),
          ],
        ),
      ),
    );
  }
}
