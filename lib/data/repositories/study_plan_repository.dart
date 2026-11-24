import '../models/study_plan.dart';

/// The student's study plan as Home shows it (8): today's progress on the
/// hero card and the next deadlines under "Coming up next". The full plan
/// screen is not designed yet (GAP-09).
abstract interface class StudyPlanRepository {
  Future<DailyProgress> fetchDailyProgress();

  /// Upcoming deadlines, soonest first.
  Future<List<PlanGoal>> fetchUpcoming();
}
