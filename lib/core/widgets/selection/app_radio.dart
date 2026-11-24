import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart' show SemanticsProperties;

import '../../theme/app_colors.dart';
import 'selection_support.dart';

/// The ClassMeet radio button (DS Radio 5248:1974, and `Radio + Text`).
///
/// [value] is selected when it equals [groupValue]. Pass a null [onChanged]
/// to disable it; tapping an unselected radio calls `onChanged(value)`. With
/// a [label] it becomes the `Radio + Text` variant, placed per [textSide].
///
/// Geometry is from the DS (24x24 circle, 1.5 border, 12 dot, focus ring
/// spread 3). Colours are from the screens (border and dot Sage-500, which
/// the DS sheet shows as the kit blue): hover Sage-50 fill, focus white fill
/// with a Sage-300 ring, disabled Grey-200. [activeColor] overrides the
/// Sage-500 for answer states (Sprout-500 correct, Talon-500 revealed). The
/// label uses Plus Jakarta Sans B1 as on the screens, not the kit's Inter.
class AppRadio<T> extends StatelessWidget {
  const AppRadio({
    super.key,
    required this.value,
    required this.groupValue,
    required this.onChanged,
    this.label,
    this.textSide = AppTextSide.left,
    this.activeColor = AppColors.sage500,
    this.statesController,
  });

  /// Outer diameter.
  static const size = 24.0;

  /// Diameter of the selected dot.
  static const dotSize = 12.0;

  final T value;
  final T? groupValue;
  final ValueChanged<T>? onChanged;
  final String? label;
  final AppTextSide textSide;
  final Color activeColor;
  final WidgetStatesController? statesController;

  bool get _selected => value == groupValue;

  @override
  Widget build(BuildContext context) {
    final onChanged = this.onChanged;
    return SelectionInteraction(
      statesController: statesController,
      onTap: onChanged == null
          ? null
          : () {
              if (!_selected) onChanged(value);
            },
      semantics: SemanticsProperties(
        checked: _selected,
        inMutuallyExclusiveGroup: true,
      ),
      builder: (context, states) => SelectionRow(
        control: _circle(states),
        label: label,
        textSide: textSide,
        disabled: states.isDisabled,
      ),
    );
  }

  /// Border colour for [states]; public for tests.
  Color borderColor(Set<WidgetState> states) =>
      states.isDisabled ? AppColors.grey200 : activeColor;

  /// Fill colour for [states]; public for tests.
  Color fillColor(Set<WidgetState> states) {
    if (states.isDisabled) return Colors.transparent;
    if (states.isFocused) return AppColors.white;
    if (states.isHovered) return AppColors.sage50;
    return Colors.transparent;
  }

  Widget _circle(Set<WidgetState> states) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: fillColor(states),
        border: Border.all(
          color: borderColor(states),
          width: selectionBorderWidth,
        ),
        boxShadow: states.isFocused && !states.isDisabled
            ? const [selectionFocusRing]
            : null,
      ),
      child: _selected
          ? Container(
              key: const ValueKey('radio-dot'),
              width: dotSize,
              height: dotSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: borderColor(states),
              ),
            )
          : null,
    );
  }
}
