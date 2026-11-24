import 'package:flutter/material.dart';

import '../../../../core/router/routes.dart';
import '../../../../core/router/screen_placeholder.dart';

/// Talon credits (frame 14). Placeholder until task 5.6 builds it.
class TalonCreditsScreen extends StatelessWidget {
  const TalonCreditsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ScreenPlaceholder(
      title: 'Talon credits',
      frame: '14',
      task: '5.6',
      links: [
        PlaceholderLink('View rewards history', Routes.rewardsHistory),
        PlaceholderLink('Answer survey', Routes.weeklySurvey),
      ],
    );
  }
}
