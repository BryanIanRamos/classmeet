import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_semantic_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/buttons/app_button.dart';
import '../../../../core/widgets/display/illustrated_card.dart';
import '../../../../data/models/study_plan.dart';
import '../../application/home_providers.dart';

/// The Home hero card (frame 8, "Frame 1180"): "YOUR DAILY PROGRESS",
/// "You got this!", the activities left today and "Continue studying".
///
/// 394×189 on the 428 frame, Sage-300 fill and border, radius 16. The copy
/// block starts 16 from the left and 20 from the top, with 10 between its
/// rows. The card art (Ollie on books, `home_hero_progress`) arrives with the
/// manual exports (1.8); until then the card is plain Sage-300.
///
/// When nothing is left today the line reads "All done for today"
/// (provisional: the design shows only the remaining count).
class DailyProgressCard extends StatelessWidget {
  const DailyProgressCard({
    super.key,
    required this.progress,
    required this.onContinue,
  });

  final DailyProgress progress;
  final VoidCallback? onContinue;

  /// Card height in the design.
  static const height = 189.0;

  /// Gap between the rows of the copy block (spec 8, "Frame 1149").
  static const _rowGap = 10.0;

  static const _padding = EdgeInsets.fromLTRB(
    AppSpacing.md,
    AppSpacing.lg,
    AppSpacing.md,
    AppSpacing.md,
  );

  @override
  Widget build(BuildContext context) {
    final accent = context.colors.textSecondaryAccent;
    final remaining = progress.remaining;
    return IllustratedCard(
      minHeight: height,
      padding: _padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'YOUR DAILY PROGRESS',
            style: AppTypography.b3.copyWith(color: accent),
          ),
          const SizedBox(height: _rowGap),
          Text(
            'You got this!',
            style: AppTypography.h5.copyWith(color: AppColors.black),
          ),
          const SizedBox(height: _rowGap),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxs),
            child: Text(
              remaining > 0
                  ? '$remaining ${countLabel(remaining, 'activity', 'activities')} remaining'
                  : 'All done for today',
              style: AppTypography.c1.copyWith(color: accent),
            ),
          ),
          const SizedBox(height: _rowGap),
          AppButton(
            label: 'Continue studying',
            onPressed: onContinue,
            expand: true,
          ),
        ],
      ),
    );
  }
}
