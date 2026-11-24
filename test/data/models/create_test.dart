import 'package:classmeet/data/models/create.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('CreateTool copy, cost and design flag', () {
    expect(CreateTool.values.map((e) => e.label), [
      'Quizzes',
      'Flashcards',
      'Visual summaries',
      'Step-by-step explanations',
      'Reading summaries',
      'Manual quiz',
    ]);
    expect(CreateTool.values.map((e) => e.caption), [
      'Test your knowledge as you go',
      'Review key terms and concepts',
      'Learn with diagrams and mind maps',
      'Break down difficult topics',
      'Review the key points quickly',
      "Create and test what you've learned",
    ]);
    expect(CreateTool.values.map((e) => e.talonCost), [2, 1, 1, 1, null, null]);
    expect(CreateTool.values.where((e) => e.isDesigned), [CreateTool.quizzes]);
  });

  test('Difficulty and QuestionType labels', () {
    expect(Difficulty.values.map((e) => e.label), ['Easy', 'Mixed', 'Hard']);
    expect(QuestionType.values.map((e) => e.label), [
      'Multiple choice',
      'True or false',
      'Fill-in-the-Blanks',
      'Identification',
    ]);
  });

  test('Draft', () {
    final d = Draft(
      id: 'd',
      title: 'Intro',
      tool: CreateTool.manualQuiz,
      updatedAt: DateTime(2026),
    );
    final c = d.copyWith();
    expect(
      [c.id, c.title, c.tool, c.updatedAt],
      ['d', 'Intro', CreateTool.manualQuiz, DateTime(2026)],
    );
    expect(d.copyWith(title: 'X').tool, CreateTool.manualQuiz);
  });

  test('QuizSetup', () {
    const s = QuizSetup(title: 't', sourceMaterialId: 'm');
    expect(s.questionCount, 10);
    expect(s.difficulty, Difficulty.mixed);
    expect(QuizSetup.questionCountChoices, [5, 10, 15, 20]);
    final c = s.copyWith();
    expect(c.sourceMaterialId, 'm');
    expect(c.title, 't');
    expect(c.questionCount, 10);
    expect(c.difficulty, Difficulty.mixed);
    expect(c.questionTypes, s.questionTypes);
    expect(c.showExplanations, isTrue);
    expect(c.shuffle, isTrue);
    final d = s.copyWith(questionCount: 20);
    expect(d.questionCount, 20);
    expect(d.title, 't');
  });

  test('GenerationJob', () {
    const j = GenerationJob(id: 'j', done: 3, total: 10);
    expect(j.stage, GenerationStage.reading);
    expect(j.fraction, closeTo(0.3, 1e-9));
    expect(j.copyWith(total: 0).fraction, 0);
    expect(j.copyWith(done: 20).fraction, 1);
    final c = j.copyWith();
    expect([c.id, c.done, c.total, c.stage], ['j', 3, 10, j.stage]);
    expect(c.setup, isNull);
    expect(c.quizId, isNull);
    final d = j.copyWith(stage: GenerationStage.saving, quizId: 'q');
    expect(d.stage, GenerationStage.saving);
    expect(d.quizId, 'q');
    expect(d.done, 3);
  });

  test('GenerationStage copy', () {
    expect(GenerationStage.values.take(4).map((e) => e.title), [
      'Reading your material',
      'Creating questions',
      'Checking answers',
      'Saving your quiz',
    ]);
    expect(GenerationStage.values.skip(1).take(3).map((e) => e.caption), [
      'Building a balanced practice quiz',
      'Preparing answers and explanations',
      'Adding it to your study materials',
    ]);
    expect(GenerationStage.values.skip(4), [
      GenerationStage.done,
      GenerationStage.failed,
    ]);
  });
}
