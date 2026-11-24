import '../models/streak.dart';
import '../models/wallet.dart';
import '../repositories/repository_exception.dart';
import '../repositories/wallet_repository.dart';
import 'fake_config.dart';
import 'samples/wallet_samples.dart';

/// In-memory [WalletRepository]. The balance changes with [spendTalons] and
/// [earn]. It is not linked to the quest fake, so claiming a quest does not
/// change this balance.
class FakeWalletRepository implements WalletRepository {
  FakeWalletRepository(this._config, {DateTime Function()? clock});

  final FakeConfig _config;
  Wallet _wallet = sampleWallet;

  @override
  Future<Wallet> fetchWallet() => _config.answer('fetchWallet', () => _wallet);

  @override
  Future<RewardProgress> fetchRewardProgress() =>
      _config.answer('fetchRewardProgress', () => sampleRewardProgress);

  @override
  Future<Streak> fetchStreak() =>
      _config.answer('fetchStreak', () => sampleStreak);

  @override
  Future<Wallet> spendTalons(int amount, {required String reason}) =>
      _config.answer('spendTalons', () {
        if (amount <= 0) {
          throw const RepositoryException('Amount must be positive');
        }
        if (amount > _wallet.talons) {
          throw RepositoryException(
            'Not enough talons ($amount needed, ${_wallet.talons} left)',
          );
        }
        return _wallet = _wallet.copyWith(talons: _wallet.talons - amount);
      });

  @override
  Future<Wallet> earn({int talons = 0, int studyPoints = 0, int xp = 0}) =>
      _config.answer('earn', () {
        if (talons < 0 || studyPoints < 0 || xp < 0) {
          throw const RepositoryException('Earned amounts cannot be negative');
        }
        return _wallet = _wallet.copyWith(
          talons: _wallet.talons + talons,
          studyPoints: _wallet.studyPoints + studyPoints,
          xp: _wallet.xp + xp,
        );
      });
}
