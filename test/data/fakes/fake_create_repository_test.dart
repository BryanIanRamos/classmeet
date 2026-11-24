import 'package:classmeet/data/fakes/fake_config.dart';
import 'package:classmeet/data/fakes/fake_create_repository.dart';
import 'package:classmeet/data/fakes/fake_quiz_repository.dart';
import 'package:classmeet/data/models/create.dart';
import 'package:classmeet/data/models/streak.dart';
import 'package:classmeet/data/models/wallet.dart';
import 'package:classmeet/data/repositories/repository_exception.dart';
import 'package:classmeet/data/repositories/wallet_repository.dart';
import 'package:flutter_test/flutter_test.dart';

const _empty = FakeConfig(scenario: FakeScenario.empty, latency: Duration.zero);
const _error = FakeConfig(scenario: FakeScenario.error, latency: Duration.zero);

/// Wallet double that records spending and can refuse it.
class _WalletDouble implements WalletRepository {
  _WalletDouble({this.fails = false});

  final bool fails;
  final spent = <(int, String)>[];

  @override
  Future<Wallet> spendTalons(int amount, {required String reason}) async {
    if (fails) throw const RepositoryException('Not enough talons');
    spent.add((amount, reason));
    return const Wallet(talons: 22);
  }

  @override
  Future<Wallet> earn({int talons = 0, int studyPoints = 0, int xp = 0}) =>
      throw UnimplementedError();

  @override
  Future<Wallet> fetchWallet() => throw UnimplementedError();

  @override
  Future<RewardProgress> fetchRewardProgress() => throw UnimplementedError();

  @override
  Future<Streak> fetchStreak() => throw UnimplementedError();
}

void main() {
  late FakeQuizRepository quizzes;
  late _WalletDouble wallet;
  late FakeCreateRepository repo;

  setUp(() {
    quizzes = FakeQuizRepository(FakeConfig.instant);
    wallet = _WalletDouble();
    repo = FakeCreateRepository(
      FakeConfig.instant,
      quizzes: quizzes,
      wallet: wallet,
    );
  });

  test('the draft matches 121', () async {
    final drafts = await repo.fetchDrafts();
    expect(drafts, hasLength(1));
    expect(drafts.single.title, 'Intro to Computing Quiz');
    expect(drafts.single.tool, CreateTool.manualQuiz);
  });

  test('generateQuiz emits the stages in order and ends in done', () async {
    final jobs = await repo
        .generateQuiz(const QuizSetup(title: 'Week 1: Computer Basics Quiz'))
        .toList();
    expect(jobs.map((j) => j.stage), [
      GenerationStage.reading,
      GenerationStage.creating,
      GenerationStage.checking,
      GenerationStage.saving,
      GenerationStage.done,
    ]);
    expect(jobs.map((j) => j.fraction), [0, 0.25, 0.5, 0.75, 1]);
    expect(jobs.map((j) => j.id).toSet(), hasLength(1));
    expect(jobs.take(4).every((j) => j.quizId == null), isTrue);

    expect(wallet.spent.single.$1, 2);

    final id = jobs.last.quizId!;
    final quiz = await quizzes.fetchQuiz(id);
    expect(quiz.title, 'Week 1: Computer Basics Quiz');
    expect(quiz.questionCount, 10);
    expect(quiz.isAiGenerated, isTrue);
    expect(quiz.difficulty, Difficulty.mixed);
    expect((await quizzes.fetchQuizzes()).first.id, id);
    final qs = await quizzes.fetchQuestions(id);
    expect(qs, hasLength(10));
    expect(qs.first.prompt, startsWith('Which part of the computer'));
  });

  test('question count beyond the pool repeats it with unique ids', () async {
    final jobs = await repo
        .generateQuiz(const QuizSetup(questionCount: 20, title: ' '))
        .toList();
    final id = jobs.last.quizId!;
    final qs = await quizzes.fetchQuestions(id);
    expect(qs, hasLength(20));
    expect(qs.map((q) => q.id).toSet(), hasLength(20));
    expect(qs[12].prompt, qs[0].prompt);
    expect((await quizzes.fetchQuiz(id)).title, 'Week 1: Computer Basics Quiz');
  });

  test('two generations get different quiz ids', () async {
    final a = (await repo.generateQuiz(const QuizSetup()).toList()).last;
    final b = (await repo.generateQuiz(const QuizSetup()).toList()).last;
    expect(a.quizId, isNot(b.quizId));
    expect(wallet.spent, hasLength(2));
  });

  test('a wallet that refuses makes the stream emit the error', () async {
    final failing = FakeCreateRepository(
      FakeConfig.instant,
      quizzes: quizzes,
      wallet: _WalletDouble(fails: true),
    );
    await expectLater(
      failing.generateQuiz(const QuizSetup()),
      emitsInOrder([emitsError(isA<RepositoryException>()), emitsDone]),
    );
    expect(await quizzes.fetchQuizzes(), hasLength(1));
  });

  test('respects the latency between stages', () async {
    final slow = FakeCreateRepository(
      const FakeConfig(latency: Duration(milliseconds: 20)),
      quizzes: quizzes,
      wallet: wallet,
    );
    final watch = Stopwatch()..start();
    await slow.generateQuiz(const QuizSetup()).toList();
    // One initial wait and four between stages.
    expect(watch.elapsedMilliseconds, greaterThanOrEqualTo(90));
  });

  test('empty scenario has no drafts but still generates', () async {
    final r = FakeCreateRepository(_empty, quizzes: quizzes, wallet: wallet);
    expect(await r.fetchDrafts(), isEmpty);
    expect(
      (await r.generateQuiz(const QuizSetup()).toList()).last.stage,
      GenerationStage.done,
    );
  });

  test('error scenario throws and the stream emits the error', () async {
    final r = FakeCreateRepository(_error, quizzes: quizzes, wallet: wallet);
    await expectLater(r.fetchDrafts(), throwsA(isA<RepositoryException>()));
    await expectLater(
      r.generateQuiz(const QuizSetup()),
      emitsInOrder([emitsError(isA<RepositoryException>()), emitsDone]),
    );
    expect(wallet.spent, isEmpty);
    expect(await quizzes.fetchQuizzes(), hasLength(1));
  });
}
