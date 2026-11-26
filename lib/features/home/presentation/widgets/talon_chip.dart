import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/display/app_badge.dart';

/// Colours of a [TalonChip]: the two looks the frame-14 chips carry.
enum TalonChipTone {
  /// "+16 talons" by "Your next reward": Talon-500 fill, Grey-900 label.
  next(fill: AppColors.talon500, label: AppColors.grey900),

  /// "+5" on a quest card: Talon-300 fill, Talon-900 label.
  reward(fill: AppColors.talon300, label: AppColors.talon900);

  const TalonChipTone({required this.fill, required this.label});

  final Color fill;
  final Color label;
}

/// A talon amount chip (frame 14): "+16 talons" beside the next reward and
/// "+5" on each quest card.
///
/// The Design System "Badge & Chip" in its Tiny size, so the geometry is
/// [AppBadgeSize.tiny]'s (24 tall, 8 each side, radius 8, Button/Tiny). Only
/// the colours are its own: the two chips are Filled instances with
/// overridden colours (spec 14), and no [AppBadgeStyle] has a Talon fill with
/// a dark label. Chips are not interactive.
///
/// [semanticLabel] replaces the text for screen readers, e.g. "+5 talons" for
/// the bare "+5".
class TalonChip extends StatelessWidget {
  const TalonChip({
    super.key,
    required this.label,
    this.tone = TalonChipTone.reward,
    this.semanticLabel,
  });

  final String label;
  final TalonChipTone tone;
  final String? semanticLabel;

  static const _size = AppBadgeSize.tiny;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: _size.height,
      padding: EdgeInsets.symmetric(horizontal: _size.padding),
      decoration: BoxDecoration(
        color: tone.fill,
        borderRadius: BorderRadius.circular(_size.radius),
      ),
      child: Center(
        widthFactor: 1,
        child: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          semanticsLabel: semanticLabel,
          style: _size.textStyle.copyWith(color: tone.label),
        ),
      ),
    );
  }
}
