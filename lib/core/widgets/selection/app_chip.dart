import 'package:flutter/material.dart';

import '../../assets/app_icons.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_radii.dart';
import '../../theme/app_semantic_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';

/// How a chip behaves.
enum AppChipKind {
  /// Toggles on and off on its own, e.g. a filter.
  filter,

  /// One chip of a group is selected: tapping the selected chip does nothing,
  /// tapping another reports `true`. The group owner clears the old one.
  choice,

  /// Several chips of a group can be on; the selected one shows a check mark.
  multiSelect,
}

/// The two chip looks from the screens.
///
/// The DS Badge & Chip sheet has no selectable chip (its "chip" is the badge
/// with a trailing x), so both looks come from the screens.
enum AppChipStyle {
  /// 36 high pill with a Sage-500 outline when off: the quiz-results
  /// "Friend / Class / Link" tabs and the "All" filter chips (Input,
  /// Size=Medium).
  outline(
    height: 36,
    padding: AppSpacing.md,
    radius: AppRadii.xxl,
    textStyle: AppTypography.b3,
  ),

  /// 32 high tab with a grey fill when off: "All / Classes / Materials /
  /// People" in Search and Notifications (Navbar Top, middle item).
  tonal(
    height: 32,
    padding: AppSpacing.sm,
    radius: AppRadii.md,
    textStyle: AppTypography.b2,
  ),

  /// 36 high pill, white with a Grey-200 outline and Grey-500 text when off:
  /// the choice chips of the onboarding steps (96 year level, 97 subjects,
  /// 99 routine), quiz setup (115), Explain (91) and Listen (89). Selected
  /// it fills Sage-500 like the others.
  neutral(
    height: 36,
    padding: AppSpacing.md,
    radius: AppRadii.xxl,
    textStyle: AppTypography.b3,
  );

  const AppChipStyle({
    required this.height,
    required this.padding,
    required this.radius,
    required this.textStyle,
  });

  final double height;

  /// Horizontal padding between the edge and the content.
  final double padding;

  final double radius;
  final TextStyle textStyle;
}

/// The ClassMeet chip: a selectable pill with a label, an optional leading
/// icon and an optional remove (x) affordance.
///
/// Build it with [AppChip.filter], [AppChip.choice] or [AppChip.multiSelect].
/// A null [onSelected] disables it. Selected chips fill with
/// [selectedColor] (Sage-500) and show white text. Unselected ones follow
/// [style]. Hover, press and focus steps follow the AppButton pattern in the
/// Sage palette (not in the DS, which has no chip states). Pass a
/// [statesController] to show a state without interaction.
class AppChip extends StatelessWidget {
  const AppChip._({
    super.key,
    required this.kind,
    required this.label,
    required this.selected,
    required this.onSelected,
    required this.style,
    required this.leadingIcon,
    required this.onDeleted,
    required this.selectedColor,
    required this.statesController,
  });

  /// A chip that toggles itself on and off.
  const AppChip.filter({
    Key? key,
    required String label,
    required bool selected,
    required ValueChanged<bool>? onSelected,
    AppChipStyle style = AppChipStyle.outline,
    IconData? leadingIcon,
    VoidCallback? onDeleted,
    Color selectedColor = AppColors.sage500,
    WidgetStatesController? statesController,
  }) : this._(
         key: key,
         kind: AppChipKind.filter,
         label: label,
         selected: selected,
         onSelected: onSelected,
         style: style,
         leadingIcon: leadingIcon,
         onDeleted: onDeleted,
         selectedColor: selectedColor,
         statesController: statesController,
       );

  /// A chip in a single-selection group.
  const AppChip.choice({
    Key? key,
    required String label,
    required bool selected,
    required ValueChanged<bool>? onSelected,
    AppChipStyle style = AppChipStyle.outline,
    IconData? leadingIcon,
    VoidCallback? onDeleted,
    Color selectedColor = AppColors.sage500,
    WidgetStatesController? statesController,
  }) : this._(
         key: key,
         kind: AppChipKind.choice,
         label: label,
         selected: selected,
         onSelected: onSelected,
         style: style,
         leadingIcon: leadingIcon,
         onDeleted: onDeleted,
         selectedColor: selectedColor,
         statesController: statesController,
       );

  /// A chip in a multiple-selection group; shows a check when selected.
  const AppChip.multiSelect({
    Key? key,
    required String label,
    required bool selected,
    required ValueChanged<bool>? onSelected,
    AppChipStyle style = AppChipStyle.outline,
    IconData? leadingIcon,
    VoidCallback? onDeleted,
    Color selectedColor = AppColors.sage500,
    WidgetStatesController? statesController,
  }) : this._(
         key: key,
         kind: AppChipKind.multiSelect,
         label: label,
         selected: selected,
         onSelected: onSelected,
         style: style,
         leadingIcon: leadingIcon,
         onDeleted: onDeleted,
         selectedColor: selectedColor,
         statesController: statesController,
       );

  /// Border width of the outline style and the focus ring's inner edge.
  static const borderWidth = 1.5;

  /// Width of the focus ring, drawn inside the edge.
  static const focusBorderWidth = 3.0;

  /// Size of the leading, check and remove icons.
  static const iconSize = 16.0;

  /// Gap between the icons and the label.
  static const gap = AppSpacing.xs;

  final AppChipKind kind;
  final String label;
  final bool selected;

