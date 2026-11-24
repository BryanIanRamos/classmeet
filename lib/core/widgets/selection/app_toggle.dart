import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart' show SemanticsProperties;

import '../../theme/app_colors.dart';
import '../../theme/app_radii.dart';
import 'selection_support.dart';

/// The ClassMeet toggle switch (DS Toggle 5248:2021, and `Toggle + Text`).
///
/// A tap calls `onChanged(!value)`; a null [onChanged] disables it. With a
/// [label] it becomes the `Toggle + Text` variant, placed per [textSide].
///
/// Geometry is from the DS (44x24 pill, 20 white knob, 2 inset, focus ring
/// spread 3). Colours: the "on" track is Plume-500 as on the quiz screens
/// (the DS sheet shows the kit blue); the off track steps Grey-200, hover
/// Grey-300 as in the DS. The DS has no "on" hover or disabled-on colour in
/// the app palette: hover-on keeps Plume-500 and disabled-on uses Plume-50
/// (the kit's light tint), disabled-off Grey-100 (the DS "Selected" off
/// variant, which the sheet labels Disabled). The focus ring is Sage-300.
class AppToggle extends StatelessWidget {
  const AppToggle({
    super.key,
    required this.value,
    required this.onChanged,
    this.label,
    this.textSide = AppTextSide.left,
    this.statesController,
  });

  static const width = 44.0;
  static const height = 24.0;
  static const knobSize = 20.0;
  static const knobInset = 2.0;

  final bool value;
  final ValueChanged<bool>? onChanged;
  final String? label;
  final AppTextSide textSide;
  final WidgetStatesController? statesController;

  @override
  Widget build(BuildContext context) {
    final onChanged = this.onChanged;
    return SelectionInteraction(
      statesController: statesController,
      onTap: onChanged == null ? null : () => onChanged(!value),
      semantics: SemanticsProperties(toggled: value),
      builder: (context, states) => SelectionRow(
        control: _track(states),
        label: label,
        textSide: textSide,
        disabled: states.isDisabled,
      ),
    );
  }

  /// Track colour for [states]; public for tests.
  Color trackColor(Set<WidgetState> states) {
    if (value) {
      return states.isDisabled ? AppColors.plume50 : AppColors.plume500;
    }
    if (states.isDisabled) return AppColors.grey100;
    return states.isHovered ? AppColors.grey300 : AppColors.grey200;
  }

  Widget _track(Set<WidgetState> states) {
    return Container(
      width: width,
      height: height,
      padding: const EdgeInsets.all(knobInset),
      alignment: value ? Alignment.centerRight : Alignment.centerLeft,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(AppRadii.sm)),
        color: trackColor(states),
        boxShadow: states.isFocused && !states.isDisabled
            ? const [selectionFocusRing]
            : null,
      ),
      child: Container(
        key: const ValueKey('toggle-knob'),
        width: knobSize,
        height: knobSize,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.white,
        ),
      ),
    );
  }
}
