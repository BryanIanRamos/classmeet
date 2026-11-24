import '../models/leaderboard.dart';
import '../models/onboarding_prefs.dart';
import '../models/profile.dart';
import '../repositories/profile_repository.dart';
import 'fake_config.dart';
import 'samples/profile_samples.dart';

/// In-memory [ProfileRepository]. Saved preferences are returned by later
/// reads.
class FakeProfileRepository implements ProfileRepository {
  FakeProfileRepository(this._config, {DateTime Function()? clock});

  final FakeConfig _config;
  OnboardingPrefs _prefs = sampleOnboardingPrefs;
  RankingVisibility _visibility = sampleRankingVisibility;

  @override
  Future<UserProfile> fetchProfile() =>
      _config.answer('fetchProfile', () => sampleUser);

  @override
  Future<OnboardingPrefs> fetchOnboardingPrefs() =>
      _config.answer('fetchOnboardingPrefs', () => _prefs);

  @override
  Future<void> saveOnboardingPrefs(OnboardingPrefs prefs) =>
      _config.answer('saveOnboardingPrefs', () => _prefs = prefs);

  @override
  Future<RankingVisibility> fetchRankingVisibility() =>
      _config.answer('fetchRankingVisibility', () => _visibility);

  @override
  Future<void> saveRankingVisibility(RankingVisibility visibility) =>
      _config.answer('saveRankingVisibility', () => _visibility = visibility);
}
