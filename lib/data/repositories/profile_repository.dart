import '../models/leaderboard.dart';
import '../models/onboarding_prefs.dart';
import '../models/profile.dart';

/// The user's profile, onboarding choices (96–99) and ranking privacy (133).
abstract interface class ProfileRepository {
  Future<UserProfile> fetchProfile();

  Future<OnboardingPrefs> fetchOnboardingPrefs();

  Future<void> saveOnboardingPrefs(OnboardingPrefs prefs);

  Future<RankingVisibility> fetchRankingVisibility();

  Future<void> saveRankingVisibility(RankingVisibility visibility);
}
