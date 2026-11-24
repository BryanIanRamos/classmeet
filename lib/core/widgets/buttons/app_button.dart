import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_radii.dart';
import '../../theme/app_semantic_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';

/// Figma "Size" axis of the Design System Button (5248:660), with the
/// measurements of each size.
enum AppButtonSize {
  giant(
    height: 56,
    padding: AppSpacing.xl,
    iconSize: 24,
    textStyle: AppTypography.buttonGiant,
  ),
  large(
    height: 48,
    padding: AppSpacing.lg,
    iconSize: 24,
    textStyle: AppTypography.buttonLarge,
  ),
  medium(
    height: 40,
    padding: AppSpacing.md,
    iconSize: 24,
    textStyle: AppTypography.buttonMedium,
  ),
  small(
    height: 32,
    padding: AppSpacing.sm,
    iconSize: 24,
    textStyle: AppTypography.buttonSmall,
  ),
  tiny(
    height: 24,
    padding: AppSpacing.xs,
    iconSize: 16,
    textStyle: AppTypography.buttonTiny,
  );

  const AppButtonSize({
    required this.height,
    required this.padding,
    required this.iconSize,
    required this.textStyle,
  });

  /// Fixed height. Icon-only buttons are square.
  final double height;

  /// Horizontal padding between the edge and the content.
  final double padding;

  final double iconSize;
  final TextStyle textStyle;
}

/// Figma "Style" axis of the Design System Button.
enum AppButtonStyle { filled, outline, clear }

/// Colour family of a button. Sage is the default (Home 8); screens also use
/// Plume (95 "Continue with Carsu", 92, 119, 122), Talon (13.1 "Join") and
/// Sky (14). Each tone applies the DS state pattern with its own ramp. The
/// palette has no Plume-700/900, so a Plume button keeps Plume-500 when
/// hovered or pressed (INC-12).
enum AppButtonTone {
  sage(
    AppColors.sage500,
    AppColors.sage700,
    AppColors.sage900,
    AppColors.sage300,
    AppColors.sage50,
    AppColors.sage100,
  ),
  plume(
    AppColors.plume500,
    AppColors.plume500,
    AppColors.plume500,
    AppColors.plume300,
    AppColors.plume50,
    AppColors.plume100,
  ),
  talon(
    AppColors.talon500,
    AppColors.talon700,
    AppColors.talon900,
    AppColors.talon300,
    AppColors.talon50,
    AppColors.talon100,
  ),
  sky(
    AppColors.sky500,
    AppColors.sky700,
    AppColors.sky900,
    AppColors.sky300,
    AppColors.sky50,
    AppColors.sky100,
  );

  const AppButtonTone(
    this.base,
    this.hovered,
    this.pressed,
    this.focusRing,
    this.tint,
    this.pressedTint,
  );

  /// Filled background, outline border, and outline/clear label.
  final Color base;

  /// Filled background when hovered / pressed.
  final Color hovered;
  final Color pressed;

  /// Focus ring.
  final Color focusRing;

  /// Outline/clear background when hovered / pressed.
  final Color tint;
  final Color pressedTint;
}

/// The ClassMeet button: [AppButtonSize] × [AppButtonStyle], with a label and
/// optional leading and trailing icons, or icon-only with [AppButton.icon].
///
/// Pass a null [onPressed] to disable it. States (hover, focus, press,
/// disabled) follow the Design System pattern; pass a
/// [statesController] to show a state without interaction (galleries,
/// goldens).
///
/// Geometry is from the DS component. Colours and the pill radius are from
/// the screens (Home 8, "Continue studying": Sage-500, white Button/Large,
/// radius 32), because the DS sheet still shows the UI kit's blue. The hover,
/// press, focus and disabled steps apply the DS pattern in the Sage palette;
/// confirm them after the harvest (task 1.4, INC-6).
class AppButton extends StatelessWidget {
  /// A button with a [label] and optional icons on either side.
  const AppButton({
    super.key,
    required String this.label,
    required this.onPressed,
    this.size = AppButtonSize.large,
    this.style = AppButtonStyle.filled,
    this.tone = AppButtonTone.sage,
    this.leadingIcon,
    this.trailingIcon,
    this.expand = false,
    this.statesController,
  }) : icon = null,
       semanticLabel = null;

