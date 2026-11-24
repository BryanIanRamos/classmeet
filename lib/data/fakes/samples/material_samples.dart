import '../../models/material.dart';

const _mb = 1024 * 1024;

/// The study library, dated relative to [now] so "Created today" and
/// "Created yesterday" (92) hold whenever the app runs.
///
/// Frame 85 gives the ITE13 weekly reviewers, 92 the In Progress and Recently
/// Created cards and the two downloaded items, and 12 the two search results
/// (ids match the search samples). The rest are // sample fillers so every
/// [MaterialKind] has a few items; the "11 reviewers / 8 quizzes / 5 sets /
/// 6 maps" counts of 85 and 92 belong to `StudyClass`, not to this list.
List<StudyMaterial> sampleMaterials(DateTime now) {
  DateTime ago(int days) => now.subtract(Duration(days: days));
  return [
    // 85: ITE13 weekly reviewers.
    StudyMaterial(
      id: 'week-1',
      classId: 'ite13',
      title: 'Computer Basics',
      week: 1,
      kind: MaterialKind.reviewer,
      source: MaterialSource.pdf,
      sourceNote: 'Merged from 2 files',
      readDone: 40,
      readTotal: 100,
      createdBy: 'Prof. Rhea Santos',
      createdAt: ago(21),
      sizeBytes: 6 * _mb,
    ),
    StudyMaterial(
      id: 'week-2',
      classId: 'ite13',
      title: 'Number Systems',
      week: 2,
      kind: MaterialKind.reviewer,
      source: MaterialSource.photo,
      sourceNote: 'OCR',
      createdBy: 'Prof. Rhea Santos',
      createdAt: ago(14),
      sizeBytes: 2 * _mb,
    ),
    StudyMaterial(
      id: 'week-3',
      classId: 'ite13',
      title: 'Hardware',
      week: 3,
      kind: MaterialKind.reviewer,
      source: MaterialSource.powerPoint,
      pagesOrSlides: 24,
      createdBy: 'Prof. Rhea Santos',
      createdAt: ago(10),
      sizeBytes: 9 * _mb,
    ),
    StudyMaterial(
      id: 'week-4',
      classId: 'ite13',
      title: 'Software',
      week: 4,
      kind: MaterialKind.reviewer,
      source: MaterialSource.word,
      pagesOrSlides: 12,
      createdBy: 'Prof. Rhea Santos',
      createdAt: ago(8),
      sizeBytes: 3 * _mb,
    ),
    // 92 In Progress: "40% read · 1 module left".
    StudyMaterial(
      id: 'data-structure-reviewer',
      classId: 'csc126',
      title: 'Data Structure Reviewer',
      kind: MaterialKind.reviewer,
      source: MaterialSource.pdf,
      modulesLeft: 1,
      readDone: 40,
      readTotal: 100,
      createdAt: ago(12),
      sizeBytes: 5 * _mb,
    ),
    // 92 Recently Created.
    StudyMaterial(
      id: 'networking-quiz-reviewer',
      classId: 'it111',
      title: 'Networking Quiz Reviewer',
      kind: MaterialKind.quiz,
      source: MaterialSource.text,
      createdAt: now,
    ),
    StudyMaterial(
      id: 'osi-model-mind-map',
      classId: 'it111',
      title: 'OSI Model Mind Map',
      kind: MaterialKind.mindMap,
      source: MaterialSource.text,
      createdAt: ago(1),
    ),
    // 92 "Downloaded for offline": PDF 12 MB and 24 cards 16 MB.
    StudyMaterial(
      id: 'data-structures-reviewer',
      classId: 'csc126',
      title: 'Data Structures Reviewer',
      kind: MaterialKind.reviewer,
      source: MaterialSource.pdf,
      createdAt: ago(20),
      sizeBytes: 12 * _mb,
      isDownloaded: true,
    ),
    StudyMaterial(
      id: 'networking-flashcards',
      classId: 'it111',
      title: 'Networking Flashcards',
      kind: MaterialKind.flashcards,
      source: MaterialSource.text,
      pagesOrSlides: 24,
      createdAt: ago(18),
      sizeBytes: 16 * _mb,
      isDownloaded: true,
    ),
    // 12: search results.
    StudyMaterial(
      id: 'data-structures-algorithms',
      title: 'Data Structures and Algorithms',
      kind: MaterialKind.reviewer,
      source: MaterialSource.pdf,
      createdBy: 'Ara Matias',
      createdAt: ago(30),
      sizeBytes: 8 * _mb,
    ),
    StudyMaterial(
      id: 'visual-computing-fundamentals',
      classId: 'csc126',
      title: 'Visual Computing Fundamentals',
      kind: MaterialKind.reviewer,
      source: MaterialSource.powerPoint,
      pagesOrSlides: 32,
      createdBy: 'Joshua Bete',
      createdAt: ago(25),
      sizeBytes: 11 * _mb,
    ),
    // Fillers for Browse by tool.
    StudyMaterial(
      id: 'intro-computing-quiz',
      classId: 'ite13',
      title: 'Intro to Computing Quiz',
      kind: MaterialKind.quiz,
      source: MaterialSource.text,
      createdAt: ago(9),
    ),
    StudyMaterial(
      id: 'number-systems-quiz',
      classId: 'ite13',
      title: 'Number Systems Quiz',
      kind: MaterialKind.quiz,
      source: MaterialSource.text,
      createdAt: ago(13),
    ),
    StudyMaterial(
      id: 'hardware-flashcards',
      classId: 'ite13',
      title: 'Hardware Flashcards',
      kind: MaterialKind.flashcards,
      source: MaterialSource.text,
      pagesOrSlides: 30,
      createdAt: ago(11),
    ),
    StudyMaterial(
      id: 'week-1-mind-map',
      classId: 'ite13',
      title: 'Computer Basics Mind Map',
      week: 1,
      kind: MaterialKind.mindMap,
      source: MaterialSource.text,
      createdAt: ago(15),
    ),
    StudyMaterial(
      id: 'sorting-mind-map',
      classId: 'csc126',
      title: 'Sorting Algorithms Mind Map',
      kind: MaterialKind.mindMap,
      source: MaterialSource.text,
      createdAt: ago(16),
    ),
  ];
}
