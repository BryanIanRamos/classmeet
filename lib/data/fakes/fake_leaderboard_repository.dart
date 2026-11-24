import '../models/leaderboard.dart';
import '../repositories/leaderboard_repository.dart';
import 'fake_config.dart';
import 'samples/leaderboard_samples.dart';

/// [LeaderboardRepository] serving the design's rows for every quiz and scope.
class FakeLeaderboardRepository implements LeaderboardRepository {
  const FakeLeaderboardRepository(this._config);

  final FakeConfig _config;

  @override
  Future<List<LeaderboardEntry>> fetchLeaderboard(
    String quizId, {
    LeaderboardScope scope = LeaderboardScope.classScope,
  }) =>
      _config.answerList('fetchLeaderboard', () => List.of(sampleLeaderboard));
}
