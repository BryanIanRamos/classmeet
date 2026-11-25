import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/clock.dart';
import '../../../../core/router/routes.dart';
import '../../../../core/theme/app_semantic_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/display/section_header.dart';
import '../../../../core/widgets/feedback/app_loader.dart';
import '../../../../core/widgets/feedback/error_state.dart';
import '../../../../core/widgets/layout/screen_background.dart';
import '../../../../data/models/quest.dart';
import '../../application/home_providers.dart';
import '../widgets/daily_progress_card.dart';
import '../widgets/home_goal_card.dart';
import '../widgets/home_header.dart';
import '../widgets/home_material_card.dart';
import '../widgets/home_quest_card.dart';
import '../widgets/home_stat_card.dart';

/// Home (frame 8), the first tab.
///
/// The header greets the user by username (D-19). Below it, on the doodle
/// background: the daily-progress hero card, then the streak and talon
/// cards. Those three need [homeSummaryProvider]; while it loads the body
/// shows a loader, and if it fails an [ErrorState] whose retry reloads it.
/// Then three sections, each from its own provider and hidden while it
/// loads, fails or is empty: "Coming up next" (the next deadline), "Pick up
/// where you left off" (the first in-progress material) and "Earn more talon
/// credits" (the daily quiz and the weekly survey). Pull down to refresh.
///
/// Navigation: avatar → profile (placeholder, GAP-07), bell →
/// notifications (11), "Continue studying" and the material card → the
/// reader of the first in-progress material ("Continue studying" falls back
/// to the Study tab), streak card → streak details (GAP-08), talon card →
/// talon credits (14), "View study plan" and the goal card → study plan
/// (GAP-09), quiz card → daily quiz (15), survey card → weekly survey (16).
class HomeDashboardScreen extends ConsumerWidget {
  const HomeDashboardScreen({super.key});

  /// Space between the cards (spec 8, "Frame 1147": gap 12, padding 16).
  static const _sectionGap = AppSpacing.sm;
  static const _statCardGap = AppSpacing.xs;

  /// The list cards are 402 wide, 4 wider on each side than the hero card,
  /// headers and stat cards (394, spec 8). The page padding is reduced by
  /// this much and the other items get it back.
  static const _cardOverhang = AppSpacing.xxs;

  /// The quests under "Earn more talon credits", in this order.
  static const _questKinds = [QuestKind.daily, QuestKind.survey];

  Future<void> _refresh(WidgetRef ref) async {
    ref
      ..invalidate(profileProvider)
      ..invalidate(walletProvider)
      ..invalidate(streakProvider)
      ..invalidate(dailyProgressProvider)
      ..invalidate(inProgressMaterialsProvider)
      ..invalidate(upcomingGoalsProvider)
      ..invalidate(questsProvider);
    try {
      await ref.read(homeSummaryProvider.future);
    } on Object {
      // The screen shows the failure through the provider's error state.
    }
  }

