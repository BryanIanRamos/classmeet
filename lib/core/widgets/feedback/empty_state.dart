import 'package:flutter/material.dart';

import '../../assets/app_images.dart';
import '../../theme/app_semantic_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../buttons/app_button.dart';

/// Shared layout of [EmptyState] and [ErrorState]: optional art, title (S1),
/// message (B3, secondary text) and an optional action button, centred.
///
/// Provisional: neither state has a design yet (GAP-21).
class StateMessage extends StatelessWidget {
  const StateMessage({
    super.key,
    required this.title,
    this.message,
    this.image,
    this.actionLabel,
    this.onAction,
  });

  /// Gap between the art and the title.
  static const gap = AppSpacing.md;

  final String title;
  final String? message;
  final AppImage? image;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (image case final art?) ...[
              Image.asset(
                art.path,
                width: art.width,
                height: art.height,
                cacheWidth: (art.width * 3).round(),
                excludeFromSemantics: true,
              ),
              const SizedBox(height: gap),
            ],
            Text(
              title,
              textAlign: TextAlign.center,
              style: AppTypography.s1.copyWith(color: colors.textPrimary),
            ),
            if (message != null) ...[
              const SizedBox(height: AppSpacing.xs),
              Text(
                message!,
                textAlign: TextAlign.center,
                style: AppTypography.b3.copyWith(color: colors.textSecondary),
              ),
            ],
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: AppSpacing.xl),
              AppButton(
                label: actionLabel!,
                onPressed: onAction,
                size: AppButtonSize.medium,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// "Nothing here yet" state for a list or screen (provisional, GAP-21).
class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.title,
    this.message,
    this.image,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final String? message;
  final AppImage? image;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return StateMessage(
      title: title,
      message: message,
      image: image,
      actionLabel: actionLabel,
      onAction: onAction,
    );
  }
}
