/// The user's balances: talon credits, study points and XP (8, 14, 122, 132).
final class Wallet {
  const Wallet({this.talons = 0, this.studyPoints = 0, this.xp = 0});

  final int talons;
  final int studyPoints;
  final int xp;

  Wallet copyWith({int? talons, int? studyPoints, int? xp}) {
    return Wallet(
      talons: talons ?? this.talons,
      studyPoints: studyPoints ?? this.studyPoints,
      xp: xp ?? this.xp,
    );
  }
}

/// Progress toward the next talon reward, e.g. "+10 talons", 171/300 (14).
final class RewardProgress {
  const RewardProgress({
    required this.nextRewardTalons,
    required this.done,
    required this.total,
  });

  final int nextRewardTalons;
  final int done;
  final int total;

  /// 0 when [total] is 0, clamped to 0..1.
  double get fraction => total <= 0 ? 0 : (done / total).clamp(0.0, 1.0);

  RewardProgress copyWith({int? nextRewardTalons, int? done, int? total}) {
    return RewardProgress(
      nextRewardTalons: nextRewardTalons ?? this.nextRewardTalons,
      done: done ?? this.done,
      total: total ?? this.total,
    );
  }
}
