import 'package:flutter/material.dart';

import '../../../../core/router/routes.dart';
import '../../../../core/router/screen_placeholder.dart';

/// Quiz ready (frame 118). Placeholder until task 7.6 builds it.
class QuizReadyScreen extends StatelessWidget {
  const QuizReadyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenPlaceholder(
      title: 'Quiz ready',
      frame: '118',
      task: '7.6',
      links: [
        PlaceholderLink(
          'Take quiz now',
          Routes.quizSetup('intro-computing'),
          replace: true,
        ),
        const PlaceholderLink(
          'Create another quiz',
          Routes.quizSource,
          replace: true,
        ),
      ],
    );
  }
}
