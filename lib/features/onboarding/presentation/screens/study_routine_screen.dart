import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/router/routes.dart';
import '../../../../core/router/screen_placeholder.dart';
import '../../../auth/application/session_controller.dart';

/// Your study routine (frame 99). Placeholder until task 4.6 builds it.
class StudyRoutineScreen extends StatelessWidget {
  const StudyRoutineScreen({super.key});

  static void _finishOnboarding(WidgetRef ref) =>
      ref.read(sessionProvider.notifier).finishOnboarding();

  @override
  Widget build(BuildContext context) {
    return const ScreenPlaceholder(
      title: 'Your study routine',
      frame: '99',
      task: '4.6',
      links: [
        PlaceholderLink(
          'Continue',
          Routes.home,
          replace: true,
          action: _finishOnboarding,
        ),
      ],
    );
  }
}
