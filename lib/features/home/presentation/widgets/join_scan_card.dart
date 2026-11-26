import 'package:flutter/material.dart';

import '../../../../core/assets/app_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_semantic_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/display/app_card.dart';

/// The "Scan a class QR code" card of Join a class (frame 13.1, "Frame 1168"):
/// a Talon-100 tile with the scan icon, the title, a grey line and a chevron,
/// on a white card with a Talon-700 outline.
///
/// 362 wide on the 428 frame and 86 high: the outline (1) and a padding of 4
/// surround a row padded by 16, so the content starts 21 from the edge. The
/// row's two items (294 and 40 wide) are 14 wider than the 320 left inside the
/// padding, so the chevron slot overflows it and sits 7 from the edge, with
/// the title and the line taking the 244 between. Figma also top-aligns the
/// 40 chevron button in the 44 high row, which puts the chevron 2 above the
/// centre; the bottom padding of [chevronLift] keeps that.
class JoinScanCard extends StatelessWidget {
  const JoinScanCard({super.key, required this.onTap});

  final VoidCallback onTap;

  /// The tile and the chevron slot are 40 square, with 24 icons.
  static const slotSize = 40.0;
  static const iconSize = 24.0;

  /// Gap between the tile and the text.
  static const tileGap = 10.0;

  /// Space under the chevron slot. Figma top-aligns the 40 chevron button in
  /// the 44 high row, so the chevron sits 2 above the row's centre; centring
  /// a slot with 4 of space under it puts it in the same place, and keeps it
  /// there when the text wraps and the card grows.
  static const chevronLift = AppSpacing.xxs;

  /// The chevron slot overflows the row's padding by this much.
  static const _overflow = 14.0;

  static const _padding = EdgeInsets.fromLTRB(
    AppSpacing.lg,
    AppSpacing.lg,
    AppSpacing.lg - _overflow,
    AppSpacing.lg,
  );

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return AppCard(
      onTap: onTap,
      color: AppColors.white,
      pressedColor: AppColors.talon50,
      borderColor: AppColors.talon700,
      padding: _padding,
      child: Row(
        children: [
          Container(
            width: slotSize,
            height: slotSize,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: AppColors.talon100,
              borderRadius: BorderRadius.all(Radius.circular(AppRadii.xs)),
            ),
            child: const Icon(
              AppIcons.scanLine,
              size: iconSize,
              color: AppColors.talon700,
            ),
          ),
          const SizedBox(width: tileGap),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Scan a class QR code',
                  style: AppTypography.b1.copyWith(color: AppColors.talon700),
                ),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  'Use the code provided by your instructor.',
                  style: AppTypography.c1.copyWith(color: colors.textSecondary),
                ),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.only(bottom: chevronLift),
            child: SizedBox.square(
              dimension: slotSize,
              child: Center(
                child: Icon(
                  AppIcons.chevronRight,
                  size: iconSize,
                  color: AppColors.talon700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
