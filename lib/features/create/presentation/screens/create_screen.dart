import 'package:flutter/material.dart';

import '../../../../core/router/routes.dart';
import '../../../../core/router/screen_placeholder.dart';

/// Create (frame 121). Placeholder until task 7.2 builds it.
class CreateScreen extends StatelessWidget {
  const CreateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenPlaceholder(
      title: 'Create',
      frame: '121',
      task: '7.2',
      links: [
        const PlaceholderLink('Quizzes', Routes.quizSource),
        PlaceholderLink('Flashcards', Routes.createTool('flashcards')),
      ],
    );
  }
}