  /// Called with the new selected value; null disables the chip.
  final ValueChanged<bool>? onSelected;

  final AppChipStyle style;
  final IconData? leadingIcon;

  /// Shows a trailing x that calls this when tapped.
  final VoidCallback? onDeleted;

  final Color selectedColor;
  final WidgetStatesController? statesController;

  bool get enabled => onSelected != null;

  void _handleTap() {
    final callback = onSelected;
    if (callback == null) return;
    switch (kind) {
      case AppChipKind.choice:
        if (!selected) callback(true);
      case AppChipKind.filter:
      case AppChipKind.multiSelect:
        callback(!selected);
    }
  }

  @override
  Widget build(BuildContext context) {
    final chip = TextButton(
      onPressed: enabled ? _handleTap : null,
      statesController: statesController,
      style: buttonStyle(context.colors),
      child: _content(),
    );
    return Semantics(
      selected: selected,
      inMutuallyExclusiveGroup: kind == AppChipKind.choice ? true : null,
      child: chip,
    );
  }

  /// The resolved [ButtonStyle]; public so tests can check each state.
  ButtonStyle buttonStyle(AppSemanticColors colors) {
    return ButtonStyle(
      textStyle: WidgetStatePropertyAll(style.textStyle),
      backgroundColor: WidgetStateProperty.resolveWith(_background),
      foregroundColor: WidgetStateProperty.resolveWith(
        (states) => _foreground(states, colors),
      ),
      iconColor: WidgetStateProperty.resolveWith(
        (states) => _foreground(states, colors),
      ),
      iconSize: const WidgetStatePropertyAll(iconSize),
      side: WidgetStateProperty.resolveWith(_side),
      shape: WidgetStatePropertyAll(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(style.radius),
        ),
      ),
      padding: WidgetStatePropertyAll(
        EdgeInsets.symmetric(horizontal: style.padding),
      ),
      minimumSize: WidgetStatePropertyAll(Size(0, style.height)),
      maximumSize: WidgetStatePropertyAll(Size(double.infinity, style.height)),
      overlayColor: const WidgetStatePropertyAll(Colors.transparent),
      splashFactory: NoSplash.splashFactory,
      elevation: const WidgetStatePropertyAll(0),
      shadowColor: const WidgetStatePropertyAll(Colors.transparent),
      surfaceTintColor: const WidgetStatePropertyAll(Colors.transparent),
      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      visualDensity: VisualDensity.standard,
    );
  }

  Color _background(Set<WidgetState> states) {
    final pressed = states.contains(WidgetState.pressed);
    final hovered = states.contains(WidgetState.hovered);
    if (!enabled) {
      return style == AppChipStyle.tonal && !selected
          ? AppColors.grey100
          : Colors.transparent;
    }
    if (selected) {
      if (selectedColor != AppColors.sage500) return selectedColor;
      if (pressed) return AppColors.sage900;
      if (hovered) return AppColors.sage700;
      return selectedColor;
    }
    return switch (style) {
      AppChipStyle.outline when pressed => AppColors.sage100,
      AppChipStyle.outline when hovered => AppColors.sage50,
      AppChipStyle.outline => Colors.transparent,
      AppChipStyle.tonal when pressed => AppColors.grey300,
      AppChipStyle.tonal when hovered => AppColors.grey200,
      AppChipStyle.tonal => AppColors.grey100,
      AppChipStyle.neutral when pressed => AppColors.grey100,
      AppChipStyle.neutral when hovered => AppColors.grey50,
      AppChipStyle.neutral => AppColors.white,
    };
  }

  Color _foreground(Set<WidgetState> states, AppSemanticColors colors) {
    if (!enabled) return colors.textGrey;
    if (selected) return colors.textPrimaryWhite;
    return switch (style) {
      AppChipStyle.outline => colors.textSecondaryAccent,
      AppChipStyle.tonal || AppChipStyle.neutral => colors.textSecondary,
    };
  }

  BorderSide _side(Set<WidgetState> states) {
    if (!enabled) {
      return style == AppChipStyle.tonal
          ? BorderSide.none
          : const BorderSide(color: AppColors.grey200, width: borderWidth);
    }
    if (states.contains(WidgetState.focused)) {
      return const BorderSide(
        color: AppColors.sage300,
        width: focusBorderWidth,
      );
    }
    return switch (style) {
      AppChipStyle.outline => BorderSide(
        color: selected ? selectedColor : AppColors.sage500,
        width: borderWidth,
      ),
      AppChipStyle.neutral => BorderSide(
        color: selected ? selectedColor : AppColors.grey200,
        width: borderWidth,
      ),
      AppChipStyle.tonal => BorderSide.none,
    };
  }

  Widget _content() {
    final leading = leadingIcon;
    final showCheck = kind == AppChipKind.multiSelect && selected;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (showCheck) ...[
          const Icon(AppIcons.check, size: iconSize),
          const SizedBox(width: gap),
        ] else if (leading != null) ...[
          Icon(leading, size: iconSize),
          const SizedBox(width: gap),
        ],
        Flexible(
          child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
        ),
        if (onDeleted case final onDeleted?) ...[
          const SizedBox(width: gap),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: enabled ? onDeleted : null,
            child: const Icon(AppIcons.x, size: iconSize),
          ),
        ],
      ],
    );
  }
}
