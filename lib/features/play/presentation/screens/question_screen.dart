import 'package:flutter/material.dart';

import '../../../../core/router/routes.dart';
import '../../../../core/router/screen_placeholder.dart';

/// Question (frame 124, 125, 126, 128, 129). Placeholder until task 8.4–8.6 builds it.
class QuestionScreen extends StatelessWidget {
  const QuestionScreen({super.key, required this.attemptId});

  final String attemptId;

  @override
  Widget build(BuildContext context) {
    return ScreenPlaceholder(
      title: 'Question',
      frame: '124, 125, 126, 128, 129',
      task: '8.4–8.6',
      details: ['attemptId: $attemptId'],
      links: [
        PlaceholderLink(
          'Finish',
          Routes.quizResults('attempt-1'),
          replace: true,
        ),
      ],
    );
  }
}
