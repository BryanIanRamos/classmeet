import 'package:flutter/material.dart';

import '../../../../core/router/routes.dart';
import '../../../../core/router/screen_placeholder.dart';

/// Create quiz: customize (frame 115). Placeholder until task 7.5 builds it.
class QuizCustomizeScreen extends StatelessWidget {
  const QuizCustomizeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ScreenPlaceholder(
      title: 'Create quiz: customize',
      frame: '115',
      task: '7.5',
      links: [PlaceholderLink('Continue', Routes.quizPreview)],
    );
  }
}
