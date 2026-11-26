import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/assets/app_icons.dart';
import '../../../../core/router/routes.dart';
import '../../../../core/theme/app_semantic_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/display/illustrated_card.dart';
import '../../../../core/widgets/display/section_header.dart';
import '../../../../core/widgets/feedback/app_alert.dart';
import '../../../../core/widgets/feedback/app_loader.dart';
import '../../../../core/widgets/feedback/empty_state.dart';
import '../../../../core/widgets/feedback/error_state.dart';
import '../../../../core/widgets/layout/screen_background.dart';
import '../../../../core/widgets/navigation/app_navbar_top.dart';
import '../../../../data/models/quest.dart';
import '../../../../data/models/wallet.dart';
import '../../application/home_providers.dart';
import '../../application/talon_credits_controller.dart';
import '../widgets/quest_card.dart';
import '../widgets/talon_balance_card.dart';

/// Talon credits (frame 14): the talon balance with the next reward, then the
/// daily quests that earn more.
///
/// A back bar, then on the doodle background: the balance card ("Your next
/// reward" 171/300, "View rewards history") and "Your daily quests" with one
/// card per quest, in the data's order (the claimed daily quiz, the locked
/// streak milestone and the weekly survey in the design). The wallet, the
/// reward progress and the quests load together: until then a loader shows,
/// and if any of them fails an [ErrorState] whose retry reloads all three.
/// With no quests the section holds an [EmptyState] (provisional copy).
///
/// Navigation: back pops, "View rewards history" opens the rewards history
/// (GAP-10, a placeholder), "Answer survey" the weekly survey (16) and "Take
/// today's quiz" the daily quiz (15). The quests reload when the user comes
/// back from one, since finishing it can complete the quest.
///
/// "Claim reward" on a completed quest runs [TalonCreditsController.claim]:
/// the quest is marked claimed, its talons are credited, and the cards and
/// Home's talon card follow. A failed claim shows an alert above the cards
/// (provisional copy).
///
/// Sizes: the cards are 16 from the sides and 16 apart; the section starts 23
/// under the balance card (Figma's 24, less that card's stroke). The card art
/// arrives with the manual exports (1.8); until then the cards are their plain
/// fills.
class TalonCreditsScreen extends ConsumerWidget {
  const TalonCreditsScreen({super.key});

  static const _pagePadding = AppSpacing.md;

  /// Between the balance card and "Your daily quests" (spec 14, "Frame 1148":
  /// gap 24). The balance card's 1 dp stroke is drawn outside its Figma box,
  /// over the gap, so the visible gap is one less.
  static const _sectionGap = AppSpacing.xl - IllustratedCard.borderWidth;

  /// Between the section header and the first card, and between cards (spec
  /// 14, "Frame 1189": gap 16).
  static const _cardGap = AppSpacing.md;

  /// Below the last card: the frame's 24 gap and 16 padding around the home
  /// indicator; the indicator itself is the bottom safe-area inset.
  static const _bottomPadding = AppSpacing.xl + AppSpacing.md;

  void _retry(WidgetRef ref) {
    ref
      ..invalidate(walletProvider)
      ..invalidate(rewardProgressProvider)
      ..invalidate(questsProvider);
  }

  /// Opens the quiz or the survey and reloads the quests when the user
  /// returns: finishing it completes the quest. The container is read before
  /// the wait, so nothing touches the screen after it is gone.
  void _open(BuildContext context, String location) {
    final container = ProviderScope.containerOf(context);
    unawaited(
      context.push<void>(location).then((_) {
        container.invalidate(questsProvider);
      }),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wallet = ref.watch(walletProvider);
    final progress = ref.watch(rewardProgressProvider);
    final quests = ref.watch(questsProvider);
    final claims = ref.watch(talonCreditsControllerProvider);
    final controller = ref.read(talonCreditsControllerProvider.notifier);

    final states = <AsyncValue<Object>>[wallet, progress, quests];
    final Widget body;
    if (states.any((state) => state.hasError && !state.isLoading)) {
      body = Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: ErrorState(onRetry: () => _retry(ref)),
        ),
      );
    } else if (states.every((state) => state.hasValue)) {
      // A reload keeps showing the previous values (a claim reloads the
      // quests and the wallet) instead of flashing the loader.
      body = _Content(
        talons: wallet.requireValue.talons,
        progress: progress.requireValue,
        quests: quests.requireValue,
        claims: claims,
        onViewHistory: () => context.push(Routes.rewardsHistory),
        onOpen: (quest) => _open(
          context,
          quest.kind == QuestKind.survey
              ? Routes.weeklySurvey
              : Routes.dailyQuiz,
        ),
        onClaim: controller.claim,
        onDismissError: controller.dismissError,
      );
    } else {
      body = const Center(child: AppLoader());
    }

    return Scaffold(
      backgroundColor: context.colors.surfaceWhite,
      body: Column(
        children: [
          SafeArea(
            bottom: false,
            child: AppNavbarTop(
              title: 'Talon credits',
              onBack: () => Navigator.maybePop(context),
            ),
          ),
          Expanded(child: ScreenBackground(child: body)),
        ],
      ),
    );
  }
}

class _Content extends StatelessWidget {
  const _Content({
    required this.talons,
    required this.progress,
    required this.quests,
    required this.claims,
    required this.onViewHistory,
    required this.onOpen,
    required this.onClaim,
    required this.onDismissError,
  });

  final int talons;
  final RewardProgress progress;
  final List<Quest> quests;
  final TalonClaimState claims;
  final VoidCallback onViewHistory;
  final void Function(Quest quest) onOpen;
  final Future<void> Function(Quest quest) onClaim;
  final VoidCallback onDismissError;

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    return ListView(
      padding: EdgeInsets.fromLTRB(
        TalonCreditsScreen._pagePadding,
        TalonCreditsScreen._pagePadding,
        TalonCreditsScreen._pagePadding,
        TalonCreditsScreen._bottomPadding + bottomInset,
      ),
      children: [
        TalonBalanceCard(
          talons: talons,
          progress: progress,
          onViewHistory: onViewHistory,
        ),
        const SizedBox(height: TalonCreditsScreen._sectionGap),
        const SectionHeader(
          title: 'Your daily quests',
          subtitle: 'Complete activities to earn more Talons.',
        ),
        const SizedBox(height: TalonCreditsScreen._cardGap),
        if (claims.failed) ...[
          AppAlert(
            title: 'Could not claim your reward',
            message: 'Something went wrong. Please try again.',
            tone: AppAlertTone.error,
            icon: AppIcons.circleX,
            onClose: onDismissError,
          ),
          const SizedBox(height: TalonCreditsScreen._cardGap),
        ],
        if (quests.isEmpty)
          const EmptyState(
            title: 'No quests right now',
            message: 'Check back tomorrow for new ways to earn talons.',
          )
        else
          for (var i = 0; i < quests.length; i++) ...[
            if (i > 0) const SizedBox(height: TalonCreditsScreen._cardGap),
            QuestCard(
              quest: quests[i],
              claiming: claims.isClaiming(quests[i].id),
              onOpen: () => onOpen(quests[i]),
              onClaim: () => unawaited(onClaim(quests[i])),
            ),
          ],
      ],
    );
  }
}
