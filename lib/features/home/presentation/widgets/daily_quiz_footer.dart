import 'package:flutter/material.dart';

import '../../../../core/assets/app_icons.dart';
import '../../../../core/theme/app_semantic_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/buttons/app_button.dart';
import '../../../../core/widgets/feedback/app_alert.dart';

/// The pinned bottom of the quiz (frame 15, "Frame 17"): the primary button
/// and the "Earn Talons for finishing" note, with an error notice above them
/// when recording the quiz failed ([failed]).
///
/// The button is large, Sage and full width, 24 from the screen edges (12 of
/// the page plus 12 of the frame); the note is C1 grey, centred, 8 below. 12
/// above and below that block, then the space the design gives its home
/// indicator (the bottom safe-area inset) and 12 of page padding. A null
/// [onPressed] disables the button.
class DailyQuizFooter extends StatelessWidget {
  const DailyQuizFooter({
    super.key,
    required this.label,
    required this.onPressed,
    this.failed = false,
  });

  final String label;
  final VoidCallback? onPressed;

  /// Shows "Could not finish the quiz" above the button.
  final bool failed;

  static const note = 'Earn Talons for finishing, not for a perfect score.';

  /// Side inset of the block: the page's 12 plus the frame's 12.
  static const inset = AppSpacing.sm + AppSpacing.sm;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final safeBottom = MediaQuery.paddingOf(context).bottom;
    return Padding(
      padding: EdgeInsets.fromLTRB(
        inset,
        AppSpacing.sm,
        inset,
        AppSpacing.sm + safeBottom + AppSpacing.sm,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (failed) ...[
            const AppAlert(
              title: 'Could not finish the quiz',
              message: 'Something went wrong. Please try again.',
              tone: AppAlertTone.error,
              icon: AppIcons.circleX,
            ),
            const SizedBox(height: AppSpacing.xs),
          ],
          AppButton(label: label, onPressed: onPressed, expand: true),
          const SizedBox(height: AppSpacing.xs),
          Text(
            note,
            textAlign: TextAlign.center,
            style: AppTypography.c1.copyWith(color: colors.textSecondary),
          ),
        ],
      ),
    );
  }
}
