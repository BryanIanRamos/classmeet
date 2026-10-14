import 'package:classmeet/core/router/routes.dart';
import 'package:classmeet/shared/widgets/dispose.logger.dart';
import 'package:classmeet/shared/widgets/placeholder.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DisposeLogger(
      name: 'Welcome',
      child: Scaffold(
        body: PlaceholderBody(
          title: 'Welcome to ClassMeet',
          actions: [
            FilledButton(
              onPressed: () => context.go(Routes.signup),
              child: Text("Get Started"),
            ),
            TextButton(
              onPressed: () => context.go(Routes.login),
              child: const Text('I already have and account'),
            ),
          ],
        ),
      ),
    );
  }
}
