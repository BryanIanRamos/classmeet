import 'package:flutter/material.dart';

import '../../theme/app_semantic_colors.dart';
import '../../theme/app_typography.dart';

/// A section title with an optional subtitle and a trailing link, as on Home
/// ("Coming up next" ... "View study plan") and "Browse by tool ... View all".
///
/// The title is S1 (Plus Jakarta Sans 18/28 w600); the link is B3 in
/// Sage-500 and calls [onActionTap]; the subtitle is B3 in grey-500 (assumed).
/// The link is shown only when both [actionLabel] and [onActionTap] are set.
class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.actionLabel,
    this.onActionTap,
  });

  final String title;
  final String? subtitle;
  final String? actionLabel;
  final VoidCallback? onActionTap;

  /// Gap between the title and the link (Figma row gap 10).
  static const actionGap = 10.0;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final label = actionLabel;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.s1.copyWith(color: colors.textPrimary),
              ),
            ),
            if (label != null && onActionTap != null) ...[
              const SizedBox(width: actionGap),
              Semantics(
                button: true,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: onActionTap,
                  child: Text(
                    label,
                    maxLines: 1,
                    style: AppTypography.b3.copyWith(
                      color: colors.textSecondaryAccent,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
        if (subtitle != null)
          Text(
            subtitle!,
            style: AppTypography.b3.copyWith(color: colors.textSecondary),
          ),
      ],
    );
  }
}
