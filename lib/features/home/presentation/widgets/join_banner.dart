import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/display/illustrated_card.dart';

/// The "Learn together" banner under the Join a class bar (frame 13.1,
/// "Frame 1179"): Ollie on the left, a paper plane and sparkles on the right,
/// and the copy between them.
///
/// Full width and 154 high, flush with the bar: no radius, no outline. The
/// card art (a Talon gradient with Ollie, clouds and the paper plane:
/// `home_join_learn_together`) arrives with the manual exports (1.8); until
/// then the card is plain Talon-100, which is close to the average of the art.
///
/// The copy block ("Frame 4", 199 wide, padding 12, gap 4) is centred
/// vertically. The spec gives sizes only, so its left edge (194) is measured
/// on the reference. It keeps that distance from the left on narrower screens,
/// where Ollie keeps his size, and the block gives up width instead: it runs
/// to the right edge, so the title still fits one line at 360.
class JoinBanner extends StatelessWidget {
  const JoinBanner({super.key});

  /// Banner height in the design.
  static const height = 154.0;

  /// Distance from the left edge to the copy block ("Frame 4").
  static const copyStart = 194.0;

  /// Width of the copy block, padding included (spec "Frame 4").
  static const copyWidth = 199.0;

  /// Gap between the title and the line (spec "Frame 4").
  static const _rowGap = AppSpacing.xxs;

  @override
  Widget build(BuildContext context) {
    return IllustratedCard(
      color: AppColors.talon100,
      radius: AppRadii.none,
      minHeight: height,
      padding: const EdgeInsets.only(left: copyStart),
      artAlignment: Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: height),
        child: Align(
          alignment: Alignment.centerLeft,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: copyWidth),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.sm),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Learn together',
                    style: AppTypography.s1.copyWith(color: AppColors.talon900),
                  ),
                  const SizedBox(height: _rowGap),
                  Text(
                    'Join your class to access shared materials, quizzes, '
                    'and announcements.',
                    style: AppTypography.c1.copyWith(color: AppColors.talon700),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
