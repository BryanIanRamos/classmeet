import 'package:flutter/material.dart';

import '../../../../core/assets/app_icons.dart';
import '../../../../core/theme/app_semantic_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/buttons/app_button.dart';
import '../../../../core/widgets/feedback/app_alert.dart';
import '../../application/home_providers.dart';

/// The foot of the survey (frame 16, "Frame 17"): the submit button and the
/// "Skip survey" link under it, with an error notice above them when sending
/// failed ([failed]).
///
/// 12 of padding around the block. The button is large, Sage and full width
/// (378 on the 428 frame). "Skip survey" is C1 grey, centred, 8 below it. The
/// design draws it as plain text; its tap area also takes in the 8 above and
/// the 12 below it, so the link is easier to hit and the layout is the
/// design's. A null [onSubmit] disables the button (the survey is being sent).
class SurveyFooter extends StatelessWidget {
  const SurveyFooter({
    super.key,
    required this.rewardTalons,
    required this.onSubmit,
    required this.onSkip,
    this.failed = false,
  });

  /// The talons the survey earns, for the button: "Earn 5 Talons".
  final int rewardTalons;

  /// Sends the survey; null while it is being sent.
  final VoidCallback? onSubmit;

  /// Leaves without sending.
  final VoidCallback onSkip;

  /// Shows "Could not submit the survey" above the button.
  final bool failed;

  static const skipLabel = 'Skip survey';

  /// "Submit survey · Earn 5 Talons". The design says 2; the quest rewards
  /// are +5 (INC-5), so the number comes from the data. A survey that pays
  /// nothing just says "Submit survey".
  static String submitLabel(int rewardTalons) => rewardTalons > 0
      ? 'Submit survey · Earn $rewardTalons '
            '${countLabel(rewardTalons, 'Talon')}'
      : 'Submit survey';

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.sm,
            AppSpacing.sm,
            AppSpacing.sm,
            0,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (failed) ...[
                const AppAlert(
                  title: 'Could not submit the survey',
                  message: 'Something went wrong. Please try again.',
                  tone: AppAlertTone.error,
                  icon: AppIcons.circleX,
                ),
                const SizedBox(height: AppSpacing.xs),
              ],
              AppButton(
                label: submitLabel(rewardTalons),
                onPressed: onSubmit,
                expand: true,
              ),
            ],
          ),
        ),
        Semantics(
          button: true,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onSkip,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.sm,
                AppSpacing.xs,
                AppSpacing.sm,
                AppSpacing.sm,
              ),
              child: Text(
                skipLabel,
                textAlign: TextAlign.center,
                style: AppTypography.c1.copyWith(color: colors.textSecondary),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
