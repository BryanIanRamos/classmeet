import 'package:classmeet/data/models/study_class.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const c = StudyClass(
    id: 'c1',
    code: 'ITE13',
    title: 'Intermediate Programming',
    teacher: 'Prof. Rhea Santos',
    newUpdates: 1,
    reviewerCount: 11,
    quizCount: 8,
    setCount: 5,
    plannerCount: 1,
  );

  test('counts default to zero', () {
    const e = StudyClass(id: 'e', code: 'c', title: 't', teacher: 'x');
    expect(e.newUpdates, 0);
    expect(e.hasNewUpdates, isFalse);
    expect(e.reviewerCount + e.quizCount + e.setCount + e.plannerCount, 0);
  });

  test('copyWith() keeps every field', () {
    final k = c.copyWith();
    expect(k.id, 'c1');
    expect(k.code, 'ITE13');
    expect(k.title, 'Intermediate Programming');
    expect(k.teacher, 'Prof. Rhea Santos');
    expect(k.newUpdates, 1);
    expect(k.reviewerCount, 11);
    expect(k.quizCount, 8);
    expect(k.setCount, 5);
    expect(k.plannerCount, 1);
  });

  test('copyWith changes only the given field', () {
    final k = c.copyWith(newUpdates: 0);
    expect(k.newUpdates, 0);
    expect(k.hasNewUpdates, isFalse);
    expect(k.reviewerCount, 11);
    expect(c.hasNewUpdates, isTrue);
  });
}
