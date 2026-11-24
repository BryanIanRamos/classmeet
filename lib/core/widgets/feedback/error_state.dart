import 'package:flutter/material.dart';

import '../../assets/app_images.dart';
import 'empty_state.dart';

/// "Something went wrong" state with a retry action (provisional, GAP-21).
/// The retry button shows when [onRetry] is set.
class ErrorState extends StatelessWidget {
  const ErrorState({
    super.key,
    this.title = 'Something went wrong',
    this.message = 'Please check your connection and try again.',
    this.image,
    this.retryLabel = 'Try again',
    this.onRetry,
  });

  final String title;
  final String? message;
  final AppImage? image;
  final String retryLabel;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return StateMessage(
      title: title,
      message: message,
      image: image,
      actionLabel: retryLabel,
      onAction: onRetry,
    );
  }
}
