/// What kind of quest it is (8, 14).
enum QuestKind { daily, milestone, survey }

/// Where a quest stands (14): the button shows "Reward claimed" etc.
enum QuestStatus { available, completed, claimed, locked }

/// A talon-earning quest (8 "Earn more talon credits", 14 daily quests).
final class Quest {
  const Quest({
    required this.id,
    required this.title,
    required this.kind,
    required this.rewardTalons,
    this.done = 0,
    this.total = 0,
    this.status = QuestStatus.available,
    this.resetsAt,
    this.availableUntil,
    this.durationMinutes,
  });

  final String id;
  final String title;
  final QuestKind kind;
  final int rewardTalons;

  /// "6 of 7 days completed" is done 6, total 7.
  final int done;
  final int total;
  final QuestStatus status;

  /// "Resets at midnight" / "Resets tomorrow".
  final DateTime? resetsAt;

  /// "Available until Sunday".
  final DateTime? availableUntil;

  /// "1 minute" on the survey quest.
  final int? durationMinutes;

  /// 0 when [total] is 0, clamped to 0..1.
  double get fraction => total <= 0 ? 0 : (done / total).clamp(0.0, 1.0);

  /// Steps left, never below 0.
  int get remaining => total > done ? total - done : 0;

  Quest copyWith({
    String? id,
    String? title,
    QuestKind? kind,
    int? rewardTalons,
    int? done,
    int? total,
    QuestStatus? status,
    DateTime? resetsAt,
    DateTime? availableUntil,
    int? durationMinutes,
  }) {
    return Quest(
      id: id ?? this.id,
      title: title ?? this.title,
      kind: kind ?? this.kind,
      rewardTalons: rewardTalons ?? this.rewardTalons,
      done: done ?? this.done,
      total: total ?? this.total,
      status: status ?? this.status,
      resetsAt: resetsAt ?? this.resetsAt,
      availableUntil: availableUntil ?? this.availableUntil,
      durationMinutes: durationMinutes ?? this.durationMinutes,
    );
  }
}
