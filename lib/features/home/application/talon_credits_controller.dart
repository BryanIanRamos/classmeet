import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/quest.dart';
import '../../../data/providers.dart';
import 'home_providers.dart';

/// What the Talon credits screen (14) shows about reward claims: the quests
/// being claimed right now and whether the last claim failed.
final class TalonClaimState {
  const TalonClaimState({this.claiming = const {}, this.failed = false});

  /// Ids of the quests whose claim is running (their button is busy).
  final Set<String> claiming;

  /// The last claim did not go through (the screen shows an alert).
  final bool failed;

  bool isClaiming(String questId) => claiming.contains(questId);

  TalonClaimState copyWith({Set<String>? claiming, bool? failed}) {
    return TalonClaimState(
      claiming: claiming ?? this.claiming,
      failed: failed ?? this.failed,
    );
  }
}

/// Claims quest rewards for the Talon credits screen (14).
///
/// [claim] marks the quest claimed on the quest repository, credits its
/// talons to the wallet, then reloads the quests and the wallet, so this
/// screen's cards and Home's talon card follow. A claim never runs twice: not
/// on a double tap (the quest is busy from the first tap), and not on a late
/// tap on a card that still shows "Claim reward" while the list reloads.
///
/// The claim and the credit are one step. The notifier stays alive until both
/// are done, even when the user leaves the screen meanwhile (the provider is
/// auto-disposed), so a claim is never left half done. Answers that arrive
/// after the whole provider scope is gone are dropped.
class TalonCreditsController extends Notifier<TalonClaimState> {
  /// Quests this controller has claimed. The quest list the screen holds can
  /// be a moment out of date right after a claim.
  final _claimed = <String>{};

  @override
  TalonClaimState build() => const TalonClaimState();

  /// Claims [quest]'s reward. Does nothing unless the quest is
  /// [QuestStatus.completed] and not already claimed or being claimed.
  Future<void> claim(Quest quest) async {
    if (quest.status != QuestStatus.completed) return;
    if (state.isClaiming(quest.id) || _claimed.contains(quest.id)) return;
    // Busy before the first await, so a second tap in the same frame is
    // turned away. A new claim also clears an earlier failure.
    state = TalonClaimState(claiming: {...state.claiming, quest.id});

    final quests = ref.read(questRepositoryProvider);
    final wallet = ref.read(walletRepositoryProvider);
    final keepAlive = ref.keepAlive();
    try {
      var failed = false;
      try {
        await quests.claimQuest(quest.id);
        if (!ref.mounted) return;
        _claimed.add(quest.id);
        await wallet.earn(talons: quest.rewardTalons);
      } on Object {
        failed = true;
      }
      if (!ref.mounted) return;

      await _reload();
      if (!ref.mounted) return;
      // A claim that went through does not hide another claim's failure.
      state = TalonClaimState(
        claiming: {...state.claiming}..remove(quest.id),
        failed: failed || state.failed,
      );
    } finally {
      if (ref.mounted) keepAlive.close();
    }
  }

  /// Hides the failure alert.
  void dismissError() {
    if (!state.failed) return;
    state = state.copyWith(failed: false);
  }

  /// Reloads what a claim changes and waits for it, so the card stays busy
  /// until it shows the new state. A failed reload shows in the providers' own
  /// error state.
  Future<void> _reload() async {
    ref
      ..invalidate(questsProvider)
      ..invalidate(walletProvider);
    try {
      await (
        ref.read(questsProvider.future),
        ref.read(walletProvider.future),
      ).wait;
    } on Object {
      // See above.
    }
  }
}

final talonCreditsControllerProvider =
    NotifierProvider.autoDispose<TalonCreditsController, TalonClaimState>(
      TalonCreditsController.new,
    );
