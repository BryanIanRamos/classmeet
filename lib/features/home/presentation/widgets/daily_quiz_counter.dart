import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_semantic_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/feedback/app_progress_bar.dart';

/// "Question 2 of 5", the question's category and the counter bar (frame 15,
/// "Frame 1198").
///
/// The bar has one separate 6-tall pill per question, 6 apart, and the first
/// [number] of them are filled: the design shows 2 filled for "Question 2",
/// so the bar counts the question being answered, not the ones done. The
/// text row is C1, grey on the left and Sage-500 on the right, with 10
/// between the texts and 10 above the bar; 16 all around. The bar announces
/// the "Question 2 of 5" text, so screen readers skip the visible copy.
class DailyQuizCounter extends StatelessWidget {
  const DailyQuizCounter({
    super.key,
    required this.number,
    required this.total,
    this.category,
  }) : assert(total > 0),
       assert(number >= 0 && number <= total);

  /// The question being answered, from 1.
  final int number;
  final int total;
  final String? category;

  /// Space between the text row and the bar, and between its two texts.
  static const gap = 10.0;

  /// Height of the pills, and the space between them.
  static const barHeight = 6.0;
  static const barGap = 6.0;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final label = 'Question $number of $total';
    final category = this.category;
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              ExcludeSemantics(
                child: Text(
                  label,
                  maxLines: 1,
                  style: AppTypography.c1.copyWith(color: colors.textSecondary),
                ),
              ),
              if (category != null) ...[
                const SizedBox(width: gap),
                Expanded(
                  child: Text(
                    category,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.end,
                    style: AppTypography.c1.copyWith(
                      color: colors.textSecondaryAccent,
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: gap),
          AppProgressBar(
            value: number / total,
            segments: total,
            segmentGap: barGap,
            height: barHeight,
            trackColor: AppColors.grey300,
            semanticLabel: label,
          ),
        ],
      ),
    );
  }
}
