import 'package:flutter/material.dart';

import '../../../../core/router/routes.dart';
import '../../../../core/router/screen_placeholder.dart';

/// Your study subjects (frame 97). Placeholder until task 4.4 builds it.
class StudySubjectsScreen extends StatelessWidget {
  const StudySubjectsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ScreenPlaceholder(
      title: 'Your study subjects',
      frame: '97',
      task: '4.4',
      links: [PlaceholderLink('Continue', Routes.onboardingPreferences)],
    );
  }
}
