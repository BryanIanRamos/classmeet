import 'package:flutter/material.dart';

import '../../../../core/router/routes.dart';
import '../../../../core/router/screen_placeholder.dart';

/// Let's play! (frame 122). Placeholder until task 8.1–8.2 builds it.
class PlayHubScreen extends StatelessWidget {
  const PlayHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenPlaceholder(
      title: "Let's play!",
      frame: '122',
      task: '8.1–8.2',
      links: [
        PlaceholderLink('Play now', Routes.quizSetup('intro-computing')),
        const PlaceholderLink('Quiz Battle', Routes.quizBattle),
        const PlaceholderLink('My quizzes', Routes.myQuizzes),
        const PlaceholderLink('Mistake Bank', Routes.mistakeBank),
      ],
    );
  }
}
