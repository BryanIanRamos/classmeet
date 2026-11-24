import '../models/streak.dart';
import '../models/wallet.dart';

/// Talons, study points, XP and the streak (8, 14, 122). AI actions spend
/// talons through [spendTalons] (91, 116).
abstract interface class WalletRepository {
  Future<Wallet> fetchWallet();

  Future<RewardProgress> fetchRewardProgress();

  Future<Streak> fetchStreak();

  /// Takes [amount] talons and returns the new balance. Throws a
  /// `RepositoryException` when the balance is too low (GAP-20).
  Future<Wallet> spendTalons(int amount, {required String reason});

  /// Adds talons, study points or XP and returns the new balance.
  Future<Wallet> earn({int talons = 0, int studyPoints = 0, int xp = 0});
}
