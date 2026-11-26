import 'package:flutter/material.dart';

import '../../../../core/assets/app_icons.dart';
import '../../../../core/assets/app_images.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/display/illustrated_card.dart';
import '../../../../data/models/wallet.dart';
import '../../application/home_providers.dart';
import 'talon_chip.dart';
import 'talon_progress_bar.dart';

/// The balance card of Talon credits (frame 14, "Frame 1191"): the talon
/// balance over a divider, then "Your next reward" with its chip and
/// progress, an encouragement and "View rewards history".
///
/// Talon-100 fill, Talon-700 border, radius 16, 396×283 (Figma: a 394×281
/// box with its 1 dp stroke outside). The two inner frames sit 16 inside that
/// box, so 17 from the card's edge, 362 wide: the balance row (115, with a
/// 1 dp bottom divider that is part of its height) and the next-reward block
/// (130); the box ends 20 after them. The card art (Ollie on the coins,
/// `home_talon_balance`, with the cloud glows) arrives with the manual exports
/// (1.8): pass it as [art]; until then the card is plain Talon-100.
///
/// The progress bar is Talon-700 on Talon-500, 8 tall, with its label. The
/// design's bar shows a fixed 24 % (a resized Figma instance); this one
/// follows [progress].
class TalonBalanceCard extends StatelessWidget {
  const TalonBalanceCard({
    super.key,
    required this.talons,
    required this.progress,
    required this.onViewHistory,
    this.art,
  });

  final int talons;
  final RewardProgress progress;

  /// "View rewards history".
  final VoidCallback onViewHistory;

  /// Text-free card art (manual export 1.8); null shows the plain fill.
  final AppImage? art;

  /// The inner frames start 16 inside the box. [IllustratedCard] draws its
  /// border over the edge without taking layout space, so the 1 dp stroke
  /// that sits outside the Figma box is added to the padding.
  static const _inset = IllustratedCard.borderWidth + AppSpacing.md;

  /// The box ends 20 after the next-reward block.
  static const _bottomInset = IllustratedCard.borderWidth + AppSpacing.lg;

  static const _padding = EdgeInsets.fromLTRB(
    _inset,
    _inset,
    _inset,
    _bottomInset,
  );

  /// Stroke between the balance and the next reward (Figma stroke 1).
  static const _dividerHeight = 1.0;

  /// Key of the divider, for tests.
  static const dividerKey = ValueKey('talon-balance-divider');

  /// The history link is 16 tall in the design; 8 of padding above and below
  /// it make the tap target 32 tall. The gap above and the block's bottom
  /// padding give up the same 8, so the layout is unchanged.
  static const _linkPadding = AppSpacing.xs;

  static const _chevronSize = 16.0;

  @override
  Widget build(BuildContext context) {
    return IllustratedCard(
      art: art,
      color: AppColors.talon100,
      borderColor: AppColors.talon700,
      padding: _padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _Balance(talons: talons),
          const SizedBox(
            key: dividerKey,
            height: _dividerHeight,
            child: ColoredBox(color: AppColors.talon700),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.md,
              AppSpacing.md,
              AppSpacing.md - _linkPadding,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _NextReward(progress: progress),
                const SizedBox(height: AppSpacing.md - _linkPadding),
                _HistoryLink(onTap: onViewHistory),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// "YOUR TALON BALANCE", the number and its unit (spec 14, "Frame 1134":
/// 82 tall, 4 between the lines, 16 around it).
class _Balance extends StatelessWidget {
  const _Balance({required this.talons});

  final int talons;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'YOUR TALON BALANCE',
            style: AppTypography.b3.copyWith(color: AppColors.talon700),
          ),
          const SizedBox(height: AppSpacing.xxs),
          Text(
            '$talons',
            style: AppTypography.h3.copyWith(color: AppColors.talon900),
          ),
          const SizedBox(height: AppSpacing.xxs),
          Text(
            countLabel(talons, 'talon'),
            style: AppTypography.c1.copyWith(color: AppColors.talon700),
          ),
        ],
      ),
    );
  }
}

/// "Your next reward" with its chip, the progress bar and the encouragement
/// (spec 14, "Frame 1192": 66 tall).
class _NextReward extends StatelessWidget {
  const _NextReward({required this.progress});

  final RewardProgress progress;

  /// Space above and below the bar (spec 14, "Frame 1147": padding 4/0).
  static const _barPadding = AppSpacing.xxs;

  @override
  Widget build(BuildContext context) {
    final reward = progress.nextRewardTalons;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Your next reward',
                style: AppTypography.b3.copyWith(color: AppColors.talon900),
              ),
            ),
            const SizedBox(width: AppSpacing.xs),
            TalonChip(
              label: '+$reward ${countLabel(reward, 'talon')}',
              tone: TalonChipTone.next,
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xxs),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: _barPadding),
          child: TalonProgressBar(
            value: progress.fraction,
            color: AppColors.talon700,
            trackColor: AppColors.talon500,
            labelColor: AppColors.talon900,
            label: '${progress.done}/${progress.total}',
          ),
        ),
        Text(
          "Keep going—you're making progress!",
          style: AppTypography.c1.copyWith(color: AppColors.talon700),
        ),
      ],
    );
  }
}

/// "View rewards history ›" (spec 14, "Frame 1156": 138×16, 4 between the
/// text and the 16 chevron).
class _HistoryLink extends StatelessWidget {
  const _HistoryLink({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Semantics(
        button: true,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              vertical: TalonBalanceCard._linkPadding,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: Text(
                    'View rewards history',
                    style: AppTypography.c2.copyWith(color: AppColors.talon900),
                  ),
                ),
                const SizedBox(width: AppSpacing.xxs),
                const Icon(
                  AppIcons.chevronRight,
                  size: TalonBalanceCard._chevronSize,
                  color: AppColors.talon900,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
