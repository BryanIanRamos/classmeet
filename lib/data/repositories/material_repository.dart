import '../models/material.dart';

/// Study materials: the library (92), a class's weekly reviewers (85) and
/// adding a reviewer from uploads (86).
abstract interface class MaterialRepository {
  Future<List<StudyMaterial>> fetchMaterials({
    String? classId,
    MaterialKind? kind,
  });

  /// "In Progress" (92): started and not finished.
  Future<List<StudyMaterial>> fetchInProgress();

  /// "Recently Created" (92), newest first.
  Future<List<StudyMaterial>> fetchRecent();

  Future<StudyMaterial> fetchMaterial(String materialId);

  /// Uploads one file, emitting progress until [UploadItem.isDone] (86).
  Stream<UploadItem> upload(String fileName, int totalBytes);

  /// Turns finished uploads into a reviewer in [classId] (86 Continue).
  Future<StudyMaterial> createReviewer({
    required String classId,
    required String title,
    required List<UploadItem> uploads,
  });
}
