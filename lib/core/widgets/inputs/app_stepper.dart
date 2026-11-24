import 'package:flutter/material.dart';

import '../../assets/app_icons.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_radii.dart';
import '../../theme/app_semantic_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';

/// Figma "Style" axis of the DS Stepper (5248:10391).
enum AppStepperStyle {
  /// Sage-50 fill with Sage-500 icons and a Sage-100 divider (kit: #EDEFFE
  /// fill, #4E61F6 icons, #C8CEFC divider).
  filled,

  /// White with a grey-200 stroke, dark icons and a grey-200 divider.
  outline,
}

/// The ClassMeet stepper: a "minus | plus" control (DS Stepper, Figma
/// 5248:10391) that moves [value] by [step] between [min] and [max].
///
/// The DS control is 32 high, radius 8, 12 padding and gap, 24 icons and a
/// 1.5 divider, and shows no number. [showValue] (the default) adds the
/// current value between two dividers; set it to false for the bare DS
/// control when the value is shown elsewhere.
///
/// Each side is disabled at its limit; a null [onChanged] disables both.
/// Colours come from the screens (kit blue becomes Sage-500).
class AppStepper extends StatelessWidget {
  const AppStepper({
    super.key,
    required this.value,
    required this.onChanged,
    this.min = 0,
    this.max = 100,
    this.step = 1,
    this.style = AppStepperStyle.filled,
    this.showValue = true,
  }) : assert(min <= max),
       assert(step > 0);

  /// Height of the control.
  static const height = 32.0;

  /// Width of each divider.
  static const dividerWidth = 1.5;

  /// Size of the icons.
  static const iconSize = 24.0;

  /// Narrowest the value text may be, so the control keeps its width while the
  /// number changes (two digits).
  static const valueMinWidth = 32.0;

  /// Border width of the outline style.
  static const borderWidth = 1.5;

  static const decrementKey = ValueKey<String>('AppStepper.decrement');
  static const incrementKey = ValueKey<String>('AppStepper.increment');

  /// Semantic labels of the two buttons.
  static const decrementLabel = 'Decrease';
  static const incrementLabel = 'Increase';

  final int value;

  /// Called with the new value, always within [min] and [max]. Null disables
  /// the stepper.
  final ValueChanged<int>? onChanged;

  final int min;
  final int max;
  final int step;
  final AppStepperStyle style;
  final bool showValue;

  bool get _canDecrement => onChanged != null && value > min;
  bool get _canIncrement => onChanged != null && value < max;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final filled = style == AppStepperStyle.filled;
    final divider = SizedBox(
      width: dividerWidth,
      height: height,
      child: ColoredBox(color: filled ? AppColors.sage100 : AppColors.grey200),
    );
    final iconColor = filled ? colors.iconSecondaryAccent : colors.iconBlack;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: filled ? AppColors.sage50 : AppColors.white,
        borderRadius: const BorderRadius.all(Radius.circular(AppRadii.xs)),
        border: filled
            ? null
            : Border.all(color: AppColors.grey200, width: borderWidth),
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.all(Radius.circular(AppRadii.xs)),
        child: SizedBox(
          height: height,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _Button(
                key: decrementKey,
                icon: AppIcons.minus,
                label: decrementLabel,
                color: iconColor,
                disabledColor: colors.iconLightGrey,
                onTap: _canDecrement ? () => _set(value - step) : null,
              ),
              divider,
              if (showValue) ...[
                ConstrainedBox(
                  constraints: const BoxConstraints(minWidth: valueMinWidth),
                  child: Center(
                    widthFactor: 1,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.xs,
                      ),
                      child: Text(
                        '$value',
                        style: AppTypography.b4.copyWith(
                          color: onChanged == null
                              ? colors.textGrey
                              : filled
                              ? colors.textSecondaryAccent
                              : colors.textPrimary,
                        ),
                      ),
                    ),
                  ),
                ),
                divider,
              ],
              _Button(
                key: incrementKey,
                icon: AppIcons.plus,
                label: incrementLabel,
                color: iconColor,
                disabledColor: colors.iconLightGrey,
                onTap: _canIncrement ? () => _set(value + step) : null,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _set(int next) => onChanged?.call(next.clamp(min, max));
}

/// One 24 icon with the DS 12 padding on both sides, so it is 48 wide.
class _Button extends StatelessWidget {
  const _Button({
    super.key,
    required this.icon,
    required this.label,
    required this.color,
    required this.disabledColor,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final Color disabledColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    return Semantics(
      button: true,
      enabled: enabled,
      label: label,
      excludeSemantics: true,
      child: MouseRegion(
        cursor: enabled ? SystemMouseCursors.click : MouseCursor.defer,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
            child: Center(
              child: Icon(
                icon,
                size: AppStepper.iconSize,
                color: enabled ? color : disabledColor,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
