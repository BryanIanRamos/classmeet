import 'package:flutter/material.dart';

import '../../../../core/widgets/feedback/coming_soon_screen.dart';

/// Friends: not designed yet (GAP-06), so it shows [ComingSoonScreen] (the Friends tab root).
class FriendsScreen extends StatelessWidget {
  const FriendsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ComingSoonScreen(
      title: 'Friends',
      gapId: 'GAP-06',
      showBack: false,
    );
  }
}
