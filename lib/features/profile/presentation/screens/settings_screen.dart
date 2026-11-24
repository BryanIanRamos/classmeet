import 'package:flutter/material.dart';

import '../../../../core/widgets/feedback/coming_soon_screen.dart';

/// Settings: not designed yet (GAP-07), so it shows [ComingSoonScreen] (9.2).
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ComingSoonScreen(title: 'Settings', gapId: 'GAP-07');
  }
}
