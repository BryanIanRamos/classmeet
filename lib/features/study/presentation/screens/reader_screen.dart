import 'package:flutter/material.dart';

import '../../../../core/router/screen_placeholder.dart';

/// Reader (frame 87, 88, 89, 91). Placeholder until task 6.5–6.8 builds it.
class ReaderScreen extends StatelessWidget {
  const ReaderScreen({super.key, required this.materialId, this.tab});

  final String materialId;
  final String? tab;

  @override
  Widget build(BuildContext context) {
    return ScreenPlaceholder(
      title: 'Reader',
      frame: '87, 88, 89, 91',
      task: '6.5–6.8',
      details: ['materialId: $materialId', 'tab: $tab'],
    );
  }
}
