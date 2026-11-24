import '../models/offline_pack.dart';
import '../repositories/download_repository.dart';
import '../repositories/repository_exception.dart';
import 'fake_config.dart';
import 'samples/download_samples.dart';

/// In-memory [DownloadRepository]; removing a pack lowers the storage used.
final class FakeDownloadRepository implements DownloadRepository {
  FakeDownloadRepository(this._config);

  final FakeConfig _config;

  final List<OfflinePack> _packs = [...sampleOfflinePacks];
  StorageUsage _usage = sampleStorageUsage;
  DownloadSettings _settings = sampleDownloadSettings;

  @override
  Future<List<OfflinePack>> fetchPacks() =>
      _config.answerList('fetchPacks', () => List.of(_packs));

  @override
  Future<StorageUsage> fetchStorageUsage() => _config.answer(
    'fetchStorageUsage',
    () => _usage,
    empty: () => StorageUsage(usedBytes: 0, totalBytes: _usage.totalBytes),
  );

  @override
  Future<DownloadSettings> fetchSettings() =>
      _config.answer('fetchSettings', () => _settings);

  @override
  Future<void> saveSettings(DownloadSettings settings) =>
      _config.answer<void>('saveSettings', () => _settings = settings);

  @override
  Future<void> removePack(String packId) =>
      _config.answer<void>('removePack', () {
        final index = _packs.indexWhere((p) => p.id == packId);
        if (index < 0) throw RepositoryException('Unknown pack "$packId"');
        final removed = _packs.removeAt(index);
        final left = _usage.usedBytes - removed.sizeBytes;
        _usage = _usage.copyWith(usedBytes: left < 0 ? 0 : left);
      });
}
