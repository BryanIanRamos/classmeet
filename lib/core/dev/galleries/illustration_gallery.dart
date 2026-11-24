import 'package:flutter/material.dart';

import '../../assets/app_images.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_semantic_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../../widgets/buttons/app_button.dart';
import '../../widgets/display/app_illustration.dart';
import '../../widgets/display/illustrated_card.dart';
import '../../widgets/feedback/coming_soon_screen.dart';

/// AppIllustration sizes, the three Home illustrated cards (placeholders
/// until the text-free exports of task 1.8 arrive) at 394 and 328 dp, and a
/// ComingSoonScreen preview.
class IllustrationMatrix extends StatelessWidget {
  const IllustrationMatrix({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('AppIllustration', style: AppTypography.s2),
        const SizedBox(height: AppSpacing.xs),
        const Wrap(
          spacing: AppSpacing.md,
          runSpacing: AppSpacing.md,
          crossAxisAlignment: WrapCrossAlignment.end,
          children: [
            AppIllustration(AppImages.createReadyOwl, width: 120),
            AppIllustration(AppImages.playResultsOwl, width: 120),
            AppIllustration(AppImages.welcomeOwl, height: 100),
            AppIllustration(
              AppImage('assets/images/missing.png', width: 80, height: 80),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xl),
        const Text('IllustratedCard', style: AppTypography.s2),
        const SizedBox(height: AppSpacing.xs),
        Wrap(
          spacing: AppSpacing.xl,
          runSpacing: AppSpacing.md,
          children: [
            for (final width in const [394.0, 328.0])
              SizedBox(
                width: width,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${width.round()} dp', style: AppTypography.c1),
                    const SizedBox(height: AppSpacing.xxs),
                    const _HeroCard(),
                    const SizedBox(height: AppSpacing.xs),
                    const Row(
                      children: [
                        Expanded(
                          child: _StatCard(
                            value: '6',
                            unit: 'days',
                            title: 'Study streak',
                            color: AppColors.ember500,
                            border: AppColors.ember700,
                          ),
                        ),
                        SizedBox(width: AppSpacing.xs),
                        Expanded(
                          child: _StatCard(
                            value: '7',
                            unit: 'talons',
                            title: 'Talon credits',
                            color: AppColors.talon500,
                            border: AppColors.talon700,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.xl),
        const Text('ComingSoonScreen', style: AppTypography.s2),
        const SizedBox(height: AppSpacing.xs),
        const SizedBox(
          width: 360,
          height: 560,
          child: ComingSoonScreen(
            title: 'Friends',
            gapId: 'GAP-06',
            showBack: false,
          ),
        ),
      ],
    );
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard();

  @override
  Widget build(BuildContext context) {
    return IllustratedCard(
      minHeight: 189,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'YOUR DAILY PROGRESS',
            style: AppTypography.b3.copyWith(color: AppColors.sage500),
          ),
          const SizedBox(height: AppSpacing.xs),
          const Text('You got this!', style: AppTypography.h5),
          const SizedBox(height: AppSpacing.xs),
          Text(
            '3 activities remaining',
            style: AppTypography.c1.copyWith(color: AppColors.sage500),
          ),
          const SizedBox(height: AppSpacing.sm),
          AppButton(label: 'Continue studying', onPressed: () {}, expand: true),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.value,
    required this.unit,
    required this.title,
    required this.color,
    required this.border,
  });

  final String value;
  final String unit;
  final String title;
  final Color color;
  final Color border;

  @override
  Widget build(BuildContext context) {
    return IllustratedCard(
      minHeight: 106,
      color: color,
      borderColor: border,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Text(value, style: AppTypography.h1),
              Text(unit, style: AppTypography.c3),
            ],
          ),
          const SizedBox(width: AppSpacing.xs),
          Flexible(
            child: Text(
              title,
              style: AppTypography.c2.copyWith(
                fontWeight: FontWeight.w700,
                color: context.colors.textPrimary,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
