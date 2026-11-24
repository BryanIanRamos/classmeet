import '../models/offline_pack.dart';

/// Offline packs and their settings (90, 92 "Downloaded for offline").
abstract interface class DownloadRepository {
  Future<List<OfflinePack>> fetchPacks();

  Future<StorageUsage> fetchStorageUsage();

  Future<DownloadSettings> fetchSettings();

  Future<void> saveSettings(DownloadSettings settings);

  Future<void> removePack(String packId);
}
