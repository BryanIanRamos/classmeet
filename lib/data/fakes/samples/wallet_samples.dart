import '../../models/streak.dart';
import '../../models/wallet.dart';

/// Talons 24 (INC-5: 119/121/122 show 24), study points 300 (122).
/// XP is not designed. // sample
const sampleWallet = Wallet(talons: 24, studyPoints: 300, xp: 120);

/// "Your next reward" on frame 14: +16 talons at 171/300.
const sampleRewardProgress = RewardProgress(
  nextRewardTalons: 16,
  done: 171,
  total: 300,
);

/// Frame 8: 6 days, 1 streak freeze left.
const sampleStreak = Streak(days: 6, freezesLeft: 1);
