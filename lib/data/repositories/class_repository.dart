import '../models/study_class.dart';

/// The user's classes (93, 85) and joining one by code or QR (13.1).
abstract interface class ClassRepository {
  Future<List<StudyClass>> fetchClasses();

  Future<StudyClass> fetchClass(String classId);

  /// Looks up the class behind [code] without joining it, so the student
  /// can check its name and teacher first (13.1 "Before you join"). Codes
  /// are case-insensitive. Throws a `RepositoryException` for an unknown
  /// code.
  Future<StudyClass> findClassByCode(String code);

  /// Joins the class with [code]. Joining a class twice changes nothing.
  /// Throws a `RepositoryException` for an unknown code.
  Future<StudyClass> joinClass(String code);
}
