import 'package:flutter/material.dart';

import '../../../../core/widgets/feedback/coming_soon_screen.dart';

/// Profile: not designed yet (GAP-07), so it shows [ComingSoonScreen] (opened from the avatar; 9.2 adds placeholder rows).
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ComingSoonScreen(title: 'Profile', gapId: 'GAP-07');
  }
}