  /// A square, icon-only button. [semanticLabel] is read by screen readers.
  const AppButton.icon({
    super.key,
    required IconData this.icon,
    required String this.semanticLabel,
    required this.onPressed,
    this.size = AppButtonSize.large,
    this.style = AppButtonStyle.filled,
    this.tone = AppButtonTone.sage,
    this.statesController,
  }) : label = null,
       leadingIcon = null,
       trailingIcon = null,
       expand = false;

  /// Inside the label's sides, as in the DS "Text" wrapper.
  static const labelPadding = AppSpacing.xs;

  /// Width of the focus ring, drawn inside the edge.
  static const focusBorderWidth = 3.0;

  /// Border width of the outline style.
  static const outlineBorderWidth = 1.5;

  final String? label;
  final IconData? icon;
  final String? semanticLabel;
  final VoidCallback? onPressed;
  final AppButtonSize size;
  final AppButtonStyle style;
  final IconData? leadingIcon;
  final IconData? trailingIcon;

  /// Stretch to the full available width, as in the Home hero card.
  final bool expand;

  final WidgetStatesController? statesController;

  final AppButtonTone tone;

  bool get _iconOnly => icon != null;

  @override
  Widget build(BuildContext context) {
    final button = TextButton(
      onPressed: onPressed,
      statesController: statesController,
      style: buttonStyle(context.colors),
      child: _content(),
    );
    return expand ? SizedBox(width: double.infinity, child: button) : button;
  }

  /// The resolved [ButtonStyle]; public so tests can check each state.
  ButtonStyle buttonStyle(AppSemanticColors colors) {
    final height = size.height;
    return ButtonStyle(
      textStyle: WidgetStatePropertyAll(size.textStyle),
      backgroundColor: WidgetStateProperty.resolveWith(_background),
      foregroundColor: WidgetStateProperty.resolveWith(
        (states) => _foreground(states, colors),
      ),
      iconColor: WidgetStateProperty.resolveWith(
        (states) => _foreground(states, colors),
      ),
      iconSize: WidgetStatePropertyAll(size.iconSize),
      side: WidgetStateProperty.resolveWith(_side),
      shape: const WidgetStatePropertyAll(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(AppRadii.xxl)),
        ),
      ),
      padding: WidgetStatePropertyAll(
        EdgeInsets.symmetric(horizontal: _iconOnly ? 0 : size.padding),
      ),
      minimumSize: WidgetStatePropertyAll(Size.square(height)),
      maximumSize: WidgetStatePropertyAll(
        _iconOnly ? Size.square(height) : Size(double.infinity, height),
      ),
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
    final disabled = states.contains(WidgetState.disabled);
    final pressed = states.contains(WidgetState.pressed);
    final hovered = states.contains(WidgetState.hovered);
    return switch (style) {
      AppButtonStyle.filled when disabled => AppColors.grey200,
      AppButtonStyle.filled when pressed => tone.pressed,
      AppButtonStyle.filled when hovered => tone.hovered,
      AppButtonStyle.filled => tone.base,
      _ when disabled => Colors.transparent,
      _ when pressed => tone.pressedTint,
      _ when hovered => tone.tint,
      _ => Colors.transparent,
    };
  }

  Color _foreground(Set<WidgetState> states, AppSemanticColors colors) {
    if (states.contains(WidgetState.disabled)) return colors.textGrey;
    if (style == AppButtonStyle.filled) return colors.textPrimaryWhite;
    return tone == AppButtonTone.sage ? colors.textSecondaryAccent : tone.base;
  }

  BorderSide _side(Set<WidgetState> states) {
    final outline = style == AppButtonStyle.outline;
    if (states.contains(WidgetState.disabled)) {
      return outline
          ? const BorderSide(
              color: AppColors.grey200,
              width: outlineBorderWidth,
            )
          : BorderSide.none;
    }
    if (states.contains(WidgetState.focused)) {
      return BorderSide(color: tone.focusRing, width: focusBorderWidth);
    }
    return outline
        ? BorderSide(color: tone.base, width: outlineBorderWidth)
        : BorderSide.none;
  }

  Widget _content() {
    if (icon case final icon?) {
      return Icon(icon, semanticLabel: semanticLabel);
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (leadingIcon case final leading?) Icon(leading),
        Flexible(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: labelPadding),
            child: Text(label!, maxLines: 1, overflow: TextOverflow.ellipsis),
          ),
        ),
        if (trailingIcon case final trailing?) Icon(trailing),
      ],
    );
  }
}
