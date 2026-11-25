import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/clock.dart';
import '../../../../core/router/routes.dart';
import '../../../../core/theme/app_semantic_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/feedback/app_loader.dart';
import '../../../../core/widgets/feedback/error_state.dart';
import '../../../../core/widgets/layout/screen_background.dart';
import '../../application/home_providers.dart';
import '../widgets/daily_progress_card.dart';
import '../widgets/home_header.dart';
import '../widgets/home_stat_card.dart';

/// Home (frame 8), the first tab.
///
/// The header greets the user by username (D-19). Below it, on the doodle
/// background: the daily-progress hero card, then the streak and talon
/// cards. Those three need [homeSummaryProvider]; while it loads the body
/// shows a loader, and if it fails an [ErrorState] whose retry reloads it.
/// Pull down to refresh.
///
/// Navigation: avatar → profile (placeholder, GAP-07), bell →
/// notifications (11), "Continue studying" → the reader of the first
/// in-progress material (else the Study tab), streak card → streak details
/// (GAP-08), talon card → talon credits (14).
class HomeDashboardScreen extends ConsumerWidget {
  const HomeDashboardScreen({super.key});

  /// Space between the cards (spec 8, "Frame 1147": gap 12, padding 16).
  static const _sectionGap = AppSpacing.sm;
  static const _statCardGap = AppSpacing.xs;

  Future<void> _refresh(WidgetRef ref) async {
    ref
      ..invalidate(profileProvider)
      ..invalidate(walletProvider)
      ..invalidate(streakProvider)
      ..invalidate(dailyProgressProvider)
      ..invalidate(inProgressMaterialsProvider);
    try {
      await ref.read(homeSummaryProvider.future);
    } on Object {
      // The screen shows the failure through the provider's error state.
    }
  }

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
    // Load the "Continue studying" target early.
    ref.watch(inProgressMaterialsProvider);

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
                    padding: const EdgeInsets.all(AppSpacing.md),
                    children: [
                      DailyProgressCard(
                        progress: value.today,
                        onContinue: () => _continueStudying(context, ref),
                      ),
                      const SizedBox(height: _sectionGap),
                      _StatCards(
                        summary: value,
                        onStreakTap: () => context.push(Routes.streak),
                        onTalonsTap: () => context.push(Routes.talonCredits),
                      ),
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
