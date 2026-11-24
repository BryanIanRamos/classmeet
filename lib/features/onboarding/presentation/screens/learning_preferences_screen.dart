import 'package:flutter/material.dart';

import '../../../../core/router/routes.dart';
import '../../../../core/router/screen_placeholder.dart';

/// Your learning preferences (frame 98). Placeholder until task 4.5 builds it.
class LearningPreferencesScreen extends StatelessWidget {
  const LearningPreferencesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ScreenPlaceholder(
      title: 'Your learning preferences',
      frame: '98',
      task: '4.5',
      links: [PlaceholderLink('Continue', Routes.onboardingRoutine)],
    );
  }
}
