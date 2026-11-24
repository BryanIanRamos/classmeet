import '../models/material.dart';
import '../repositories/material_repository.dart';
import '../repositories/repository_exception.dart';
import 'fake_config.dart';
import 'samples/material_samples.dart';

/// In-memory [MaterialRepository]. `createReviewer` adds to the library and
/// to Recently Created.
final class FakeMaterialRepository implements MaterialRepository {
  FakeMaterialRepository(this._config, {DateTime Function()? clock})
    : _clock = clock ?? DateTime.now {
    _materials = sampleMaterials(_clock());
  }

  /// "Recently Created" shows items from the last week.
  static const _recentWindow = Duration(days: 7);

  /// An upload is emitted in this many steps (0%, 25%, … 100%).
  static const _uploadSteps = 4;

  final FakeConfig _config;
  final DateTime Function() _clock;
  late final List<StudyMaterial> _materials;
  int _nextId = 1;

  @override
  Future<List<StudyMaterial>> fetchMaterials({
    String? classId,
    MaterialKind? kind,
  }) => _config.answerList('fetchMaterials', () {
    return [
      for (final m in _materials)
        if ((classId == null || m.classId == classId) &&
            (kind == null || m.kind == kind))
          m,
    ];
  });

  @override
  Future<List<StudyMaterial>> fetchInProgress() => _config.answerList(
    'fetchInProgress',
    () => [
      for (final m in _materials)
        if (m.modulesLeft > 0) m,
    ],
  );

  @override
  Future<List<StudyMaterial>> fetchRecent() =>
      _config.answerList('fetchRecent', () {
        final since = _clock().subtract(_recentWindow);
        // Newest first; among equal times, the one added last comes first.
        final recent = [
          for (var i = 0; i < _materials.length; i++)
            if (!_materials[i].createdAt.isBefore(since)) i,
        ];
        recent.sort((a, b) {
          final byTime = _materials[b].createdAt.compareTo(
            _materials[a].createdAt,
          );
          return byTime != 0 ? byTime : b.compareTo(a);
        });
        return [for (final i in recent) _materials[i]];
      });

  @override
  Future<StudyMaterial> fetchMaterial(String materialId) =>
      _config.answer('fetchMaterial', () => _find(materialId));

  StudyMaterial _find(String materialId) => _materials.firstWhere(
    (m) => m.id == materialId,
    orElse: () => throw RepositoryException('Unknown material "$materialId"'),
  );

  @override
  Stream<UploadItem> upload(String fileName, int totalBytes) async* {
    final delay = _config.latency;
    Future<void> pause() async {
      if (delay != null && delay > Duration.zero) {
        await Future<void>.delayed(delay);
      }
    }

    await pause();
    if (_config.scenario == FakeScenario.error) {
      throw const RepositoryException('upload failed (FAKE_SCENARIO=error)');
    }
    for (var step = 0; step <= _uploadSteps; step++) {
      if (step > 0) await pause();
      yield UploadItem(
        fileName: fileName,
        sentBytes: totalBytes * step ~/ _uploadSteps,
        totalBytes: totalBytes,
      );
    }
  }

  @override
  Future<StudyMaterial> createReviewer({
    required String classId,
    required String title,
    required List<UploadItem> uploads,
  }) => _config.answer('createReviewer', () {
    final material = StudyMaterial(
      id: 'created-${_nextId++}',
      classId: classId,
      title: title,
      kind: MaterialKind.reviewer,
      source: _sourceOf(uploads),
      sourceNote: uploads.length > 1
          ? 'Merged from ${uploads.length} files'
          : null,
      createdBy: 'Bryan', // the signed-in user's username (D-19)
      createdAt: _clock(),
      sizeBytes: uploads.fold<int>(0, (sum, u) => sum + u.totalBytes),
    );
    _materials.add(material);
    return material;
  });

  static MaterialSource _sourceOf(List<UploadItem> uploads) {
    if (uploads.isEmpty) return MaterialSource.text;
    final name = uploads.first.fileName.toLowerCase();
    if (name.endsWith('.jpg') ||
        name.endsWith('.jpeg') ||
        name.endsWith('.png')) {
      return MaterialSource.photo;
    }
    if (name.endsWith('.ppt') || name.endsWith('.pptx')) {
      return MaterialSource.powerPoint;
    }
    if (name.endsWith('.doc') || name.endsWith('.docx')) {
      return MaterialSource.word;
    }
    return MaterialSource.pdf;
  }
}
