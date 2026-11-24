/// Today's study goal on the Home hero card (8): "YOUR DAILY PROGRESS",
/// "3 activities remaining".
///
/// The study plan itself is not designed yet (GAP-09); Home only shows how
/// many of today's planned activities are left.
final class DailyProgress {
  const DailyProgress({this.activitiesDone = 0, this.activitiesTotal = 0});

  final int activitiesDone;
  final int activitiesTotal;

  /// Activities left today, never below 0.
  int get remaining =>
      activitiesTotal > activitiesDone ? activitiesTotal - activitiesDone : 0;

  /// 0 when nothing is planned, clamped to 0..1.
  double get fraction => activitiesTotal <= 0
      ? 0
      : (activitiesDone / activitiesTotal).clamp(0.0, 1.0);

  DailyProgress copyWith({int? activitiesDone, int? activitiesTotal}) {
    return DailyProgress(
      activitiesDone: activitiesDone ?? this.activitiesDone,
      activitiesTotal: activitiesTotal ?? this.activitiesTotal,
    );
  }
}

/// A deadline on the study plan, shown under "Coming up next" on Home (8):
/// "IT109 Midterm", "3 activities left · In 5 days", 67%.
final class PlanGoal {
  const PlanGoal({
    required this.id,
    required this.title,
    this.classId,
    required this.dueAt,
    this.activitiesDone = 0,
    this.activitiesTotal = 0,
  });

  final String id;

  /// e.g. "IT109 Midterm".
  final String title;
  final String? classId;

  /// When the exam or deadline is ("In 5 days").
  final DateTime dueAt;
  final int activitiesDone;
  final int activitiesTotal;

  /// Activities left before [dueAt], never below 0.
  int get remaining =>
      activitiesTotal > activitiesDone ? activitiesTotal - activitiesDone : 0;

  /// 0 when no activities are planned, clamped to 0..1.
  double get fraction => activitiesTotal <= 0
      ? 0
      : (activitiesDone / activitiesTotal).clamp(0.0, 1.0);

  PlanGoal copyWith({
    String? id,
    String? title,
    String? classId,
    DateTime? dueAt,
    int? activitiesDone,
    int? activitiesTotal,
  }) {
    return PlanGoal(
      id: id ?? this.id,
      title: title ?? this.title,
      classId: classId ?? this.classId,
      dueAt: dueAt ?? this.dueAt,
      activitiesDone: activitiesDone ?? this.activitiesDone,
      activitiesTotal: activitiesTotal ?? this.activitiesTotal,
    );
  }
}
