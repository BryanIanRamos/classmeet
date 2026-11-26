import 'package:flutter/material.dart';

import '../../../../core/theme/app_semantic_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/selection/app_answer_option.dart';
import '../../../../data/models/quiz.dart';
import 'daily_quiz_counter.dart';
import 'daily_quiz_feedback_card.dart';
import 'daily_quiz_info_card.dart';

/// One question of the daily quiz as the scrolling part of frame 15: the
/// counter, the question, the hint, the options and, under them, the "About
/// today's quiz" card.
///
/// Blocks are inset as in the design: the counter and the options 16 from
/// the content edge, the question and the hint 12; 24 between the options and
/// the card, 16 between options. The screen adds the 12 of the page itself.
///
/// After [checked] the options lock ([onSelect] is no longer called): the
/// right one turns Sprout and a wrong [selected] one Talon, and a
/// [DailyQuizFeedbackCard] takes the info card's place under them. The hint
/// stays. [feedbackKey] marks the card, so the screen can scroll it into view.
class DailyQuizQuestionView extends StatelessWidget {
  const DailyQuizQuestionView({
    super.key,
    required this.question,
    required this.number,
    required this.total,
    required this.selected,
    required this.checked,
    required this.onSelect,
    this.feedbackKey,
  });

  final Question question;

  /// The question's place, from 1, of [total].
  final int number;
  final int total;

  /// The picked option, or null.
  final int? selected;
  final bool checked;
  final ValueChanged<int> onSelect;
  final Key? feedbackKey;

  /// Space between two options.
  static const optionGap = AppSpacing.md;

  /// Space between the options and the card under them.
  static const cardGap = AppSpacing.xl;

  /// The text of an option as the quiz shows it: its letter, then the answer.
  static String optionLabel(int index, String answer) =>
      '${String.fromCharCode(_firstLetter + index)}. $answer';

  static const _firstLetter = 0x41; // "A"

  AppAnswerOptionState _stateOf(int index) {
    if (!checked) {
      return index == selected
          ? AppAnswerOptionState.selected
          : AppAnswerOptionState.idle;
    }
    if (index == question.correctIndex) return AppAnswerOptionState.correct;
    if (index == selected) return AppAnswerOptionState.wrong;
    return AppAnswerOptionState.idle;
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DailyQuizCounter(
          number: number,
          total: total,
          category: question.category,
        ),
        Padding(
          padding: const EdgeInsets.all(AppSpacing.sm),
          child: Text(
            question.prompt,
            style: AppTypography.s1.copyWith(color: colors.textPrimary),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(AppSpacing.sm),
          child: Text(
            'Please select the correct answer',
            style: AppTypography.b3.copyWith(color: colors.textSecondary),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (var i = 0; i < question.options.length; i++) ...[
                if (i > 0) const SizedBox(height: optionGap),
                AppAnswerOption(
                  label: optionLabel(i, question.options[i]),
                  state: _stateOf(i),
                  onTap: checked ? null : () => onSelect(i),
                ),
              ],
              const SizedBox(height: cardGap),
              if (checked)
                DailyQuizFeedbackCard(
                  key: feedbackKey,
                  correct: selected == question.correctIndex,
                  answer: question.options[question.correctIndex],
                  explanation: question.explanation,
                )
              else
                const DailyQuizInfoCard(),
            ],
          ),
        ),
      ],
    );
  }
}
