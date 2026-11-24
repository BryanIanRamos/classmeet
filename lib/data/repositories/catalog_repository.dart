import '../models/catalog.dart';

/// Schools, colleges, programs and subjects for the dependent dropdowns (96)
/// and the subject chips (97).
abstract interface class CatalogRepository {
  Future<List<School>> fetchSchools();

  Future<List<College>> fetchColleges(String schoolId);

  Future<List<Program>> fetchPrograms(String collegeId);

  /// Subjects of a program, or a general list when [programId] is null.
  Future<List<Subject>> fetchSubjects({String? programId});
}
