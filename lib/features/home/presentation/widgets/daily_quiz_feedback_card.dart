import 'package:flutter/material.dart';

import '../../../../core/assets/app_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_semantic_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';

/// What the quiz says after "Check answer", in the words of the Play
/// feedback card (frames 125 and 126, "Frame 1173"): "Nice work!" for a
/// right answer, "Correct answer: …" naming the right option for a wrong
/// one, then the explanation.
///
/// Always Sprout, because it is about the right answer: a Sprout-50 card,
/// radius 16, 12 inside and 12 between rows; a 16 Sprout-700 circle-check
/// and a B4 Sprout-700 title with 12 between them; the explanation in C3
/// Grey-900. (125 adds a "+10 points" chip; the daily quiz has no points.)
/// The card is a live region, so screen readers announce it when it
/// appears.
class DailyQuizFeedbackCard extends StatelessWidget {
  const DailyQuizFeedbackCard({
    super.key,
    required this.correct,
    required this.answer,
    this.explanation,
  });

  final bool correct;

  /// The right option's text, without its letter: named after a wrong pick.
  final String answer;

  /// Why the right option is right; the card shows only the title without it.
  final String? explanation;

  /// Icon size (spec 125: 16).
  static const iconSize = 16.0;

  /// "Nice work!" or "Correct answer: …" (125, 126).
  String get title => correct ? 'Nice work!' : 'Correct answer: $answer';

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final explanation = this.explanation;
    return Semantics(
      container: true,
      liveRegion: true,
      child: DecoratedBox(
        decoration: const BoxDecoration(
          color: AppColors.sprout50,
          borderRadius: BorderRadius.all(Radius.circular(AppRadii.md)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.sm),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    AppIcons.circleCheck,
                    size: iconSize,
                    color: AppColors.sprout700,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      title,
                      style: AppTypography.b4.copyWith(
                        color: AppColors.sprout700,
                      ),
                    ),
                  ),
                ],
              ),
              if (explanation != null) ...[
                const SizedBox(height: AppSpacing.sm),
                Text(
                  explanation,
                  style: AppTypography.c3.copyWith(color: colors.textPrimary),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
