import 'package:flutter/material.dart';

import '../../assets/app_icons.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_semantic_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import 'app_navbar_item.dart';

/// The ClassMeet top bar (DS Navbar: Top, Figma 5248:1785): [leading] items,
/// a middle title (optionally with [subtitle]), and [trailing] items.
///
/// Content variants of the DS: Icons / Text + Icon (items from
/// [AppNavbarItem]), Title, and Title + Secondary Text. Pass [onBack] for the
/// back chevron (screens 13.1, 14, 11), or an [avatar] for the Home header,
/// where the title and subtitle are start-aligned next to the avatar.
///
/// It is just the bar: the shell adds the safe-area inset. It is one row, so
/// a second bar (study tabs, task 2.9) can be stacked under it.
///
/// Geometry follows the screens: 48dp tall, white, 16dp from the edge to the
/// first icon (the DS sheet shows 44dp on grey-50 with Inter text). The title
/// is B2 (16/24 Medium), the subtitle Inter C1 in the dark text colour of the
/// Home screen (the DS sheet shows grey-400; pass [subtitleColor] to change
/// it).
class AppNavbarTop extends StatelessWidget {
  const AppNavbarTop({
    super.key,
    this.title,
    this.subtitle,
    this.leading = const [],
    this.trailing = const [],
    this.onBack,
    this.avatar,
    this.showBottomBorder = false,
    this.backgroundColor,
    this.subtitleColor,
  });

  /// Bar height (screens 11, 14, Home: 48).
  static const height = 48.0;

  /// Width reserved on each side, so a centered title stays centered when
  /// only one side has an item (the DS side items are equal width).
  static const sideMinWidth = 48.0;

  /// Padding between the screen edge and a side slot, so that the item's own
  /// padding puts the icon 16dp from the edge.
  static const edgePadding = AppSpacing.xs;

  /// Edge padding and avatar gap of the Home header (avatar variant). The
  /// bottom border is 1dp, grey-100.
  static const avatarEdgePadding = AppSpacing.md;
  static const avatarGap = 10.0;

  final String? title;
  final String? subtitle;
  final List<Widget> leading;
  final List<Widget> trailing;

  /// Adds a back chevron as the first leading item.
  final VoidCallback? onBack;

  /// Leading avatar (Home); switches to the start-aligned header layout.
  final Widget? avatar;
  final bool showBottomBorder;

  /// Bar fill; defaults to the white surface.
  final Color? backgroundColor;
  final Color? subtitleColor;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final hasAvatar = avatar != null;
    final leadingItems = [
      if (onBack != null)
        AppNavbarItem.icon(
          icon: AppIcons.chevronLeft,
          semanticLabel: 'Back',
          onTap: onBack,
        ),
      ...leading,
    ];

    final Widget row;
    if (hasAvatar) {
      row = Row(
        children: [
          const SizedBox(width: avatarEdgePadding),
          avatar!,
          const SizedBox(width: avatarGap),
          Expanded(child: _titleBlock(colors, TextAlign.start)),
          ...trailing,
          const SizedBox(width: edgePadding),
        ],
      );
    } else {
      row = Row(
        children: [
          ConstrainedBox(
            constraints: const BoxConstraints(minWidth: sideMinWidth),
            child: Row(mainAxisSize: MainAxisSize.min, children: leadingItems),
          ),
          Expanded(child: _titleBlock(colors, TextAlign.center)),
          ConstrainedBox(
            constraints: const BoxConstraints(minWidth: sideMinWidth),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.end,
              children: trailing,
            ),
          ),
        ],
      );
    }

    return DecoratedBox(
      decoration: BoxDecoration(
        color: backgroundColor ?? colors.surfaceWhite,
        border: showBottomBorder
            ? const Border(bottom: BorderSide(color: AppColors.grey100))
            : null,
      ),
      child: SizedBox(
        height: height,
        child: Padding(
          padding: hasAvatar
              ? EdgeInsets.zero
              : const EdgeInsets.symmetric(horizontal: edgePadding),
          child: row,
        ),
      ),
    );
  }

  Widget _titleBlock(AppSemanticColors colors, TextAlign align) {
    if (title == null) return const SizedBox.shrink();
    final crossAxis = align == TextAlign.center
        ? CrossAxisAlignment.center
        : CrossAxisAlignment.start;
    return Semantics(
      header: true,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: crossAxis,
        children: [
          Text(
            title!,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: align,
            style: AppTypography.b2.copyWith(color: colors.textPrimary),
          ),
          if (subtitle != null)
            Text(
              subtitle!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: align,
              style: AppTypography.interC1.copyWith(
                color: subtitleColor ?? colors.textPrimary,
              ),
            ),
        ],
      ),
    );
  }
}
