import 'package:classmeet/core/router/routes.dart';
import 'package:classmeet/shared/widgets/dispose.logger.dart';
import 'package:classmeet/shared/widgets/placeholder.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SetPickSubjectScreen extends StatelessWidget {
  const SetPickSubjectScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DisposeLogger(
      name: 'StudyStyle',
      child: Scaffold(
        appBar: AppBar(title: Text('Study Style')),
        body: PlaceholderBody(
          title: 'Study Style',
          actions: [
            FilledButton(
              onPressed: () => context.push(Routes.studyStyle),
              child: const Text('Next'),
            ),
          ],
        ),
      ),
    );
  }
}
