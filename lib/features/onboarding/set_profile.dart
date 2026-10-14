import 'package:classmeet/core/router/routes.dart';
import 'package:classmeet/shared/widgets/dispose.logger.dart';
import 'package:classmeet/shared/widgets/placeholder.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SetProfileScreen extends StatelessWidget {
  const SetProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DisposeLogger(
      name: 'SetProfile',
      child: Scaffold(
        appBar: AppBar(title: const Text('Set up your profile')),
        body: PlaceholderBody(
          title: 'Set Profile 1/4',
          actions: [
            FilledButton(
              onPressed: () => context.push(Routes.pickSubject),
              child: const Text('Next'),
            ),
          ],
        ),
      ),
    );
  }
}
