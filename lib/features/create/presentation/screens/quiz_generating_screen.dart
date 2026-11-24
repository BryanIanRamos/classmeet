import 'package:flutter/material.dart';

import '../../../../core/router/routes.dart';
import '../../../../core/router/screen_placeholder.dart';

/// Generating quiz (frame 117). Placeholder until task 7.6 builds it.
class QuizGeneratingScreen extends StatelessWidget {
  const QuizGeneratingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ScreenPlaceholder(
      title: 'Generating quiz',
      frame: '117',
      task: '7.6',
      links: [PlaceholderLink('Done', Routes.quizReady, replace: true)],
    );
  }
}
