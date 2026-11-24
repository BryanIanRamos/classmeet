import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_radii.dart';
import '../../theme/app_semantic_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';

/// Figma "Size" axis of the Design System Badge & Chip (5248:1220).
///
/// The DS text sizes (14/16, 12/16, 10/12 SemiBold) are the Button text
/// styles, so the badge reuses them.
enum AppBadgeSize {
  medium(
    height: 40,
    padding: AppSpacing.sm,
    iconSize: 24,
    radius: AppRadii.sm,
    labelPadding: AppSpacing.xs,
    textStyle: AppTypography.buttonMedium,
  ),
  small(
    height: 32,
    padding: AppSpacing.sm,
    iconSize: 24,
    radius: AppRadii.xs,
    labelPadding: AppSpacing.xs,
    textStyle: AppTypography.buttonSmall,
  ),

  /// The only size the screens use ("+2", "40% read", "In progress"). Screens
  /// show no padding around the label, unlike the DS sheet's 8.
  tiny(
    height: 24,
    padding: AppSpacing.xs,
    iconSize: 16,
    radius: AppRadii.xs,
    labelPadding: AppSpacing.none,
    textStyle: AppTypography.buttonTiny,
  );

  const AppBadgeSize({
    required this.height,
    required this.padding,
    required this.iconSize,
    required this.radius,
    required this.labelPadding,
    required this.textStyle,
  });

  final double height;

  /// Horizontal padding between the edge and the content.
  final double padding;

  final double iconSize;
  final double radius;

  /// Padding on each side of the label.
  final double labelPadding;

  final TextStyle textStyle;
}

/// Figma "State" axis of the DS Badge & Chip (default, success, info,
/// warning, error), plus [neutral] for the grey badge on screens.
///
/// Each tone carries the Sage-based palette that replaces the UI kit's colours
/// (default blue → sage, success → sprout, info → sky, warning → talon,
/// error → ember).
enum AppBadgeTone {
  neutral(
    tint50: AppColors.grey50,
    tint100: AppColors.grey200,
    strong: AppColors.grey500,
    softText: AppColors.grey500,
  ),
  accent(
    tint50: AppColors.sage50,
    tint100: AppColors.sage100,
    strong: AppColors.sage500,
    softText: AppColors.sage500,
  ),
  success(
    tint50: AppColors.sprout50,
    tint100: AppColors.sprout100,
    strong: AppColors.sprout500,
    softText: AppColors.sprout900,
  ),
  info(
    tint50: AppColors.sky50,
    tint100: AppColors.sky100,
    strong: AppColors.sky500,
    softText: AppColors.sky900,
  ),
  warning(
    tint50: AppColors.talon50,
    tint100: AppColors.talon100,
    strong: AppColors.talon500,
    softText: AppColors.talon900,
  ),
  error(
    tint50: AppColors.ember50,
    tint100: AppColors.ember100,
    strong: AppColors.ember500,
    softText: AppColors.ember700,
  );

  const AppBadgeTone({
    required this.tint50,
    required this.tint100,
    required this.strong,
    required this.softText,
  });

  /// Fill of the outline style.
  final Color tint50;

  /// Fill of the soft style.
  final Color tint100;

  /// Fill of the filled style, border and text of the outline style.
  final Color strong;

  /// Text colour on the soft fill (the 900 shade, or Ember-700 as Ember has
  /// no 900).
  final Color softText;
}

/// Figma "Style" axis of the DS Badge & Chip, with the screens' soft look.
enum AppBadgeStyle {
  /// Tint-100 fill with a dark label: the badges on screens.
  soft,

  /// Solid tone fill with a white label: the DS "Filled".
  filled,

  /// Tint-50 fill with a tone border and label: the DS "Outline".
  outline,

  /// No fill, a tone-coloured label: the talon cost count next to a coin.
  clear,
}

/// The ClassMeet badge: a small status label with optional leading and
/// trailing icons, or icon-only with [AppBadge.icon].
///
/// Geometry is from the DS component. Colours are from the screens (soft
/// tint-100 fill, e.g. "24 talons" Talon-100 with Talon-900 text, "40% read"
/// grey), and the DS kit colours are translated to the Sage palette.
/// Badges are not interactive.
class AppBadge extends StatelessWidget {
  /// A badge with a [label] and optional icons.
  const AppBadge({
    super.key,
    required String this.label,
    this.size = AppBadgeSize.tiny,
    this.tone = AppBadgeTone.accent,
    this.style = AppBadgeStyle.soft,
    this.leadingIcon,
    this.trailingIcon,
  }) : icon = null,
       semanticLabel = null;

  /// A square, icon-only badge. [semanticLabel] is read by screen readers.
  const AppBadge.icon({
    super.key,
    required IconData this.icon,
    required String this.semanticLabel,
    this.size = AppBadgeSize.tiny,
    this.tone = AppBadgeTone.accent,
    this.style = AppBadgeStyle.soft,
  }) : label = null,
       leadingIcon = null,
       trailingIcon = null;

  /// Border width of the outline style.
  static const outlineBorderWidth = 1.5;

  final String? label;
  final IconData? icon;
  final String? semanticLabel;
  final AppBadgeSize size;
  final AppBadgeTone tone;
  final AppBadgeStyle style;
  final IconData? leadingIcon;
  final IconData? trailingIcon;

  /// Fill colour for [style] and [tone]; public for tests.
  Color get background => switch (style) {
    AppBadgeStyle.soft => tone.tint100,
    AppBadgeStyle.filled => tone.strong,
    AppBadgeStyle.outline => tone.tint50,
    AppBadgeStyle.clear => Colors.transparent,
  };

  /// Label and icon colour for [style] and [tone]; public for tests.
  Color foreground(AppSemanticColors colors) => switch (style) {
    AppBadgeStyle.soft => tone.softText,
    AppBadgeStyle.filled => colors.textPrimaryWhite,
    AppBadgeStyle.outline || AppBadgeStyle.clear => tone.strong,
  };

  @override
  Widget build(BuildContext context) {
    final color = foreground(context.colors);
    final iconOnly = icon != null;
    return Semantics(
      container: true,
      label: semanticLabel,
      child: Container(
        height: size.height,
        width: iconOnly ? size.height : null,
        padding: EdgeInsets.symmetric(horizontal: iconOnly ? 0 : size.padding),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(size.radius),
          border: style == AppBadgeStyle.outline
              ? Border.all(color: tone.strong, width: outlineBorderWidth)
              : null,
        ),
        child: IconTheme(
          data: IconThemeData(color: color, size: size.iconSize),
          child: DefaultTextStyle(
            style: size.textStyle.copyWith(color: color),
            child: iconOnly ? Center(child: Icon(icon)) : _content(),
          ),
        ),
      ),
    );
  }

  Widget _content() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (leadingIcon case final leading?) Icon(leading),
        Flexible(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: size.labelPadding),
            child: Text(label!, maxLines: 1, overflow: TextOverflow.ellipsis),
          ),
        ),
        if (trailingIcon case final trailing?) Icon(trailing),
      ],
    );
  }
}
