import '../models/catalog.dart';
import '../repositories/catalog_repository.dart';
import 'fake_config.dart';
import 'samples/catalog_samples.dart';

/// Read-only [CatalogRepository] over the sample schools, colleges, programs
/// and subjects. An unknown school or college has no children (empty list).
class FakeCatalogRepository implements CatalogRepository {
  FakeCatalogRepository(this._config, {DateTime Function()? clock});

  final FakeConfig _config;

  @override
  Future<List<School>> fetchSchools() =>
      _config.answerList('fetchSchools', () => sampleSchools);

  @override
  Future<List<College>> fetchColleges(String schoolId) => _config.answerList(
    'fetchColleges',
    () => [
      for (final college in sampleColleges)
        if (college.schoolId == schoolId) college,
    ],
  );

  @override
  Future<List<Program>> fetchPrograms(String collegeId) => _config.answerList(
    'fetchPrograms',
    () => [
      for (final program in samplePrograms)
        if (program.collegeId == collegeId) program,
    ],
  );

  /// The subject chips are the same for every program.
  @override
  Future<List<Subject>> fetchSubjects({String? programId}) =>
      _config.answerList('fetchSubjects', () => sampleSubjects);
}
