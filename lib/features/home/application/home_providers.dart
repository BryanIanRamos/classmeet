import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/material.dart';
import '../../../data/models/profile.dart';
import '../../../data/models/quest.dart';
import '../../../data/models/streak.dart';
import '../../../data/models/study_plan.dart';
import '../../../data/models/wallet.dart';
import '../../../data/providers.dart';

/// The signed-in user: the Home greeting, avatar and "BSIT 2A · CSU".
final profileProvider = FutureProvider<UserProfile>(
  (ref) => ref.watch(profileRepositoryProvider).fetchProfile(),
);

/// Talon, study-point and XP balances (Home talon card, 14, 122).
final walletProvider = FutureProvider<Wallet>(
  (ref) => ref.watch(walletRepositoryProvider).fetchWallet(),
);

/// The study streak card (8).
final streakProvider = FutureProvider<Streak>(
  (ref) => ref.watch(walletRepositoryProvider).fetchStreak(),
);

/// "3 activities remaining" on the hero card (8).
final dailyProgressProvider = FutureProvider<DailyProgress>(
  (ref) => ref.watch(studyPlanRepositoryProvider).fetchDailyProgress(),
);

/// Started, unfinished materials: "Pick up where you left off" and the
/// hero card's "Continue studying" target (8).
final inProgressMaterialsProvider = FutureProvider<List<StudyMaterial>>(
  (ref) => ref.watch(materialRepositoryProvider).fetchInProgress(),
);

/// "Coming up next" (8): upcoming deadlines, soonest first.
final upcomingGoalsProvider = FutureProvider<List<PlanGoal>>(
  (ref) => ref.watch(studyPlanRepositoryProvider).fetchUpcoming(),
);

/// Talon-earning quests: "Earn more talon credits" (8) and the daily quests
/// of Talon credits (14). Invalidate it after claiming or completing one.
final questsProvider = FutureProvider<List<Quest>>(
  (ref) => ref.watch(questRepositoryProvider).fetchQuests(),
);

/// What the top of Home needs before it can show anything: the hero card
/// and the two stat cards. One failure shows the dashboard's error state.
typedef HomeSummary = ({DailyProgress today, Streak streak, Wallet wallet});

final homeSummaryProvider = FutureProvider<HomeSummary>((ref) async {
  final (today, streak, wallet) = await (
    ref.watch(dailyProgressProvider.future),
    ref.watch(streakProvider.future),
    ref.watch(walletProvider.future),
  ).wait;
  return (today: today, streak: streak, wallet: wallet);
});

/// "Good morning" before noon, "Good afternoon" until 6 PM, then
/// "Good evening" (the design shows the evening one).
String greetingFor(DateTime time) => switch (time.hour) {
  < 12 => 'Good morning',
  < 18 => 'Good afternoon',
  _ => 'Good evening',
};

/// The noun for [count]: [singular] for 1, else [plural] (default: an "s"
/// added), as in "1 day" and "6 days".
String countLabel(int count, String singular, [String? plural]) =>
    count == 1 ? singular : (plural ?? '${singular}s');
