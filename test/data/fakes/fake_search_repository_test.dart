import 'package:classmeet/data/fakes/fake_config.dart';
import 'package:classmeet/data/fakes/fake_search_repository.dart';
import 'package:classmeet/data/models/search_result.dart';
import 'package:classmeet/data/repositories/repository_exception.dart';
import 'package:flutter_test/flutter_test.dart';

const _empty = FakeConfig(scenario: FakeScenario.empty, latency: Duration.zero);
const _error = FakeConfig(scenario: FakeScenario.error, latency: Duration.zero);

void main() {
  late FakeSearchRepository repo;
  setUp(() => repo = FakeSearchRepository(FakeConfig.instant));

  test('recent searches match frame 12', () async {
    expect(await repo.fetchRecentSearches(), [
      'Data Structures midterm',
      'Normalization',
      'Networking 112',
    ]);
  });

  test('clearRecentSearches persists', () async {
    await repo.clearRecentSearches();
    expect(await repo.fetchRecentSearches(), isEmpty);
  });

  test('an empty query returns everything', () async {
    final r = await repo.search('');
    expect(r.classes, hasLength(1));
    expect(r.materials, hasLength(2));
    expect(r.people.map((p) => p.name), [
      'Arabela Matias',
      'Bryan Ramos',
      'Joshua Bete',
    ]);
    expect(r.classes.first.title, 'ITE13 - Introduction to Computing');
    expect(r.materials.first.subtitle, 'Created by Ara Matias');
    expect(r.people.last.schoolName, 'Father Saturnino Urios University');
  });

  test('filters case-insensitively by substring', () async {
    final r = await repo.search('RHEA');
    expect(r.classes, hasLength(1));
    expect(r.materials, isEmpty);
    expect(r.people, isEmpty);
    final visual = await repo.search('visual');
    expect(visual.materials.single.title, 'Visual Computing Fundamentals');
    expect((await repo.search('zzz')).isEmpty, isTrue);
  });

  test('category narrows the results', () async {
    final r = await repo.search('', category: SearchCategory.people);
    expect(r.people, hasLength(3));
    expect(r.classes, isEmpty);
    expect(r.materials, isEmpty);
  });

  test('empty scenario returns nothing', () async {
    final r = FakeSearchRepository(_empty);
    expect(await r.fetchRecentSearches(), isEmpty);
    expect((await r.search('')).isEmpty, isTrue);
  });

  test('error scenario throws', () {
    final r = FakeSearchRepository(_error);
    expect(r.fetchRecentSearches(), throwsA(isA<RepositoryException>()));
    expect(r.clearRecentSearches(), throwsA(isA<RepositoryException>()));
    expect(r.search('a'), throwsA(isA<RepositoryException>()));
  });
}
