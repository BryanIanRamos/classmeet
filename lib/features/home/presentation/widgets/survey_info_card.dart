import 'package:flutter/material.dart';

import '../../../../core/assets/app_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_semantic_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';

/// The "Your feedback matters" card above the submit button (frame 16,
/// "Frame 1173").
///
/// Sage-100, radius 16, 16 inside. A shield-check icon (16) and the title in
/// C1 Sage-500 with 4 between them, 8 above the C3 Sage-500 body. The screen
/// insets the card 16 from the page's content edge.
class SurveyInfoCard extends StatelessWidget {
  const SurveyInfoCard({super.key});

  static const title = 'Your feedback matters';
  static const body =
      'Responses are grouped to help improve ClassMeet. '
      'You can skip any question.';

  /// Icon size.
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
                  AppIcons.shieldCheck,
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
