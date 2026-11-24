import 'package:classmeet/data/fakes/fake_config.dart';
import 'package:classmeet/data/fakes/fake_quiz_repository.dart';
import 'package:classmeet/data/models/create.dart';
import 'package:classmeet/data/models/quiz.dart';
import 'package:classmeet/data/repositories/repository_exception.dart';
import 'package:flutter_test/flutter_test.dart';

const _empty = FakeConfig(scenario: FakeScenario.empty, latency: Duration.zero);
const _error = FakeConfig(scenario: FakeScenario.error, latency: Duration.zero);

void main() {
  late FakeQuizRepository repo;
  setUp(() => repo = FakeQuizRepository(FakeConfig.instant));

  test('sample quiz matches 122 and 123', () async {
    final quizzes = await repo.fetchQuizzes();
    expect(quizzes, hasLength(1));
    final q = quizzes.single;
    expect(q.id, 'intro-computing');
    expect(q.title, 'Intro to Computing Quiz');
    expect(q.classCode, 'ITE13');
    expect(q.questionCount, 20);
    expect(q.difficulty, Difficulty.mixed);
    expect(q.types, {QuestionType.multipleChoice, QuestionType.identification});
    expect(q.bestPercent, 85);
    expect((await repo.fetchQuiz('intro-computing')).title, q.title);
    expect((await repo.fetchContinueQuiz())?.id, 'intro-computing');
  });

  test(
    'the 20 questions are well formed and the first is the design one',
    () async {
      final qs = await repo.fetchQuestions('intro-computing');
      expect(qs, hasLength(20));
      expect(qs.map((q) => q.id).toSet(), hasLength(20));
      final first = qs.first;
      expect(
        first.prompt,
        'Which part of the computer carries out instructions from programs?',
      );
      expect(first.options, [
        'Monitor',
        'Central Processing Unit',
        'Hard drive',
        'Keyboard',
      ]);
      expect(first.options[first.correctIndex], 'Central Processing Unit');
      expect(
        first.sourceLabel,
        'Based on your Week 1: Computer Basics Reviewer',
      );
      for (final q in qs) {
        expect(q.correctIndex, inInclusiveRange(0, q.options.length - 1));
        expect(q.explanation, isNotEmpty);
        expect(
          q.type,
          anyOf(QuestionType.multipleChoice, QuestionType.trueOrFalse),
        );
      }
    },
  );

  test('addQuiz puts the quiz first and serves its questions', () async {
    const quiz = Quiz(
      id: 'new',
      title: 'New',
      classCode: 'ITE13',
      questionCount: 1,
      difficulty: Difficulty.easy,
    );
    const question = Question(id: 'new-q1', prompt: 'P', correctIndex: 0);
    repo.addQuiz(quiz, const [question]);
    expect((await repo.fetchQuizzes()).first.id, 'new');
    expect((await repo.fetchQuestions('new')).single.id, 'new-q1');
    expect((await repo.fetchContinueQuiz())?.id, 'intro-computing');
  });

  test('unknown quiz id throws', () async {
    await expectLater(
      repo.fetchQuiz('nope'),
      throwsA(isA<RepositoryException>()),
    );
    await expectLater(
      repo.fetchQuestions('nope'),
      throwsA(isA<RepositoryException>()),
    );
  });

  test('empty scenario returns empty lists and no continue quiz', () async {
    final r = FakeQuizRepository(_empty);
    expect(await r.fetchQuizzes(), isEmpty);
    expect(await r.fetchQuestions('intro-computing'), isEmpty);
    expect(await r.fetchContinueQuiz(), isNull);
  });

  test('error scenario throws RepositoryException', () async {
    final r = FakeQuizRepository(_error);
    for (final call in <Future<Object?> Function()>[
      r.fetchQuizzes,
      () => r.fetchQuiz('intro-computing'),
      () => r.fetchQuestions('intro-computing'),
      r.fetchContinueQuiz,
    ]) {
      await expectLater(call(), throwsA(isA<RepositoryException>()));
    }
  });
}
