import 'package:flutter/material.dart';

import '../../../../core/router/screen_placeholder.dart';

/// Downloads (frame 90). Placeholder until task 6.9 builds it.
class DownloadsScreen extends StatelessWidget {
  const DownloadsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ScreenPlaceholder(
      title: 'Downloads',
      frame: '90',
      task: '6.9',
    );
  }
}
