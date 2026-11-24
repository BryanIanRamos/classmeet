import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart' show SemanticsProperties;

import '../../assets/app_icons.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_radii.dart';
import 'selection_support.dart';

/// Size of an [AppCheckbox] with the measurements of each.
///
/// The DS Checkbox sheet (5248:1446) has no Size axis, only the 24 box;
/// [medium] is that box. [small] is an assumption (20 box, scaled radius and
/// icon) for dense lists, to be confirmed against the screens.
enum AppCheckboxSize {
  medium(box: 24, radius: AppRadii.xs, iconSize: 20),
  small(box: 20, radius: 6, iconSize: 16);

  const AppCheckboxSize({
    required this.box,
    required this.radius,
    required this.iconSize,
  });

  /// Outer width and height.
  final double box;

  /// Corner radius.
  final double radius;

  /// Size of the check or minus mark.
  final double iconSize;
}

/// The ClassMeet checkbox (DS Checkbox 5248:1446, and `Checkbox + Text`).
///
/// [value] is true (checked), false (unchecked) or null (indeterminate).
/// A tap calls `onChanged(!(value ?? false))`: indeterminate and unchecked
/// become checked, checked becomes unchecked. A null [onChanged] disables
/// it. With a [label] it becomes the `Checkbox + Text` variant, placed per
/// [textSide].
///
/// Geometry is from the DS (24 box, 1.5 border, 20 icon, focus ring spread
/// 3). The corner radius is 8 as on the screens and the left DS variants (the
/// right-side variants show 6). Colours are from the screens: Sage-500 in
/// place of the kit blue, hover Sage-50, focus ring Sage-300, disabled
/// Grey-200. The hover and disabled steps of a checked box are not in the DS;
/// they use Sage-700 and a Grey-200 fill (assumption).
class AppCheckbox extends StatelessWidget {
  const AppCheckbox({
    super.key,
    required this.value,
    required this.onChanged,
    this.size = AppCheckboxSize.medium,
    this.label,
    this.textSide = AppTextSide.left,
    this.statesController,
  });

  final bool? value;
  final ValueChanged<bool>? onChanged;
  final AppCheckboxSize size;
  final String? label;
  final AppTextSide textSide;
  final WidgetStatesController? statesController;

  bool get _filled => value != false;

  @override
  Widget build(BuildContext context) {
    final onChanged = this.onChanged;
    return SelectionInteraction(
      statesController: statesController,
      onTap: onChanged == null ? null : () => onChanged(!(value ?? false)),
      semantics: SemanticsProperties(
        checked: value ?? false,
        mixed: value == null,
      ),
      builder: (context, states) => SelectionRow(
        control: _box(states),
        label: label,
        textSide: textSide,
        disabled: states.isDisabled,
      ),
    );
  }

  /// Fill colour for [states]; public for tests.
  Color fillColor(Set<WidgetState> states) {
    if (_filled) {
      if (states.isDisabled) return AppColors.grey200;
      return states.isHovered ? AppColors.sage700 : AppColors.sage500;
    }
    if (states.isDisabled) return Colors.transparent;
    if (states.isFocused) return AppColors.white;
    if (states.isHovered) return AppColors.sage50;
    return Colors.transparent;
  }

  /// Border colour for [states]; public for tests.
  Color borderColor(Set<WidgetState> states) {
    if (_filled) return fillColor(states);
    return states.isDisabled ? AppColors.grey200 : AppColors.sage500;
  }

  Widget _box(Set<WidgetState> states) {
    return Container(
      width: size.box,
      height: size.box,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(size.radius)),
        color: fillColor(states),
        border: Border.all(
          color: borderColor(states),
          width: selectionBorderWidth,
        ),
        boxShadow: states.isFocused && !states.isDisabled
            ? const [selectionFocusRing]
            : null,
      ),
      child: _filled
          ? Icon(
              value == null ? AppIcons.minus : AppIcons.check,
              size: size.iconSize,
              color: AppColors.white,
            )
          : null,
    );
  }
}
