import 'package:flutter/material.dart';

import '../../../../core/router/routes.dart';
import '../../../../core/router/screen_placeholder.dart';

/// Home (frame 8). Placeholder until task 5.1–5.2 builds it.
class HomeDashboardScreen extends StatelessWidget {
  const HomeDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ScreenPlaceholder(
      title: 'Home',
      frame: '8',
      task: '5.1–5.2',
      links: [
        PlaceholderLink('Notifications', Routes.notifications),
        PlaceholderLink('Search', Routes.search),
        PlaceholderLink('Join a class', Routes.joinClass),
        PlaceholderLink('Talon credits', Routes.talonCredits),
        PlaceholderLink('Daily GK quiz', Routes.dailyQuiz),
        PlaceholderLink('Weekly survey', Routes.weeklySurvey),
        PlaceholderLink('View streak', Routes.streak),
        PlaceholderLink('View study plan', Routes.studyPlan),
        PlaceholderLink('Profile', Routes.profile),
      ],
    );
  }
}
