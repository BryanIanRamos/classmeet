import '../../models/study_class.dart';

/// The classes the student has already joined (93). ITE13 is
/// "Introduction to Computing" everywhere (INC-5). Counts for ITE13 come from
/// frame 85; the others are // sample.
const sampleClasses = [
  StudyClass(
    id: 'ite13',
    code: 'ITE13',
    title: 'Introduction to Computing',
    teacher: 'Prof. Rhea Santos',
    reviewerCount: 11,
    quizCount: 8,
    setCount: 5,
    plannerCount: 1,
  ),
  StudyClass(
    id: 'csc126',
    code: 'CSC126',
    title: 'Visual Computing Fundamentals',
    teacher: 'Prof. Joshua Bete',
    reviewerCount: 6,
    quizCount: 4,
    setCount: 3,
    plannerCount: 1,
  ),
  StudyClass(
    id: 'it111',
    code: 'IT111',
    title: 'Computer Human Interaction',
    teacher: 'Prof. Ara Matias',
    newUpdates: 2,
    reviewerCount: 5,
    quizCount: 3,
    setCount: 2,
  ),
];

/// The 4th class on frame 93, joined with [joinableClassCode]. // sample
const joinableClass = StudyClass(
  id: 'ite16',
  code: 'ITE16',
  title: 'Database Management Systems',
  teacher: 'Prof. Dave Ramos',
  newUpdates: 1,
  reviewerCount: 4,
  quizCount: 2,
  setCount: 2,
  plannerCount: 1,
);

const joinableClassCode = 'ITE16-2026';
