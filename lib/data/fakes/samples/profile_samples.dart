import '../../models/leaderboard.dart';
import '../../models/onboarding_prefs.dart';
import '../../models/profile.dart';

/// The owl picture of frames 8 and 12 (`AppImages.avatar`; a test checks
/// the path is registered).
const sampleOwlAvatar = 'assets/images/common/avatar.png';

/// The signed-in student (frames 8, 93), with the owl picture of frame 8.
/// Email is a placeholder, never real.
const sampleUser = UserProfile(
  id: 'user-bryan',
  username: 'Bryan',
  email: 'student@example.com',
  nickname: 'Owl_4821',
  avatarAsset: sampleOwlAvatar,
  programLabel: 'BSIT 2A',
  schoolShort: 'CSU',
  yearLevel: YearLevel.second,
);

/// Onboarding answers before the student changes anything: only the school
/// shown on frame 96 is filled in. // sample
const sampleOnboardingPrefs = OnboardingPrefs(schoolId: 'csu');

/// Default of the ranking privacy sheet (133).
const sampleRankingVisibility = RankingVisibility.displayName;
