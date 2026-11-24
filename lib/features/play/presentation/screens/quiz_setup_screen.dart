import 'package:flutter/material.dart';

import '../../../../core/router/routes.dart';
import '../../../../core/router/screen_placeholder.dart';

/// Quiz setup (frame 123). Placeholder until task 8.3 builds it.
class QuizSetupScreen extends StatelessWidget {
  const QuizSetupScreen({super.key, required this.quizId});

  final String quizId;

  @override
  Widget build(BuildContext context) {
    return ScreenPlaceholder(
      title: 'Quiz setup',
      frame: '123',
      task: '8.3',
      details: ['quizId: $quizId'],
      links: [PlaceholderLink('Start playing', Routes.question('attempt-1'))],
    );
  }
}
