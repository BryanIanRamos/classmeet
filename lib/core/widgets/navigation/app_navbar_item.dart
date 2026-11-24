import 'package:flutter/material.dart';

import '../../theme/app_semantic_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';

/// One action in an [AppNavbarTop] side slot: an icon, a text label, or both
/// (the DS "Icons" and "Text + Icon" content variants of the Left and Right
/// items, Figma 5248:1785).
///
/// The item carries its own tap padding (8 horizontal, 12 vertical), so a
/// 24dp icon sits 16dp from the screen edge and the 48dp tall hit area fills
/// the bar. Icon-only items need a semantic label.
class AppNavbarItem extends StatelessWidget {
  /// An icon-only item, e.g. the back chevron or the Home bell.
  const AppNavbarItem.icon({
    super.key,
    required IconData this.icon,
    required String this.semanticLabel,
    required this.onTap,
    this.iconColor,
  }) : label = null,
       trailingIcon = null;

  /// A text item with an optional [icon] before and [trailingIcon] after the
  /// label.
  const AppNavbarItem.text({
    super.key,
    required String this.label,
    required this.onTap,
    this.iconColor,
    this.icon,
    this.trailingIcon,
  }) : semanticLabel = null;

  /// Icon glyph size (DS icon instances are 24x24).
  static const iconSize = 24.0;

  /// Gap between an icon and the label (DS "Text + Icon" gap).
  static const labelGap = AppSpacing.xxs;

  /// Padding around the content, which is also the tap target.
  static const padding = EdgeInsets.symmetric(
    horizontal: AppSpacing.xs,
    vertical: AppSpacing.sm,
  );

  final IconData? icon;
  final IconData? trailingIcon;
  final String? label;
  final String? semanticLabel;

  /// Overrides the icon colour (DS sheet icons are grey-400).
  final Color? iconColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final label = this.label;
    final children = <Widget>[
      if (icon case final icon?)
        Icon(icon, size: iconSize, color: _iconColor(colors)),
      if (icon != null && label != null) const SizedBox(width: labelGap),
      if (label != null)
        Flexible(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.b1.copyWith(color: colors.textPrimary),
          ),
        ),
      if (trailingIcon case final trailing?) ...[
        const SizedBox(width: labelGap),
        Icon(trailing, size: iconSize, color: _iconColor(colors)),
      ],
    ];
    return Semantics(
      button: true,
      label: semanticLabel,
      container: true,
      excludeSemantics: semanticLabel != null,
      onTap: onTap,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Padding(
          padding: padding,
          child: Row(mainAxisSize: MainAxisSize.min, children: children),
        ),
      ),
    );
  }

  /// Icons beside a label are grey (DS strokes #9EA2AE); icon-only items on
  /// the screens (back chevron, Home bell) are dark, so they use the black
  /// role.
  Color _iconColor(AppSemanticColors colors) =>
      iconColor ?? (label == null ? colors.iconBlack : colors.iconGrey);
}
