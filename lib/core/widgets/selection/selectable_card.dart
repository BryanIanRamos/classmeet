import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart' show SemanticsProperties;

import '../../assets/app_icons.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_radii.dart';
import '../../theme/app_semantic_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import 'selection_support.dart';

/// Which indicator a [SelectableCard] shows at its end.
enum SelectableCardIndicator { checkbox, radio }

/// A tappable tile with a title, an optional description and a checkbox or
/// radio indicator: the study-method cards of "Learning preferences" (98) and
/// the goal grid of "Study routine" (99).
///
/// Unselected it is Sage-50 with grey text and an outlined indicator;
/// selected it is Sage-500 ("Sage-filled") with white text, a 60 % white
/// description, and a Sage-50 indicator holding a Sage-500 mark. Radius 16,
/// padding 12, indicator 24 (8-radius square, or a circle for
/// [SelectableCardIndicator.radio]). The title uses Inter B1 as that screen
/// does; the description is Plus Jakarta Sans C1. A null [onTap] disables
/// the card (Grey-50 fill, grey text).
///
/// The option rows of the quiz screens (grey card with a leading radio or
/// checkbox and a label) are an `AppRadio`/`AppCheckbox` with a label inside
/// a bordered container, not this widget.
class SelectableCard extends StatelessWidget {
  const SelectableCard({
    super.key,
    required this.title,
    required this.selected,
    required this.onTap,
    this.description,
    this.leadingIcon,
    this.indicator = SelectableCardIndicator.checkbox,
    this.indicatorColor = AppColors.sage500,
    this.indicatorFill = AppColors.sage50,
    this.statesController,
  });

  /// Indicator width and height.
  static const indicatorSize = 24.0;

  /// Mark inside a selected checkbox indicator.
  static const markSize = 20.0;

  /// Dot inside a selected radio indicator.
  static const dotSize = 12.0;

  /// Icon size of [leadingIcon].
  static const iconSize = 24.0;

  /// Minimum height of the card (64 on screen 99).
  static const minHeight = 64.0;

  final String title;
  final String? description;
  final IconData? leadingIcon;
  final bool selected;
  final VoidCallback? onTap;
  final SelectableCardIndicator indicator;

  /// Outline of an unselected indicator and the mark of a selected one.
  /// Sage-500 on most screens; 98 uses Plume-500.
  final Color indicatorColor;

  /// Fill of a selected indicator (Sage-50; Plume-50 on 98).
  final Color indicatorFill;
  final WidgetStatesController? statesController;

  @override
  Widget build(BuildContext context) {
    final colors =
        Theme.of(context).extension<AppSemanticColors>() ??
        AppSemanticColors.light;
    return SelectionInteraction(
      statesController: statesController,
      onTap: onTap,
      semantics: SemanticsProperties(
        checked: selected,
        inMutuallyExclusiveGroup: indicator == SelectableCardIndicator.radio,
      ),
      builder: (context, states) {
        final disabled = states.isDisabled;
        final titleColor = disabled
            ? colors.textGrey
            : selected
            ? colors.textPrimaryWhite
            : colors.textPrimary;
        final descriptionColor = selected && !disabled
            ? colors.textSecondaryWhite
            : colors.textSecondary;
        return Container(
          constraints: const BoxConstraints(minHeight: minHeight),
          padding: const EdgeInsets.all(AppSpacing.sm),
          decoration: BoxDecoration(
            color: fill(states),
            borderRadius: const BorderRadius.all(Radius.circular(AppRadii.md)),
            border: states.isFocused && !disabled
                ? Border.all(
                    color: AppColors.sage300,
                    width: selectionFocusRingWidth,
                  )
                : null,
          ),
          child: Row(
            children: [
              if (leadingIcon case final icon?) ...[
                Icon(icon, size: iconSize, color: titleColor),
                const SizedBox(width: AppSpacing.sm),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: AppTypography.interB1.copyWith(color: titleColor),
                    ),
                    if (description case final text?)
                      Text(
                        text,
                        style: AppTypography.c1.copyWith(
                          color: descriptionColor,
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              _indicator(disabled),
            ],
          ),
        );
      },
    );
  }

  /// Card fill for [states]; public for tests.
  Color fill(Set<WidgetState> states) {
    if (states.isDisabled) return AppColors.grey50;
    if (selected) {
      return states.isHovered ? AppColors.sage700 : AppColors.sage500;
    }
    return states.isHovered ? AppColors.sage100 : AppColors.sage50;
  }

  Widget _indicator(bool disabled) {
    final isRadio = indicator == SelectableCardIndicator.radio;
    final accent = disabled ? AppColors.grey200 : indicatorColor;
    final BoxShape shape = isRadio ? BoxShape.circle : BoxShape.rectangle;
    final radius = isRadio
        ? null
        : const BorderRadius.all(Radius.circular(AppRadii.xs));
    return Container(
      key: const ValueKey('card-indicator'),
      width: indicatorSize,
      height: indicatorSize,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: shape,
        borderRadius: radius,
        color: selected ? indicatorFill : Colors.transparent,
        border: selected
            ? null
            : Border.all(color: accent, width: selectionBorderWidth),
      ),
      child: selected
          ? (isRadio
                ? Container(
                    width: dotSize,
                    height: dotSize,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: accent,
                    ),
                  )
                : Icon(AppIcons.check, size: markSize, color: accent))
          : null,
    );
  }
}
