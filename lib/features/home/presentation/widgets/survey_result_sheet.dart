import 'package:flutter/material.dart';

import '../../../../core/assets/app_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_semantic_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/buttons/app_button.dart';
import '../../../../core/widgets/layout/app_sheet.dart';
import '../../application/home_providers.dart';
import '../../application/weekly_survey_controller.dart';

/// Opens the result sheet over the sent survey and completes when it closes.
/// "Done" is its only way out: no scrim tap or drag.
Future<void> showSurveyResultSheet(
  BuildContext context,
  WeeklySurveyResult result,
) {
  return showAppSheet<void>(
    context,
    isDismissible: false,
    enableDrag: false,
    builder: (_) => SurveyResultSheet(result: result),
  );
}

/// What sending the survey leaves behind: "Thanks for sharing!" and either the
/// talons earned or a note that this week's reward was already taken. The
/// design has no result screen yet, so the look is provisional, the same as
/// the daily quiz's: the heading of the wrong-answer sheet (129: a 24 icon and
/// an S1 title) and its Talon tile.
///
/// "Done" closes the sheet; the screen then leaves the survey, back to where it
/// was opened (Home or Talon credits).
class SurveyResultSheet extends StatelessWidget {
  const SurveyResultSheet({super.key, required this.result});

  final WeeklySurveyResult result;

  static const title = 'Thanks for sharing!';
  static const alreadyEarned = "You already earned this week's talons.";

  /// Size of the heading icon and of the one in the talon tile.
  static const iconSize = 24.0;
  static const tileIconSize = 16.0;

  /// Space between the heading icon and its text (spec 129: 10).
  static const iconGap = 10.0;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final talons = result.talonsEarned;
    return AppSheet(
      showGrabber: false,
      footer: AppButton(
        label: 'Done',
        expand: true,
        onPressed: () => Navigator.pop(context),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(
                AppIcons.heart,
                size: iconSize,
                color: colors.iconSecondaryAccent,
              ),
              const SizedBox(width: iconGap),
              Expanded(
                child: Semantics(
                  header: true,
                  child: Text(
                    title,
                    style: AppTypography.s1.copyWith(color: colors.textPrimary),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          if (result.earnedTalons)
            DecoratedBox(
              decoration: const BoxDecoration(
                color: AppColors.talon50,
                borderRadius: BorderRadius.all(Radius.circular(AppRadii.md)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.sm),
                child: Row(
                  children: [
                    const Icon(
                      AppIcons.coins,
                      size: tileIconSize,
                      color: AppColors.talon700,
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Expanded(
                      child: Text(
                        '+$talons ${countLabel(talons, 'talon')} earned',
                        style: AppTypography.b2.copyWith(
                          color: colors.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            Text(
              alreadyEarned,
              style: AppTypography.b3.copyWith(color: colors.textSecondary),
            ),
        ],
      ),
    );
  }
}
