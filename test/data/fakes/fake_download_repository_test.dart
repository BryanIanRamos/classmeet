import 'package:classmeet/data/fakes/fake_config.dart';
import 'package:classmeet/data/fakes/fake_download_repository.dart';
import 'package:classmeet/data/models/offline_pack.dart';
import 'package:classmeet/data/repositories/repository_exception.dart';
import 'package:flutter_test/flutter_test.dart';

const _mb = 1024 * 1024;
const _empty = FakeConfig(scenario: FakeScenario.empty, latency: Duration.zero);
const _error = FakeConfig(scenario: FakeScenario.error, latency: Duration.zero);

void main() {
  FakeDownloadRepository sample() => FakeDownloadRepository(FakeConfig.instant);

  group('sample', () {
    test('packs match frame 90', () async {
      final packs = await sample().fetchPacks();
      expect(packs.map((p) => p.title), [
        'ITE 13 · Weeks 1 to 4',
        'CSC126 · Midterm pack',
        'ITE16 · Finals pack',
      ]);
      expect(packs[0].contentsLabel, 'Reviewers + 3 quizzes');
      expect(packs[0].sizeBytes, 48 * _mb);
      expect(packs[1].contentsLabel, '2 reviewers + flashcards');
      expect(packs[2].contentsLabel, '1 reviewer');
    });

    test('storage is 120 MB of 500 MB', () async {
      final usage = await sample().fetchStorageUsage();
      expect(usage.usedBytes, 120 * _mb);
      expect(usage.totalBytes, 500 * _mb);
    });

    test('both settings are on', () async {
      final settings = await sample().fetchSettings();
      expect(settings.wifiOnly, isTrue);
      expect(settings.autoDownload, isTrue);
    });
  });

  group('writes', () {
    test('saveSettings persists', () async {
      final repo = sample();
      await repo.saveSettings(const DownloadSettings(wifiOnly: false));
      final settings = await repo.fetchSettings();
      expect(settings.wifiOnly, isFalse);
      expect(settings.autoDownload, isTrue);
    });

    test('removePack drops the pack and the storage used', () async {
      final repo = sample();
      await repo.removePack('csc126-midterm');
      final packs = await repo.fetchPacks();
      expect(packs.map((p) => p.id), ['ite13-weeks-1-4', 'ite16-finals']);
      expect((await repo.fetchStorageUsage()).usedBytes, 90 * _mb);
    });

    test('removing an unknown pack throws', () {
      expect(sample().removePack('nope'), throwsA(isA<RepositoryException>()));
    });

    test('samples are not mutated', () async {
      final a = sample();
      await a.removePack('ite16-finals');
      expect(await sample().fetchPacks(), hasLength(3));
    });
  });

  group('empty', () {
    test('no packs and 0 MB used', () async {
      final repo = FakeDownloadRepository(_empty);
      expect(await repo.fetchPacks(), isEmpty);
      final usage = await repo.fetchStorageUsage();
      expect(usage.usedBytes, 0);
      expect(usage.totalBytes, 500 * _mb);
    });
  });

  group('error', () {
    test('every method throws RepositoryException', () {
      final repo = FakeDownloadRepository(_error);
      final throwsRepo = throwsA(isA<RepositoryException>());
      expect(repo.fetchPacks(), throwsRepo);
      expect(repo.fetchStorageUsage(), throwsRepo);
      expect(repo.fetchSettings(), throwsRepo);
      expect(repo.saveSettings(const DownloadSettings()), throwsRepo);
      expect(repo.removePack('ite16-finals'), throwsRepo);
    });
  });
}
