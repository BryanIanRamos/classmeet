import 'package:flutter/material.dart';

import '../../../../core/router/routes.dart';
import '../../../../core/router/screen_placeholder.dart';

/// Create quiz: source (frame 114). Placeholder until task 7.4 builds it.
class QuizSourceScreen extends StatelessWidget {
  const QuizSourceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ScreenPlaceholder(
      title: 'Create quiz: source',
      frame: '114',
      task: '7.4',
      links: [PlaceholderLink('Continue', Routes.quizCustomize)],
    );
  }
}
