import 'package:flutter/material.dart';

import '../../../../core/router/routes.dart';
import '../../../../core/router/screen_placeholder.dart';

/// Study (frame 92, 93). Placeholder until task 6.1–6.2 builds it.
class StudyScreen extends StatelessWidget {
  const StudyScreen({super.key, this.tab});

  final String? tab;

  @override
  Widget build(BuildContext context) {
    return ScreenPlaceholder(
      title: 'Study',
      frame: '92, 93',
      task: '6.1–6.2',
      details: ['tab: $tab'],
      links: [
        const PlaceholderLink('My Classes', Routes.studyClasses, replace: true),
        const PlaceholderLink('Create material', Routes.create),
        PlaceholderLink('Course overview', Routes.course('ite13')),
        PlaceholderLink('Reviewer', Routes.reader('week-1')),
        const PlaceholderLink('Downloads', Routes.downloads),
        PlaceholderLink('Browse flashcards', Routes.studyTool('flashcards')),
      ],
    );
  }
}
