import 'package:classmeet/data/fakes/fake_class_repository.dart';
import 'package:classmeet/data/fakes/fake_config.dart';
import 'package:classmeet/data/repositories/repository_exception.dart';
import 'package:flutter_test/flutter_test.dart';

const _empty = FakeConfig(scenario: FakeScenario.empty, latency: Duration.zero);
const _error = FakeConfig(scenario: FakeScenario.error, latency: Duration.zero);

void main() {
  late FakeClassRepository repo;
  setUp(() => repo = FakeClassRepository(FakeConfig.instant));

  test('fetchClasses returns the 3 joined classes', () async {
    final classes = await repo.fetchClasses();
    expect(classes.map((c) => c.id), ['ite13', 'csc126', 'it111']);
    final ite13 = classes.first;
    expect(ite13.title, 'Introduction to Computing');
    expect(ite13.teacher, 'Prof. Rhea Santos');
    expect(ite13.hasNewUpdates, isFalse);
  });

  test('fetchClass returns ITE13 counts from frame 85', () async {
    final c = await repo.fetchClass('ite13');
    expect(
      (c.reviewerCount, c.quizCount, c.setCount, c.plannerCount),
      (11, 8, 5, 1),
    );
  });

  test('fetchClass with an unknown id fails', () {
    expect(repo.fetchClass('nope'), throwsA(isA<RepositoryException>()));
  });

  test('joinClass adds the 4th class and persists', () async {
    final joined = await repo.joinClass('ite16-2026');
    expect(joined.code, 'ITE16');
    expect(joined.teacher, 'Prof. Dave Ramos');
    expect((await repo.fetchClasses()).map((c) => c.id), contains('ite16'));
    await repo.joinClass('ITE16-2026');
    expect(await repo.fetchClasses(), hasLength(4));
  });

  test('joinClass with an unknown code fails', () async {
    await expectLater(
      repo.joinClass('WRONG'),
      throwsA(isA<RepositoryException>()),
    );
    expect(await repo.fetchClasses(), hasLength(3));
  });

  test('empty scenario returns no classes but details still resolve', () async {
    final r = FakeClassRepository(_empty);
    expect(await r.fetchClasses(), isEmpty);
    expect((await r.fetchClass('ite13')).code, 'ITE13');
    await r.joinClass('ITE16-2026');
    expect(await r.fetchClasses(), hasLength(1));
  });

  test('error scenario throws', () {
    final r = FakeClassRepository(_error);
    expect(r.fetchClasses(), throwsA(isA<RepositoryException>()));
    expect(r.fetchClass('ite13'), throwsA(isA<RepositoryException>()));
    expect(r.joinClass('ITE16-2026'), throwsA(isA<RepositoryException>()));
  });
}
