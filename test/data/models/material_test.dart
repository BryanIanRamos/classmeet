import 'package:classmeet/data/models/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final created = DateTime(2026);
  final m = StudyMaterial(
    id: 'm1',
    classId: 'c1',
    title: 'Computer Basics',
    week: 1,
    kind: MaterialKind.reviewer,
    source: MaterialSource.pdf,
    sourceNote: 'Merged from 2 files',
    pagesOrSlides: 12,
    modulesLeft: 1,
    readDone: 2,
    readTotal: 5,
    createdBy: 'u1',
    createdAt: created,
    sizeBytes: 100,
    isDownloaded: true,
  );

  test('const construction', () {
    const x = UploadItem(fileName: 'a.jpg', totalBytes: 10);
    expect(x.sentBytes, 0);
  });

  test('copyWith keeps all fields', () {
    final c = m.copyWith();
    expect(c.id, m.id);
    expect(c.classId, m.classId);
    expect(c.title, m.title);
    expect(c.week, m.week);
    expect(c.kind, m.kind);
    expect(c.source, m.source);
    expect(c.sourceNote, m.sourceNote);
    expect(c.pagesOrSlides, m.pagesOrSlides);
    expect(c.modulesLeft, m.modulesLeft);
    expect(c.readDone, m.readDone);
    expect(c.readTotal, m.readTotal);
    expect(c.createdBy, m.createdBy);
    expect(c.createdAt, m.createdAt);
    expect(c.sizeBytes, m.sizeBytes);
    expect(c.isDownloaded, m.isDownloaded);
  });

  test('copyWith changes one field', () {
    final c = m.copyWith(title: 'X');
    expect(c.title, 'X');
    expect(c.id, m.id);
    expect(c.readDone, m.readDone);
  });

  test('fraction at 0, partial and over total', () {
    expect(m.copyWith(readTotal: 0).fraction, 0);
    expect(m.fraction, closeTo(0.4, 1e-9));
    expect(m.copyWith(readDone: 9).fraction, 1);
  });

  test('UploadItem', () {
    const u = UploadItem(fileName: 'a', sentBytes: 4, totalBytes: 10);
    expect(u.fraction, closeTo(0.4, 1e-9));
    expect(u.isDone, isFalse);
    expect(u.copyWith().fileName, 'a');
    expect(u.copyWith().sentBytes, 4);
    expect(u.copyWith().totalBytes, 10);
    expect(u.copyWith(sentBytes: 10).isDone, isTrue);
    expect(u.copyWith(sentBytes: 99).fraction, 1);
    expect(u.copyWith(totalBytes: 0).fraction, 0);
  });

  test('enum labels', () {
    expect(MaterialKind.values.map((e) => e.label), [
      'Reviewers',
      'Quizzes',
      'Flashcards',
      'Mind maps',
    ]);
    expect(MaterialSource.values.map((e) => e.label), [
      'PDF',
      'Photo of handout',
      'PowerPoint',
      'Word document',
      'Pasted text',
    ]);
  });
}
