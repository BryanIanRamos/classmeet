import '../../models/offline_pack.dart';

const _mb = 1024 * 1024;

/// Frame 90. (Frame 92's "4 items saved · 28 MB" card disagrees with these
/// numbers; 90 wins.)
const sampleOfflinePacks = [
  OfflinePack(
    id: 'ite13-weeks-1-4',
    title: 'ITE 13 · Weeks 1 to 4',
    contentsLabel: 'Reviewers + 3 quizzes',
    sizeBytes: 48 * _mb,
  ),
  OfflinePack(
    id: 'csc126-midterm',
    title: 'CSC126 · Midterm pack',
    contentsLabel: '2 reviewers + flashcards',
    sizeBytes: 30 * _mb,
  ),
  OfflinePack(
    id: 'ite16-finals',
    title: 'ITE16 · Finals pack',
    contentsLabel: '1 reviewer',
    sizeBytes: 22 * _mb,
  ),
];

/// "Storage used 120 MB / 500 MB" (the packs add up to 100 MB; the rest is
/// cache).
const sampleStorageUsage = StorageUsage(
  usedBytes: 120 * _mb,
  totalBytes: 500 * _mb,
);

/// Both toggles are on in the design.
const sampleDownloadSettings = DownloadSettings();
