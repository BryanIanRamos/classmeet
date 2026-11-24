import 'package:flutter/material.dart';

import '../../../../core/router/routes.dart';
import '../../../../core/router/screen_placeholder.dart';

/// Welcome (frame 94). Placeholder until task 4.1 builds it.
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ScreenPlaceholder(
      title: 'Welcome',
      frame: '94',
      task: '4.1',
      links: [PlaceholderLink('Get started', Routes.welcome)],
    );
  }
}
