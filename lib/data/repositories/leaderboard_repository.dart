import '../models/leaderboard.dart';

/// Rankings for a quiz (132). Only first attempts count.
abstract interface class LeaderboardRepository {
  Future<List<LeaderboardEntry>> fetchLeaderboard(
    String quizId, {
    LeaderboardScope scope = LeaderboardScope.classScope,
  });
}
