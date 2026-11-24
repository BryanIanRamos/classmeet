import 'package:classmeet/data/fakes/fake_config.dart';
import 'package:classmeet/data/fakes/fake_study_plan_repository.dart';
import 'package:classmeet/data/repositories/repository_exception.dart';
import 'package:flutter_test/flutter_test.dart';

const _empty = FakeConfig(scenario: FakeScenario.empty, latency: Duration.zero);
const _error = FakeConfig(scenario: FakeScenario.error, latency: Duration.zero);

void main() {
  final now = DateTime(2026, 11, 24, 19, 30);
  FakeStudyPlanRepository repo(FakeConfig config) =>
      FakeStudyPlanRepository(config, clock: () => now);

  test('daily progress matches frame 8: 3 activities remaining', () async {
    final p = await repo(FakeConfig.instant).fetchDailyProgress();
    expect(p.remaining, 3);
  });

  test('upcoming goals are soonest first; the first is frame 8', () async {
    final goals = await repo(FakeConfig.instant).fetchUpcoming();
    expect(goals, hasLength(2));
    final first = goals.first;
    expect(first.title, 'IT109 Midterm');
    expect(first.remaining, 3);
    expect((first.fraction * 100).round(), 67);
    expect(first.dueAt, DateTime(2026, 11, 29));
    expect(goals[1].dueAt.isAfter(first.dueAt), isTrue);
  });

  test('empty scenario plans nothing', () async {
    final r = repo(_empty);
    expect((await r.fetchDailyProgress()).activitiesTotal, 0);
    expect(await r.fetchUpcoming(), isEmpty);
  });

  test('error scenario throws', () {
    final r = repo(_error);
    expect(r.fetchDailyProgress(), throwsA(isA<RepositoryException>()));
    expect(r.fetchUpcoming(), throwsA(isA<RepositoryException>()));
  });
}
