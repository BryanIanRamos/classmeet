import 'package:classmeet/core/router/routes.dart';
import 'package:classmeet/shared/widgets/dispose.logger.dart';
import 'package:classmeet/shared/widgets/placeholder.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class StudyStyleScreen extends StatelessWidget {
  const StudyStyleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DisposeLogger(
      name: 'Study Style',
      child: Scaffold(
        appBar: AppBar(title: const Text('Study Style & Exam')),
        body: PlaceholderBody(
          title: 'Study Style and Exam (3/4)',
          actions: [
            FilledButton(
              onPressed: () => context.push(Routes.privacyConsent),
              child: const Text('Next'),
            ),
          ],
        ),
      ),
    );
  }
}
