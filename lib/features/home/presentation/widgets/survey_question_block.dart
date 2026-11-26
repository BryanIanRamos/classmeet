import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_semantic_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/selection/app_answer_option.dart';
import '../../../../core/widgets/selection/app_chip.dart';
import '../../../../data/models/survey.dart';

/// One question of the weekly survey (frame 16, "Frame 15", "Frame 1197" and
/// "Frame 1198"): the numbered prompt and, under it, the options as chips or
/// as radio cards, by the question's style.
///
/// 12 of padding around the block, 16 under it, 8 between the prompt and the
/// options. The prompt is B2 with a hanging number: "1." sits 4 in, the text
/// starts 24 in, and a prompt that wraps (question 3) keeps that edge.
///
/// [SurveyQuestionStyle.chips] are neutral [AppChip]s, 16 apart, that wrap onto
/// more lines on a narrow screen. [SurveyQuestionStyle.radios] are
/// [AppAnswerOption] cards, 16 apart. One option is picked per question;
/// picking the picked one again keeps it.
///
/// The [divider] is the design's in-layout Grey-200 stroke under the block: a
/// full-width 1 line, with the padding above it, between two questions. The
/// last question has none.
class SurveyQuestionBlock extends StatelessWidget {
  const SurveyQuestionBlock({
    super.key,
    required this.number,
    required this.question,
    required this.selected,
    required this.onSelect,
    this.divider = true,
  });

  /// The question's place in the survey, from 1.
  final int number;
  final SurveyQuestion question;

  /// The index of the picked option, or null.
  final int? selected;

  /// Called with the index of the option that was tapped.
  final ValueChanged<int> onSelect;

  /// Draws the line under the block, between this question and the next.
  final bool divider;

  /// Width of the number's slot, which is where the prompt starts.
  static const markerSlot = AppSpacing.xl;

  /// Space left of the number, and the least space right of it.
  static const markerInset = AppSpacing.xxs;

  /// Space between the prompt and the options.
  static const promptGap = AppSpacing.xs;

  /// Space between two options, in a column and on a chip row.
  static const optionGap = AppSpacing.md;

  static const _padding = EdgeInsets.fromLTRB(
    AppSpacing.sm,
    AppSpacing.sm,
    AppSpacing.sm,
    AppSpacing.md,
  );

  static const _divider = BoxDecoration(
    border: Border(bottom: BorderSide(color: AppColors.grey200)),
  );

  @override
  Widget build(BuildContext context) {
    return Container(
      // The line takes layout space under the padding, like Figma's in-layout
      // stroke (a Container adds the decoration's border to its padding).
      decoration: divider ? _divider : null,
      padding: _padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _prompt(context),
          const SizedBox(height: promptGap),
          switch (question.style) {
            SurveyQuestionStyle.chips => _chips(),
            SurveyQuestionStyle.radios => _radios(),
          },
        ],
      ),
    );
  }

  /// "1." and the question as one label for screen readers.
  Widget _prompt(BuildContext context) {
    final style = AppTypography.b2.copyWith(color: context.colors.textPrimary);
    return Semantics(
      label: '$number. ${question.prompt}',
      excludeSemantics: true,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ConstrainedBox(
            constraints: const BoxConstraints(minWidth: markerSlot),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: markerInset),
              child: Text('$number.', style: style),
            ),
          ),
          Expanded(child: Text(question.prompt, style: style)),
        ],
      ),
    );
  }

  Widget _chips() {
    return Wrap(
      spacing: optionGap,
      runSpacing: optionGap,
      children: [
        for (var i = 0; i < question.options.length; i++)
          AppChip.choice(
            label: question.options[i],
            style: AppChipStyle.neutral,
            selected: selected == i,
            onSelected: (_) => onSelect(i),
          ),
      ],
    );
  }

  Widget _radios() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < question.options.length; i++) ...[
          if (i > 0) const SizedBox(height: optionGap),
          AppAnswerOption(
            label: question.options[i],
            state: selected == i
                ? AppAnswerOptionState.selected
                : AppAnswerOptionState.idle,
            onTap: () => onSelect(i),
          ),
        ],
      ],
    );
  }
}
