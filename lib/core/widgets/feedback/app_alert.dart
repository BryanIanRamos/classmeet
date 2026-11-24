import 'package:flutter/material.dart';

import '../../assets/app_icons.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_radii.dart';
import '../../theme/app_semantic_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';

/// Figma "State" axis of the DS Alert (default, success, info, warning,
/// error), with the Sage palette in place of the UI kit's colours (default
/// blue → sage, success → sprout, info → sky, warning → talon, error →
/// ember).
enum AppAlertTone {
  /// The DS "Default" state.
  normal(tint: AppColors.sage50, strong: AppColors.sage500),
  success(tint: AppColors.sprout50, strong: AppColors.sprout500),
  info(tint: AppColors.sky50, strong: AppColors.sky500),
  warning(tint: AppColors.talon50, strong: AppColors.talon500),
  error(tint: AppColors.ember50, strong: AppColors.ember500);

  const AppAlertTone({required this.tint, required this.strong});

  /// Fill of the outline style.
  final Color tint;

  /// Fill of the filled style; border, icon and primary action of the
  /// outline style.
  final Color strong;
}

/// Figma "Style" axis of the DS Alert. The DS sheet's "Primary" and
/// "Secondary" are the two text-button styles of the actions, set with
/// [AppAlert.actionLabel] and [AppAlert.secondaryActionLabel].
enum AppAlertStyle {
  /// Solid tone fill with white text.
  filled,

  /// Tint-50 fill with a tone border, dark title and grey message.
  outline,
}

/// The ClassMeet alert / notice card (DS Alert, Figma 5248:2071).
///
/// Geometry from the DS: padding 16, radius 12, 16 between icon and content,
/// 4 between title and message, 16 above the actions, outline border 1.5.
/// Title is S2 (DS Inter 16/24 SemiBold) and message B3 (Inter 14/20); the
/// kit's Inter becomes Plus Jakarta Sans. The height follows the content.
/// An optional close button ([onClose]) sits at the end of the row.
class AppAlert extends StatelessWidget {
  const AppAlert({
    super.key,
    required this.title,
    this.message,
    this.tone = AppAlertTone.normal,
    this.style = AppAlertStyle.outline,
    this.icon,
    this.onClose,
    this.actionLabel,
    this.onAction,
    this.secondaryActionLabel,
    this.onSecondaryAction,
  });

  /// Padding inside the card.
  static const padding = AppSpacing.md;

  /// Corner radius.
  static const radius = AppRadii.sm;

  /// Border width of the outline style.
  static const borderWidth = 1.5;

  /// Size of the leading and close icons.
  static const iconSize = 24.0;

  /// Gap between the icon, the content and the close button.
  static const gap = AppSpacing.md;

  /// Gap between the title and the message.
  static const textGap = AppSpacing.xxs;

  /// Gap between the text and the actions, and between the two actions.
  static const actionGap = AppSpacing.md;

  final String title;
  final String? message;
  final AppAlertTone tone;
  final AppAlertStyle style;

  /// Leading icon (the DS shows a star).
  final IconData? icon;

  /// Shows the close (x) button when set.
  final VoidCallback? onClose;

  /// The DS "Primary" text button; shown when both label and callback are set.
  final String? actionLabel;
  final VoidCallback? onAction;

  /// The DS "Secondary" text button (grey, or 60% white on filled).
  final String? secondaryActionLabel;
  final VoidCallback? onSecondaryAction;

  /// Card fill; public for tests.
  Color get background =>
      style == AppAlertStyle.filled ? tone.strong : tone.tint;

  /// Icon colour; public for tests.
  Color get iconColor =>
      style == AppAlertStyle.filled ? AppColors.white : tone.strong;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final filled = style == AppAlertStyle.filled;
    final titleColor = filled ? colors.textPrimaryWhite : colors.textPrimary;
    final messageColor = filled
        ? colors.textPrimaryWhite
        : colors.textSecondary;
    final primaryColor = filled ? colors.textPrimaryWhite : tone.strong;
    final secondaryColor = filled
        ? colors.textSecondaryWhite
        : AppColors.grey400;
    final hasPrimary = actionLabel != null && onAction != null;
    final hasSecondary =
        secondaryActionLabel != null && onSecondaryAction != null;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(radius),
        border: filled
            ? null
            : Border.all(color: tone.strong, width: borderWidth),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null) ...[
            Icon(icon, size: iconSize, color: iconColor),
            const SizedBox(width: gap),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.s2.copyWith(color: titleColor),
                ),
                if (message != null) ...[
                  const SizedBox(height: textGap),
                  Text(
                    message!,
                    style: AppTypography.b3.copyWith(color: messageColor),
                  ),
                ],
                if (hasPrimary || hasSecondary) ...[
                  const SizedBox(height: actionGap),
                  Wrap(
                    spacing: actionGap,
                    runSpacing: AppSpacing.xs,
                    children: [
                      if (hasPrimary)
                        _AlertAction(
                          label: actionLabel!,
                          color: primaryColor,
                          onPressed: onAction!,
                        ),
                      if (hasSecondary)
                        _AlertAction(
                          label: secondaryActionLabel!,
                          color: secondaryColor,
                          onPressed: onSecondaryAction!,
                        ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          if (onClose != null) ...[
            const SizedBox(width: gap),
            Semantics(
              button: true,
              label: 'Dismiss',
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: onClose,
                child: Icon(AppIcons.x, size: iconSize, color: iconColor),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _AlertAction extends StatelessWidget {
  const _AlertAction({
    required this.label,
    required this.color,
    required this.onPressed,
  });

  final String label;
  final Color color;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onPressed,
        child: Text(
          label,
          style: AppTypography.buttonLarge.copyWith(color: color),
        ),
      ),
    );
  }
}
