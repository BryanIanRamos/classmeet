import 'package:flutter/material.dart';

import '../../../../core/theme/app_semantic_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';

/// The heading of the survey (frame 16, "Frame 13"): the survey's [title] in
/// S1 and, 4 below it, the B3 grey line that invites the student to answer.
///
/// 12 of padding around both, left aligned (the design's "centre" is the
/// frame's own alignment: the text starts at the frame's left edge).
class SurveyIntro extends StatelessWidget {
  const SurveyIntro({super.key, required this.title});

  /// "How's your study week going?", from the survey.
  final String title;

  /// Static screen copy: it is not part of the survey data.
  static const intro =
      'A quick check-in helps us make ClassMeet better for you.';

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Semantics(
            header: true,
            child: Text(
              title,
              style: AppTypography.s1.copyWith(color: colors.textPrimary),
            ),
          ),
          const SizedBox(height: AppSpacing.xxs),
          Text(
            intro,
            style: AppTypography.b3.copyWith(color: colors.textSecondary),
          ),
        ],
      ),
    );
  }
}
