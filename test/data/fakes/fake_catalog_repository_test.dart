import 'package:classmeet/data/fakes/fake_catalog_repository.dart';
import 'package:classmeet/data/fakes/fake_config.dart';
import 'package:classmeet/data/repositories/repository_exception.dart';
import 'package:flutter_test/flutter_test.dart';

const _empty = FakeConfig(scenario: FakeScenario.empty, latency: Duration.zero);
const _error = FakeConfig(scenario: FakeScenario.error, latency: Duration.zero);

void main() {
  final repo = FakeCatalogRepository(FakeConfig.instant);

  test('schools include the two designed ones', () async {
    final names = (await repo.fetchSchools()).map((s) => s.name);
    expect(names, contains('Caraga State University'));
    expect(names, contains('Father Saturnino Urios University'));
  });

  test('colleges and programs are filtered by parent', () async {
    final colleges = await repo.fetchColleges('csu');
    expect(colleges, isNotEmpty);
    expect(colleges.every((c) => c.schoolId == 'csu'), isTrue);
    final programs = await repo.fetchPrograms(colleges.first.id);
    expect(programs.map((p) => p.name), contains('BS Information Technology'));
    expect(programs.every((p) => p.collegeId == colleges.first.id), isTrue);
    expect(await repo.fetchColleges('nope'), isEmpty);
    expect(await repo.fetchPrograms('nope'), isEmpty);
  });

  test('subjects are the six chips of frame 97', () async {
    final subjects = await repo.fetchSubjects();
    expect(subjects.map((s) => s.name), [
      'Networking I',
      'Database II',
      'Computer Programming',
      'Introduction to Computing',
      'HCI',
      'Data Structures and Algorithms',
    ]);
    expect(await repo.fetchSubjects(programId: 'csu-bsit'), hasLength(6));
  });

  test('empty scenario returns empty lists', () async {
    final r = FakeCatalogRepository(_empty);
    expect(await r.fetchSchools(), isEmpty);
    expect(await r.fetchColleges('csu'), isEmpty);
    expect(await r.fetchPrograms('csu-ccis'), isEmpty);
    expect(await r.fetchSubjects(), isEmpty);
  });

  test('error scenario throws', () {
    final r = FakeCatalogRepository(_error);
    expect(r.fetchSchools(), throwsA(isA<RepositoryException>()));
    expect(r.fetchColleges('csu'), throwsA(isA<RepositoryException>()));
    expect(r.fetchPrograms('x'), throwsA(isA<RepositoryException>()));
    expect(r.fetchSubjects(), throwsA(isA<RepositoryException>()));
  });
}
