/// How the user appears in rankings (133).
enum RankingVisibility {
  displayName('Display name'),
  nickname('Nickname'),
  anonymous('Anonymous');

  const RankingVisibility(this.label);
  final String label;
}

/// Leaderboard tabs (132).
enum LeaderboardScope {
  friend('Friend'),
  classScope('Class'),
  link('Link');

  const LeaderboardScope(this.label);
  final String label;
}

/// A row of the class leaderboard (132).
final class LeaderboardEntry {
  const LeaderboardEntry({
    required this.rank,
    required this.name,
    this.visibility = RankingVisibility.displayName,
    required this.duration,
    required this.percent,
    required this.correct,
    required this.total,
    this.isYou = false,
  });

  final int rank;
  final String name;
  final RankingVisibility visibility;
  final Duration duration;
  final int percent;
  final int correct;
  final int total;
  final bool isYou;

  LeaderboardEntry copyWith({
    int? rank,
    String? name,
    RankingVisibility? visibility,
    Duration? duration,
    int? percent,
    int? correct,
    int? total,
    bool? isYou,
  }) => LeaderboardEntry(
    rank: rank ?? this.rank,
    name: name ?? this.name,
    visibility: visibility ?? this.visibility,
    duration: duration ?? this.duration,
    percent: percent ?? this.percent,
    correct: correct ?? this.correct,
    total: total ?? this.total,
    isYou: isYou ?? this.isYou,
  );
}
