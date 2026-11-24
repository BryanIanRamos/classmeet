import 'package:classmeet/data/models/create.dart';
import 'package:classmeet/data/models/quiz.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Quiz', () {
    const q = Quiz(
      id: 'q',
      title: 'T',
      classCode: 'ITE13',
      questionCount: 20,
      difficulty: Difficulty.mixed,
      types: {QuestionType.multipleChoice},
      bestPercent: 85,
      isAiGenerated: true,
    );
    final c = q.copyWith();
    expect(
      [c.id, c.title, c.classCode, c.questionCount],
      ['q', 'T', 'ITE13', 20],
    );
    expect(c.difficulty, Difficulty.mixed);
    expect(c.types, q.types);
    expect(c.bestPercent, 85);
    expect(c.isAiGenerated, isTrue);
    final d = q.copyWith(questionCount: 5);
    expect(d.questionCount, 5);
    expect(d.title, 'T');
  });

  test('Question', () {
    const q = Question(
      id: 'x',
      prompt: 'P',
      category: 'Science & Society',
      options: ['a', 'b'],
      correctIndex: 1,
      explanation: 'e',
      sourceLabel: 's',
    );
    expect(q.type, QuestionType.multipleChoice);
    final c = q.copyWith();
    expect(
      [c.id, c.prompt, c.category, c.explanation, c.sourceLabel],
      ['x', 'P', 'Science & Society', 'e', 's'],
    );
    expect(c.options, ['a', 'b']);
    expect(c.correctIndex, 1);
    expect(c.type, QuestionType.multipleChoice);
    final d = q.copyWith(correctIndex: 0);
    expect(d.correctIndex, 0);
    expect(d.prompt, 'P');
  });

  test('GameMode copy and design flag', () {
    expect(GameMode.values.map((e) => e.label), [
      'Standard',
      'Streak Run',
      'Reviewer Quest',
      'Quiz Battle',
    ]);
    expect(GameMode.values.map((e) => e.caption), [
      'Learn at your pace',
      'Keep the combo alive',
      'Adventure mode',
      'Challenge friends',
    ]);
    expect(GameMode.values.map((e) => e.longCaption), [
      'Practice with explanations after every answer',
      'Earn bonus points for consecutive correct answers',
      'Clear challenges and reach the chapter boss',
      'Practice and challenge with friends',
    ]);
    expect(GameMode.values.map((e) => e.isDesigned), [true, true, true, false]);
  });

  test('GameSettings', () {
    const s = GameSettings();
    expect(s.timed, isFalse);
    final c = s.copyWith();
    expect([c.askBeforeReveal, c.showComments, c.timed], [true, true, false]);
    final d = s.copyWith(timed: true);
    expect(d.timed, isTrue);
    expect(d.askBeforeReveal, isTrue);
  });
}
