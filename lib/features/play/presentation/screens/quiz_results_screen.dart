import 'package:flutter/material.dart';

import '../../../../core/router/routes.dart';
import '../../../../core/router/screen_placeholder.dart';

/// Results (frame 132, 133). Placeholder until task 8.7–8.8 builds it.
class QuizResultsScreen extends StatelessWidget {
  const QuizResultsScreen({super.key, required this.attemptId});

  final String attemptId;

  @override
  Widget build(BuildContext context) {
    return ScreenPlaceholder(
      title: 'Results',
      frame: '132, 133',
      task: '8.7–8.8',
      details: ['attemptId: $attemptId'],
      links: const [
        PlaceholderLink('Review missed', Routes.mistakeBank),
        PlaceholderLink('Class leaderboard', Routes.leaderboard),
        PlaceholderLink('Done', Routes.play, replace: true),
      ],
    );
  }
}
