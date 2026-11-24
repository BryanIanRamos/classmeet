import '../../models/leaderboard.dart';

/// 132 "Class leaderboard". The fake serves the same rows for every quiz and
/// every scope (Friend / Class / Link).
const List<LeaderboardEntry> sampleLeaderboard = [
  LeaderboardEntry(
    rank: 1,
    name: 'Joshua Rosales',
    duration: Duration(minutes: 4, seconds: 12),
    percent: 100,
    correct: 20,
    total: 20,
  ),
  LeaderboardEntry(
    rank: 2,
    name: 'Big Mac',
    visibility: RankingVisibility.nickname,
    duration: Duration(minutes: 5, seconds: 3),
    percent: 95,
    correct: 19,
    total: 20,
  ),
  LeaderboardEntry(
    rank: 3,
    name: 'Anonymous Hoot',
    visibility: RankingVisibility.anonymous,
    duration: Duration(minutes: 5, seconds: 58),
    percent: 90,
    correct: 18,
    total: 20,
  ),
  LeaderboardEntry(
    rank: 4,
    name: 'Owl_4821',
    visibility: RankingVisibility.nickname,
    duration: Duration(minutes: 6, seconds: 59),
    percent: 80,
    correct: 16,
    total: 20,
    isYou: true,
  ),
];
