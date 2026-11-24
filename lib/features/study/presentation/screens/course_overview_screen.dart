import 'package:flutter/material.dart';

import '../../../../core/router/routes.dart';
import '../../../../core/router/screen_placeholder.dart';

/// Course overview (frame 85). Placeholder until task 6.2 builds it.
class CourseOverviewScreen extends StatelessWidget {
  const CourseOverviewScreen({super.key, required this.courseId});

  final String courseId;

  @override
  Widget build(BuildContext context) {
    return ScreenPlaceholder(
      title: 'Course overview',
      frame: '85',
      task: '6.2',
      details: ['courseId: $courseId'],
      links: [
        const PlaceholderLink('Add reviewer', Routes.addReviewer),
        PlaceholderLink('Week 1: Computer Basics', Routes.reader('week-1')),
      ],
    );
  }
}
