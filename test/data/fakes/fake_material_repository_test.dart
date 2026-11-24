import 'package:classmeet/data/fakes/fake_config.dart';
import 'package:classmeet/data/fakes/fake_material_repository.dart';
import 'package:classmeet/data/models/material.dart';
import 'package:classmeet/data/repositories/repository_exception.dart';
import 'package:flutter_test/flutter_test.dart';

const _empty = FakeConfig(scenario: FakeScenario.empty, latency: Duration.zero);
const _error = FakeConfig(scenario: FakeScenario.error, latency: Duration.zero);

final _now = DateTime(2026, 11, 24, 10);

void main() {
  late FakeMaterialRepository repo;
  setUp(
    () => repo = FakeMaterialRepository(FakeConfig.instant, clock: () => _now),
  );

  group('sample', () {
    test('ite13 weekly reviewers match frame 85', () async {
      final list = await repo.fetchMaterials(
        classId: 'ite13',
        kind: MaterialKind.reviewer,
      );
      expect(list.map((m) => m.id), ['week-1', 'week-2', 'week-3', 'week-4']);
      final w1 = list[0];
      expect(w1.title, 'Computer Basics');
      expect(w1.week, 1);
      expect(w1.source, MaterialSource.pdf);
      expect(w1.sourceNote, 'Merged from 2 files');
      expect(w1.fraction, 0.4);
      expect(list[1].title, 'Number Systems');
      expect(list[1].source.label, 'Photo of handout');
      expect(list[2].title, 'Hardware');
      expect(list[2].source.label, 'PowerPoint');
      expect(list[2].pagesOrSlides, 24);
      expect(list[3].title, 'Software');
      expect(list[3].source.label, 'Word document');
      expect(list[3].pagesOrSlides, 12);
    });

    test('every kind has a few materials', () async {
      for (final kind in MaterialKind.values) {
        final list = await repo.fetchMaterials(kind: kind);
        expect(list.length, greaterThanOrEqualTo(2), reason: kind.name);
        expect(list.every((m) => m.kind == kind), isTrue);
      }
    });

    test('in progress is the Data Structure Reviewer', () async {
      final list = await repo.fetchInProgress();
      expect(list.map((m) => m.title), ['Data Structure Reviewer']);
      expect(list.single.fraction, 0.4);
      expect(list.single.modulesLeft, 1);
    });

    test('recently created is newest first', () async {
      final list = await repo.fetchRecent();
      expect(list.map((m) => m.title), [
        'Networking Quiz Reviewer',
        'OSI Model Mind Map',
      ]);
      expect(list[0].createdAt, _now);
      expect(list[1].createdAt, _now.subtract(const Duration(days: 1)));
    });

    test('search materials are by Ara Matias and Joshua Bete', () async {
      final a = await repo.fetchMaterial('data-structures-algorithms');
      expect(a.title, 'Data Structures and Algorithms');
      expect(a.createdBy, 'Ara Matias');
      final b = await repo.fetchMaterial('visual-computing-fundamentals');
      expect(b.createdBy, 'Joshua Bete');
    });

    test('two downloaded items for 92', () async {
      final all = await repo.fetchMaterials();
      final downloaded = all.where((m) => m.isDownloaded).toList();
      expect(downloaded.map((m) => m.title), [
        'Data Structures Reviewer',
        'Networking Flashcards',
      ]);
    });

    test('fetchMaterial week-1 and an unknown id', () async {
      expect((await repo.fetchMaterial('week-1')).title, 'Computer Basics');
      expect(repo.fetchMaterial('nope'), throwsA(isA<RepositoryException>()));
    });
  });

  group('upload', () {
    test('progress is monotonic and ends done', () async {
      final items = await repo.upload('IMG_2041.jpg', 2000).toList();
      expect(items.length, greaterThanOrEqualTo(5));
      expect(items.first.sentBytes, 0);
      expect(items.every((i) => i.fileName == 'IMG_2041.jpg'), isTrue);
      for (var i = 1; i < items.length; i++) {
        expect(items[i].sentBytes, greaterThan(items[i - 1].sentBytes));
      }
      expect(items.last.isDone, isTrue);
      expect(items.last.sentBytes, 2000);
      expect(items.sublist(0, items.length - 1).any((i) => i.isDone), isFalse);
    });

    test('the error scenario emits a RepositoryException', () {
      final r = FakeMaterialRepository(_error);
      expect(
        r.upload('a.pdf', 100).toList(),
        throwsA(isA<RepositoryException>()),
      );
    });

    test('the empty scenario still uploads', () async {
      final r = FakeMaterialRepository(_empty);
      expect((await r.upload('a.pdf', 100).last).isDone, isTrue);
    });
  });

  group('createReviewer', () {
    const uploads = [
      UploadItem(fileName: 'notes.pdf', sentBytes: 1000, totalBytes: 1000),
      UploadItem(fileName: 'IMG_2042.jpg', sentBytes: 500, totalBytes: 500),
    ];

    test('adds to the class and to Recently Created', () async {
      final created = await repo.createReviewer(
        classId: 'ite13',
        title: 'Week 5',
        uploads: uploads,
      );
      expect(created.title, 'Week 5');
      expect(created.classId, 'ite13');
      expect(created.source, MaterialSource.pdf);
      expect(created.sourceNote, 'Merged from 2 files');
      expect(created.sizeBytes, 1500);
      expect(created.createdAt, _now);

      expect((await repo.fetchMaterial(created.id)).title, 'Week 5');
      final ite13 = await repo.fetchMaterials(classId: 'ite13');
      expect(ite13.map((m) => m.id), contains(created.id));
      final recent = await repo.fetchRecent();
      expect(recent.first.id, created.id);
      expect(recent, hasLength(3));
    });

    test('ids are unique and a photo upload is a photo', () async {
      final a = await repo.createReviewer(
        classId: 'ite13',
        title: 'A',
        uploads: [uploads[1]],
      );
      final b = await repo.createReviewer(
        classId: 'ite13',
        title: 'B',
        uploads: uploads,
      );
      expect(a.id, isNot(b.id));
      expect(a.source, MaterialSource.photo);
      expect(a.sourceNote, isNull);
    });

    test('a new repository starts from the samples again', () async {
      await repo.createReviewer(classId: 'ite13', title: 'X', uploads: uploads);
      final fresh = FakeMaterialRepository(
        FakeConfig.instant,
        clock: () => _now,
      );
      expect(await fresh.fetchRecent(), hasLength(2));
    });
  });

  group('empty', () {
    test('lists are empty', () async {
      final r = FakeMaterialRepository(_empty, clock: () => _now);
      expect(await r.fetchMaterials(), isEmpty);
      expect(await r.fetchInProgress(), isEmpty);
      expect(await r.fetchRecent(), isEmpty);
    });
  });

  group('error', () {
    test('every method throws RepositoryException', () {
      final r = FakeMaterialRepository(_error, clock: () => _now);
      final throwsRepo = throwsA(isA<RepositoryException>());
      expect(r.fetchMaterials(), throwsRepo);
      expect(r.fetchInProgress(), throwsRepo);
      expect(r.fetchRecent(), throwsRepo);
      expect(r.fetchMaterial('week-1'), throwsRepo);
      expect(
        r.createReviewer(classId: 'ite13', title: 'x', uploads: const []),
        throwsRepo,
      );
    });
  });
}
