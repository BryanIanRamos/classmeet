import 'package:flutter/material.dart';

import '../../../../core/router/routes.dart';
import '../../../../core/router/screen_placeholder.dart';

/// Create quiz: preview (frame 116). Placeholder until task 7.4 builds it.
class QuizPreviewScreen extends StatelessWidget {
  const QuizPreviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ScreenPlaceholder(
      title: 'Create quiz: preview',
      frame: '116',
      task: '7.4',
      links: [PlaceholderLink('Continue', Routes.quizGenerating)],
    );
  }
}
