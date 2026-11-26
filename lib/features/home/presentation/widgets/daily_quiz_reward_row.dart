import 'package:flutter/material.dart';

import '../../../../core/theme/app_semantic_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../application/home_providers.dart';

/// The strip under the quiz bar (frame 15, "Frame 1197"): when the quest
/// resets on the left and the reward on the right.
///
/// 48 tall: one C1 line with 16 around it. It is white like the bar above, so
/// the doodle pattern starts under it. "Resets at midnight" is C1 grey; the
/// reward is C1 Bold in the warning (Talon-500) colour. Without [resets] the
/// reward stays on the right.
class DailyQuizRewardRow extends StatelessWidget {
  const DailyQuizRewardRow({
    super.key,
    required this.rewardTalons,
    this.resets = true,
  });

  final int rewardTalons;

  /// Shows "Resets at midnight".
  final bool resets;

  /// Minimum space between the two texts (spec: gap 10).
  static const gap = 10.0;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return ColoredBox(
      color: colors.surfaceWhite,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: [
            Expanded(
              child: resets
                  ? Text(
                      'Resets at midnight',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.c1.copyWith(
                        color: colors.textSecondary,
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
            const SizedBox(width: gap),
            Text(
              '+$rewardTalons ${countLabel(rewardTalons, 'talon')}',
              maxLines: 1,
              style: AppTypography.c1Bold.copyWith(color: colors.textWarning),
            ),
          ],
        ),
      ),
    );
  }
}
