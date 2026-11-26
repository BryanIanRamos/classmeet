import 'package:flutter/material.dart';

import '../../../../core/assets/app_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_semantic_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';

/// The "About today's quiz" card under the options (frame 15, "Frame 1173").
///
/// Sage-100, radius 16, 16 inside. An info icon (16) and the title in C1
/// Sage-500 with 4 between them, 8 above the C3 Sage-500 body. The copy is
/// the design's, so it says "5" whatever today's count is.
class DailyQuizInfoCard extends StatelessWidget {
  const DailyQuizInfoCard({super.key});

  static const title = "About today's quiz";
  static const body =
      'Everyone gets the same 5 GE questions each day. Topics rotate across '
      'general education subjects, including: Understanding the Self, '
      'Philippine History, Math in the Modern World, Purposive Comm, STS, '
      'Ethics, and more.';

  /// Icon size, and the gap between the icon and the title.
  static const iconSize = 16.0;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: AppColors.sage100,
        borderRadius: BorderRadius.all(Radius.circular(AppRadii.md)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  AppIcons.info,
                  size: iconSize,
                  color: colors.iconSecondaryAccent,
                ),
                const SizedBox(width: AppSpacing.xxs),
                Expanded(
                  child: Text(
                    title,
                    style: AppTypography.c1.copyWith(
                      color: colors.textSecondaryAccent,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              body,
              style: AppTypography.c3.copyWith(
                color: colors.textSecondaryAccent,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
