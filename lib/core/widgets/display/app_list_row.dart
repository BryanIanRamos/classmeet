import 'package:flutter/material.dart';

import '../../assets/app_icons.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_radii.dart';
import '../../theme/app_semantic_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import 'app_card.dart';

/// Look of an [AppListRow].
enum AppListRowStyle {
  /// The Home card: Grey-50 fill, Grey-300 border, radius 16, padding 16,
  /// title S1, top-aligned trailing.
  card,

  /// The DS List row (5248:10403): no card chrome, min height 56, padding
  /// 12/16, title B1, centred trailing. Put it on a Grey-50 surface for the
  /// DS look.
  plain,
}

/// A list row (DS List 5248:10403 and the Home list cards): a leading slot,
/// a title with optional subtitle and bottom content, and a trailing slot.
///
/// Leading: [leadingIcon] in a 40 square slot (icon 24, optional
/// [leadingTint] fill with radius 8), or any [leading] widget such as an
/// `AppAvatar`. Trailing, left to right: [trailingText] (B1 grey-500), a
/// [trailing] widget (badge, checkbox, radio, toggle, stepper...) and, with
/// [showChevron], a 24 chevron. Pass [subtitleWidget] instead of [subtitle]
/// for a rich meta line (e.g. a "+2 talons" span). [bottom] sits under the
/// row (e.g. an `AppProgressBar`).
///
/// A null [onTap] makes the row static; otherwise it shows a flat pressed
/// fill. When the trailing control is itself interactive (checkbox, toggle),
/// leave [onTap] null or toggle the same state from it.
///
/// Type: Plus Jakarta Sans, from the screens (the DS sheet shows Inter).
/// Colours: the chevron is the dark icon colour on [AppListRowStyle.card]
/// (Home) and Grey-400 on [AppListRowStyle.plain] (DS).
class AppListRow extends StatelessWidget {
  const AppListRow({
    super.key,
    required this.title,
    this.subtitle,
    this.subtitleWidget,
    this.leadingIcon,
    this.leadingTint,
    this.leading,
    this.trailing,
    this.trailingText,
    this.showChevron = false,
    this.bottom,
    this.onTap,
    this.style = AppListRowStyle.card,
    this.showDivider = false,
  });

  /// Width and height of the icon slot.
  static const leadingSlot = 40.0;

  /// Glyph size inside the icon slot and of the chevron.
  static const iconSize = 24.0;

  /// Gap between the leading slot and the text (Figma gap 10 on Home).
  static const leadingGap = 10.0;

  /// Gap between trailing parts.
  static const trailingGap = AppSpacing.sm;

  /// Widest the trailing text may grow before it ellipsizes.
  static const trailingTextMaxWidth = 120.0;

  /// Minimum height of the plain row (DS: 4 + 48 + 4).
  static const plainMinHeight = 56.0;

  /// Height of the title line, used to align the card trailing to it.
  static const titleLineHeight = 28.0;

  final String title;
  final String? subtitle;
  final Widget? subtitleWidget;
  final IconData? leadingIcon;

  /// Fill of the icon slot; null leaves it transparent (as on Home).
  final Color? leadingTint;
  final Widget? leading;
  final Widget? trailing;
  final String? trailingText;
  final bool showChevron;
  final Widget? bottom;
  final VoidCallback? onTap;
  final AppListRowStyle style;

  /// Draws a Grey-200 line under the row (for stacked [AppListRowStyle.plain]
  /// rows).
  final bool showDivider;

  bool get _isCard => style == AppListRowStyle.card;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final titleStyle = _isCard ? AppTypography.s1 : AppTypography.b1;
    final leadingWidget = _leading(colors);
    final trailingParts = <Widget>[
      if (trailingText != null)
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: trailingTextMaxWidth),
          child: Text(
            trailingText!,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.b1.copyWith(color: colors.textSecondary),
          ),
        ),
      ?trailing,
      if (showChevron)
        Icon(
          AppIcons.chevronRight,
          size: iconSize,
          color: _isCard ? colors.iconBlack : colors.iconGrey,
        ),
    ];

    Widget trailingWidget = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < trailingParts.length; i++) ...[
          if (i > 0) const SizedBox(width: trailingGap),
          trailingParts[i],
        ],
      ],
    );
    if (_isCard) {
      trailingWidget = SizedBox(
        height: titleLineHeight,
        child: Center(child: trailingWidget),
      );
    }

    final row = Row(
      crossAxisAlignment: _isCard
          ? CrossAxisAlignment.start
          : CrossAxisAlignment.center,
      children: [
        if (leadingWidget != null) ...[
          leadingWidget,
          SizedBox(width: _isCard ? leadingGap : AppSpacing.sm),
        ],
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: titleStyle.copyWith(color: colors.textPrimary),
              ),
              if (subtitle != null || subtitleWidget != null)
                Padding(
                  padding: _isCard
                      ? const EdgeInsets.symmetric(vertical: AppSpacing.xxs)
                      : EdgeInsets.zero,
                  child:
                      subtitleWidget ??
                      Text(
                        subtitle!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.c1.copyWith(
                          color: colors.textSecondary,
                        ),
                      ),
                ),
            ],
          ),
        ),
        if (trailingParts.isNotEmpty) ...[
          const SizedBox(width: AppSpacing.sm),
          trailingWidget,
        ],
      ],
    );

    final content = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (_isCard)
          row
        else
          ConstrainedBox(
            constraints: const BoxConstraints(minHeight: plainMinHeight),
            child: Align(alignment: Alignment.centerLeft, child: row),
          ),
        if (bottom != null)
          Padding(
            padding: const EdgeInsets.only(top: AppSpacing.xxs),
            child: bottom,
          ),
      ],
    );

    final card = _isCard
        ? AppCard(onTap: onTap, semanticLabel: title, child: content)
        : AppCard(
            onTap: onTap,
            semanticLabel: title,
            color: Colors.transparent,
            pressedColor: AppColors.grey50,
            borderColor: null,
            radius: AppRadii.none,
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.sm,
              AppSpacing.none,
              AppSpacing.md,
              AppSpacing.none,
            ),
            child: content,
          );
    if (!showDivider) return card;
    return DecoratedBox(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.grey200)),
      ),
      child: card,
    );
  }

  Widget? _leading(AppSemanticColors colors) {
    if (leading != null) return leading;
    if (leadingIcon == null) return null;
    return Container(
      key: const ValueKey('list-row-leading'),
      width: leadingSlot,
      height: leadingSlot,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: leadingTint,
        borderRadius: BorderRadius.circular(AppRadii.xs),
      ),
      child: Icon(leadingIcon, size: iconSize, color: colors.iconBlack),
    );
  }
}
