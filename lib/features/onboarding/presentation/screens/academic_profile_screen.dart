import 'package:flutter/material.dart';

import '../../../../core/router/routes.dart';
import '../../../../core/router/screen_placeholder.dart';

/// Your academic profile (frame 96). Placeholder until task 4.3 builds it.
class AcademicProfileScreen extends StatelessWidget {
  const AcademicProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ScreenPlaceholder(
      title: 'Your academic profile',
      frame: '96',
      task: '4.3',
      links: [PlaceholderLink('Continue', Routes.onboardingSubjects)],
    );
  }
}
