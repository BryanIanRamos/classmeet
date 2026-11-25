import 'package:flutter/material.dart';

import '../../../../core/assets/app_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_semantic_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/display/illustrated_card.dart';

/// Colours of the two Home stat cards (frame 8).
enum HomeStatTone {
  /// "Study streak": Ember-500 fill, Ember-700 border.
  streak(AppColors.ember500, AppColors.ember700),

  /// "Talon credits": Talon-500 fill, Talon-700 border.
  talons(AppColors.talon500, AppColors.talon700);

  const HomeStatTone(this.fill, this.border);

  final Color fill;
  final Color border;
}

/// A Home stat card (frame 8, "Frame 1181" and "Frame 1182"): a big number
/// over its unit ("6 days", "24 talons"), then a title, a caption and a
/// link with a chevron ("View streak ›"). The whole card is the tap target.
///
/// 193×106 on the 428 frame, radius 16. The number column sits 18 from the
/// left and 15 from the top; the labels start 8 after it, 24 from the top.
/// H1 number with the unit pulled up 5 (Figma gap -5); the title is 12/16
/// Bold (C2 with Figma's Bold override). The flame and coin art
/// arrives with the manual exports (1.8); until then the card is its plain
/// tone colour.
///
/// When the content is wider than the card (a two-digit number on a 360 dp
/// screen, where the card is 160 wide) it scales down as a whole instead of
/// cutting the labels; it never scales up.
class HomeStatCard extends StatelessWidget {
  const HomeStatCard({
    super.key,
    required this.tone,
    required this.value,
    required this.unit,
    required this.title,
    required this.caption,
    required this.linkLabel,
    required this.onTap,
  });

  final HomeStatTone tone;

  /// The big number, e.g. "6".
  final String value;

  /// Under the number, e.g. "days".
  final String unit;
  final String title;
  final String caption;
  final String linkLabel;
  final VoidCallback? onTap;

  /// Card height in the design.
  static const height = 106.0;

  static const _padding = EdgeInsets.only(
    left: 18,
    top: 15,
    right: AppSpacing.xs,
  );

  /// The labels start 24 from the card top: 9 below the number column.
  static const _labelsTop = 9.0;

  /// Figma stacks the unit 5 into the number's line box (gap -5).
  static const _unitOverlap = 5.0;
  static const _labelGap = 2.0;
  static const _chevronSize = 16.0;

  @override
  Widget build(BuildContext context) {
    final ink = context.colors.textPrimary;
    TextStyle style(TextStyle base) => base.copyWith(color: ink);
    Widget label(String text, TextStyle base) =>
        Text(text, maxLines: 1, softWrap: false, style: style(base));

    return Semantics(
      button: onTap != null,
      label: '$title: $value $unit. $caption. $linkLabel',
      excludeSemantics: true,
      child: IllustratedCard(
        color: tone.fill,
        borderColor: tone.border,
        minHeight: height,
        padding: _padding,
        onTap: onTap,
        child: FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.topLeft,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(value, style: style(AppTypography.h1)),
                  Transform.translate(
                    offset: const Offset(0, -_unitOverlap),
                    child: Text(unit, style: style(AppTypography.c3)),
                  ),
                ],
              ),
              const SizedBox(width: AppSpacing.xs),
              Padding(
                padding: const EdgeInsets.only(top: _labelsTop),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    label(title, AppTypography.c1Bold),
                    const SizedBox(height: _labelGap),
                    label(caption, AppTypography.c3),
                    const SizedBox(height: _labelGap),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        label(linkLabel, AppTypography.c3),
                        const SizedBox(width: AppSpacing.xxs),
                        Icon(
                          AppIcons.chevronRight,
                          size: _chevronSize,
                          color: context.colors.iconBlack,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
