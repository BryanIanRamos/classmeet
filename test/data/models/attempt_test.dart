import 'package:classmeet/data/models/attempt.dart';
import 'package:classmeet/data/models/quiz.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('AnswerRecord', () {
    const a = AnswerRecord(questionId: 'q', chosenIndex: 2, isCorrect: false);
    expect(a.tries, 1);
    expect(a.wasRevealed, isFalse);
    final c = a.copyWith();
    expect(
      [c.questionId, c.chosenIndex, c.isCorrect, c.tries],
      ['q', 2, false, 1],
    );
    expect(c.wasRevealed, isFalse);
    final d = a.copyWith(wasRevealed: true);
    expect(d.wasRevealed, isTrue);
    expect(d.chosenIndex, 2);
  });

  test('Attempt', () {
    final started = DateTime(2026);
    final a = Attempt(
      id: 'a',
      quizId: 'q',
      mode: GameMode.reviewerQuest,
      answers: const [
        AnswerRecord(questionId: 'q1', chosenIndex: 0, isCorrect: true),
      ],
      heartsLeft: 3,
      startedAt: started,
      finishedAt: DateTime(2026, 1, 2),
      studyPointsEarned: 8,
      xpEarned: 40,
      correctCount: 16,
      total: 20,
    );
    expect(Attempt.maxHearts, 5);
    expect(Attempt(id: 'a', quizId: 'q', startedAt: started).heartsLeft, 5);
    final c = a.copyWith();
    expect(
      [c.id, c.quizId, c.mode, c.heartsLeft],
      ['a', 'q', GameMode.reviewerQuest, 3],
    );
    expect(c.answers, hasLength(1));
    expect(c.startedAt, started);
    expect(c.finishedAt, DateTime(2026, 1, 2));
    expect(
      [c.studyPointsEarned, c.xpEarned, c.correctCount, c.total],
      [8, 40, 16, 20],
    );
    final d = a.copyWith(heartsLeft: 2);
    expect(d.heartsLeft, 2);
    expect(d.correctCount, 16);
  });

  test('percent', () {
    final s = DateTime(2026);
    Attempt of(int c, int t) =>
        Attempt(id: 'a', quizId: 'q', startedAt: s, correctCount: c, total: t);
    expect(of(0, 0).percent, 0);
    expect(of(16, 20).percent, 80);
    expect(of(1, 3).percent, 33);
    expect(of(25, 20).percent, 100);
  });
}
