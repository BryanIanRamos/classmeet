/// A downloaded pack, e.g. "ITE 13 · Weeks 1 to 4" (90, 92).
final class OfflinePack {
  const OfflinePack({
    required this.id,
    required this.title,
    required this.contentsLabel,
    required this.sizeBytes,
  });

  final String id;
  final String title;

  /// e.g. "Reviewers + 3 quizzes".
  final String contentsLabel;
  final int sizeBytes;

  OfflinePack copyWith({
    String? id,
    String? title,
    String? contentsLabel,
    int? sizeBytes,
  }) => OfflinePack(
    id: id ?? this.id,
    title: title ?? this.title,
    contentsLabel: contentsLabel ?? this.contentsLabel,
    sizeBytes: sizeBytes ?? this.sizeBytes,
  );
}

/// The "Storage used 120 MB / 500 MB" meter (90).
final class StorageUsage {
  const StorageUsage({required this.usedBytes, required this.totalBytes});

  final int usedBytes;
  final int totalBytes;

  /// Used share, 0..1 (0 when total is 0).
  double get fraction =>
      totalBytes <= 0 ? 0 : (usedBytes / totalBytes).clamp(0.0, 1.0);

  StorageUsage copyWith({int? usedBytes, int? totalBytes}) => StorageUsage(
    usedBytes: usedBytes ?? this.usedBytes,
    totalBytes: totalBytes ?? this.totalBytes,
  );
}

/// Download toggles on the downloads screen (90).
final class DownloadSettings {
  const DownloadSettings({this.wifiOnly = true, this.autoDownload = true});

  final bool wifiOnly;
  final bool autoDownload;

  DownloadSettings copyWith({bool? wifiOnly, bool? autoDownload}) =>
      DownloadSettings(
        wifiOnly: wifiOnly ?? this.wifiOnly,
        autoDownload: autoDownload ?? this.autoDownload,
      );
}
