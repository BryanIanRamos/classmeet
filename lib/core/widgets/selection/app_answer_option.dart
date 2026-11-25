import 'package:flutter/material.dart';

import '../../assets/app_icons.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_radii.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';

/// The states of a quiz answer option, with each state's colours: the
/// question (15, 124), its correct state (125) and the revealed state (126).
enum AppAnswerOptionState {
  /// Not chosen: Grey-50 with a Sage-500 outline and an empty Sage ring.
  idle(
    fill: AppColors.grey50,
    border: AppColors.sage500,
    ring: AppColors.sage500,
    label: AppColors.grey900,
  ),

  /// Chosen, not yet checked: Sage-500 fill, white label, Sage-50 ring and
  /// dot (15, "A." selected).
  selected(
    fill: AppColors.sage500,
    border: AppColors.sage500,
    ring: AppColors.sage50,
    dot: AppColors.sage50,
    label: AppColors.white,
  ),

  /// The right answer after checking: Sprout-50 with a Sprout-500 outline,
  /// ring and dot, and a circle-check (125, 126).
  correct(
    fill: AppColors.sprout50,
    border: AppColors.sprout500,
    ring: AppColors.sprout500,
    dot: AppColors.sprout500,
    label: AppColors.grey900,
    trailing: AppIcons.circleCheck,
  ),

  /// The student's wrong pick after checking: Talon-50 with a Talon-500
  /// outline, ring and dot, and a circle-x (126; Talon, not Ember).
  wrong(
    fill: AppColors.talon50,
    border: AppColors.talon500,
    ring: AppColors.talon500,
    dot: AppColors.talon500,
    label: AppColors.grey900,
    trailing: AppIcons.circleX,
  );

  const AppAnswerOptionState({
    required this.fill,
    required this.border,
    required this.ring,
    required this.label,
    this.dot,
    this.trailing,
  });

  final Color fill;
  final Color border;

  /// Radio ring; also the trailing icon colour.
  final Color ring;

  /// Radio dot; null leaves the ring empty.
  final Color? dot;
  final Color label;
  final IconData? trailing;
}

/// A quiz answer option (frames 15, 124–126): a radio, the answer text and,
/// after checking, a check or cross at the end.
///
/// 50 tall for one line: a 1 Sage-500 border laid out outside the 12 padding
/// (Figma "(in layout)"), a 24 radio, 16 to the B1 label. The selected
/// option keeps the border in its fill colour, so choosing does not shift
/// the list (the design draws it 48 tall without a border, INC-15). Long
/// answers wrap; the radio stays on the first line.
///
/// A null [onTap] makes the option static (after the answer is checked).
/// Screen readers hear a radio button in a group, checked when [state] is
/// not [AppAnswerOptionState.idle], plus "correct answer" or "your answer,
/// incorrect" after checking.
class AppAnswerOption extends StatelessWidget {
  const AppAnswerOption({
    super.key,
    required this.label,
    required this.state,
    required this.onTap,
  });

  final String label;
  final AppAnswerOptionState state;
  final VoidCallback? onTap;

  static const borderWidth = 1.0;
  static const radioSize = 24.0;
  static const radioRing = 1.5;
  static const radioDot = 12.0;
  static const trailingSize = 16.0;

  /// Gap between the radio and the label (spec "Radio + Text" gap 16).
  static const labelGap = AppSpacing.md;

  @override
  Widget build(BuildContext context) {
    final s = state;
    final trailing = s.trailing;
    final shape = BorderRadius.circular(AppRadii.md);
    return Semantics(
      inMutuallyExclusiveGroup: true,
      checked: s != AppAnswerOptionState.idle,
      enabled: onTap != null,
      label: switch (s) {
        AppAnswerOptionState.correct => '$label, correct answer',
        AppAnswerOptionState.wrong => '$label, your answer, incorrect',
        _ => label,
      },
      excludeSemantics: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: s.fill,
            borderRadius: shape,
            border: Border.all(color: s.border),
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.sm + borderWidth),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Radio(ring: s.ring, dot: s.dot),
                const SizedBox(width: labelGap),
                Expanded(
                  child: Text(
                    label,
                    style: AppTypography.b1.copyWith(color: s.label),
                  ),
                ),
                if (trailing != null) ...[
                  const SizedBox(width: AppSpacing.xs),
                  SizedBox(
                    height: radioSize,
                    child: Icon(trailing, size: trailingSize, color: s.ring),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Radio extends StatelessWidget {
  const _Radio({required this.ring, required this.dot});

  final Color ring;
  final Color? dot;

  @override
  Widget build(BuildContext context) {
    final dot = this.dot;
    return Container(
      key: const ValueKey('answer-radio'),
      width: AppAnswerOption.radioSize,
      height: AppAnswerOption.radioSize,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: ring, width: AppAnswerOption.radioRing),
      ),
      child: dot == null
          ? null
          : Container(
              key: const ValueKey('answer-radio-dot'),
              width: AppAnswerOption.radioDot,
              height: AppAnswerOption.radioDot,
              decoration: BoxDecoration(color: dot, shape: BoxShape.circle),
            ),
    );
  }
}
