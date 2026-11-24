import 'package:flutter/material.dart';

import '../../../../core/router/screen_placeholder.dart';

/// Forgot password (frame GAP-02). Placeholder until task 4.2 builds it.
class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ScreenPlaceholder(
      title: 'Forgot password',
      frame: 'GAP-02',
      task: '4.2',
    );
  }
}
