import '../models/study_plan.dart';
import '../repositories/study_plan_repository.dart';
import 'fake_config.dart';
import 'samples/study_plan_samples.dart';

/// In-memory [StudyPlanRepository]. Due dates count from the clock, so
/// "In 5 days" stays true whenever the app runs. The empty scenario has
/// nothing planned: no activities today and no deadlines.
class FakeStudyPlanRepository implements StudyPlanRepository {
  FakeStudyPlanRepository(this._config, {DateTime Function()? clock})
    : _clock = clock ?? DateTime.now;

  final FakeConfig _config;
  final DateTime Function() _clock;

  @override
  Future<DailyProgress> fetchDailyProgress() => _config.answer(
    'fetchDailyProgress',
    () => sampleDailyProgress,
    empty: () => const DailyProgress(),
  );

  @override
  Future<List<PlanGoal>> fetchUpcoming() =>
      _config.answerList('fetchUpcoming', () => planGoalSamples(_clock()));
}