  static Widget _inset(Widget child) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: _cardOverhang),
    child: child,
  );

  void _continueStudying(BuildContext context, WidgetRef ref) {
    final materials = ref.read(inProgressMaterialsProvider).value;
    if (materials != null && materials.isNotEmpty) {
      context.push(Routes.reader(materials.first.id));
    } else {
      context.go(Routes.study);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final now = ref.watch(clockProvider)();
    final profile = ref.watch(profileProvider);
    final summary = ref.watch(homeSummaryProvider);
    final goals = ref.watch(upcomingGoalsProvider).value ?? const [];
    // Also the "Continue studying" target.
    final materials = ref.watch(inProgressMaterialsProvider).value ?? const [];
    final allQuests = ref.watch(questsProvider).value ?? const [];
    final quests = [
      for (final kind in _questKinds) ...allQuests.where((q) => q.kind == kind),
    ];

    return Scaffold(
      backgroundColor: context.colors.surfaceWhite,
      body: Column(
        children: [
          HomeHeader(
            greeting: greetingFor(now),
            profile: profile.value,
            onAvatarTap: () => context.push(Routes.profile),
            onNotificationsTap: () => context.push(Routes.notifications),
          ),
          Expanded(
            child: ScreenBackground(
              child: switch (summary) {
                AsyncData(:final value) => RefreshIndicator(
                  onRefresh: () => _refresh(ref),
                  child: ListView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md - _cardOverhang,
                      vertical: AppSpacing.md,
                    ),
                    children: [
                      _inset(
                        DailyProgressCard(
                          progress: value.today,
                          onContinue: () => _continueStudying(context, ref),
                        ),
                      ),
                      const SizedBox(height: _sectionGap),
                      _inset(
                        _StatCards(
                          summary: value,
                          onStreakTap: () => context.push(Routes.streak),
                          onTalonsTap: () => context.push(Routes.talonCredits),
                        ),
                      ),
                      if (goals.isNotEmpty) ...[
                        const SizedBox(height: _sectionGap),
                        _inset(
                          SectionHeader(
                            title: 'Coming up next',
                            actionLabel: 'View study plan',
                            onActionTap: () => context.push(Routes.studyPlan),
                          ),
                        ),
                        const SizedBox(height: _sectionGap),
                        HomeGoalCard(
                          goal: goals.first,
                          now: now,
                          onTap: () => context.push(Routes.studyPlan),
                        ),
                      ],
                      if (materials.isNotEmpty) ...[
                        const SizedBox(height: _sectionGap),
                        _inset(
                          const SectionHeader(
                            title: 'Pick up where you left off',
                          ),
                        ),
                        const SizedBox(height: _sectionGap),
                        HomeMaterialCard(
                          material: materials.first,
                          onTap: () =>
                              context.push(Routes.reader(materials.first.id)),
                        ),
                      ],
                      if (quests.isNotEmpty) ...[
                        const SizedBox(height: _sectionGap),
                        _inset(
                          const SectionHeader(title: 'Earn more talon credits'),
                        ),
                        for (final quest in quests) ...[
                          const SizedBox(height: _sectionGap),
                          HomeQuestCard(
                            quest: quest,
                            onTap: () => context.push(
                              quest.kind == QuestKind.survey
                                  ? Routes.weeklySurvey
                                  : Routes.dailyQuiz,
                            ),
                          ),
                        ],
                      ],
                    ],
                  ),
                ),
                AsyncError() => Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: ErrorState(onRetry: () => _refresh(ref)),
                  ),
                ),
                _ => const Center(child: AppLoader()),
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// The streak and talon cards side by side, 8 apart.
class _StatCards extends StatelessWidget {
  const _StatCards({
    required this.summary,
    required this.onStreakTap,
    required this.onTalonsTap,
  });

  final HomeSummary summary;
  final VoidCallback onStreakTap;
  final VoidCallback onTalonsTap;

  @override
  Widget build(BuildContext context) {
    final days = summary.streak.days;
    final freezes = summary.streak.freezesLeft;
    final talons = summary.wallet.talons;
    return Row(
      children: [
        Expanded(
          child: HomeStatCard(
            tone: HomeStatTone.streak,
            value: '$days',
            unit: countLabel(days, 'day'),
            title: 'Study streak',
            caption: freezes == 0
                ? 'No streak freezes left'
                : '$freezes ${countLabel(freezes, 'streak freeze', 'streak freezes')} left',
            linkLabel: 'View streak',
            onTap: onStreakTap,
          ),
        ),
        const SizedBox(width: HomeDashboardScreen._statCardGap),
        Expanded(
          child: HomeStatCard(
            tone: HomeStatTone.talons,
            value: '$talons',
            unit: countLabel(talons, 'talon'),
            title: 'Talon credits',
            caption: 'Earn by studying',
            linkLabel: 'View credits',
            onTap: onTalonsTap,
          ),
        ),
      ],
    );
  }
}
