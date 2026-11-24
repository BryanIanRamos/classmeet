import '../models/study_class.dart';

/// The user's classes (93, 85) and joining one by code or QR (13.1).
abstract interface class ClassRepository {
  Future<List<StudyClass>> fetchClasses();

  Future<StudyClass> fetchClass(String classId);

  /// Joins the class with [code]. Throws a `RepositoryException` for an
  /// unknown code.
  Future<StudyClass> joinClass(String code);
}
