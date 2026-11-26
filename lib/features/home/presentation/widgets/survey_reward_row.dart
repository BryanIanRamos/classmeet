import 'package:flutter/material.dart';

import '../../../../core/theme/app_semantic_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../application/home_providers.dart';

/// The strip under the survey's bar (frame 16, "Frame 1197"): how long the
/// survey is open on the left and the reward on the right.
///
/// 48 tall: one C1 line with 16 around it. It is white like the bar above, so
/// the doodle pattern starts under it. The left text ([availability], "Available
/// until Sunday") is C1 grey. The design repeats "Resets at midnight" from the
/// daily quiz, but the survey closes on Sunday, as Home and Talon credits say.
/// The reward is C1 Bold in the warning (Talon-500) colour. Without
/// [availability] the reward stays on the right.
class SurveyRewardRow extends StatelessWidget {
  const SurveyRewardRow({
    super.key,
    required this.rewardTalons,
    this.availability,
  });

  final int rewardTalons;

  /// "Available until Sunday"; null leaves the left side empty.
  final String? availability;

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
              child: availability == null
                  ? const SizedBox.shrink()
                  : Text(
                      availability!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.c1.copyWith(
                        color: colors.textSecondary,
                      ),
                    ),
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
