import 'package:classmeet/data/fakes/fake_attempt_repository.dart';
import 'package:classmeet/data/fakes/fake_config.dart';
import 'package:classmeet/data/fakes/fake_mistake_repository.dart';
import 'package:classmeet/data/fakes/fake_quiz_repository.dart';
import 'package:classmeet/data/models/attempt.dart';
import 'package:classmeet/data/models/quiz.dart';
import 'package:classmeet/data/models/streak.dart';
import 'package:classmeet/data/models/wallet.dart';
import 'package:classmeet/data/repositories/repository_exception.dart';
import 'package:classmeet/data/repositories/wallet_repository.dart';
import 'package:flutter_test/flutter_test.dart';

const _empty = FakeConfig(scenario: FakeScenario.empty, latency: Duration.zero);
const _error = FakeConfig(scenario: FakeScenario.error, latency: Duration.zero);
final _now = DateTime(2026, 11, 24, 12);
const _quizId = 'intro-computing';

/// Records what the attempt fake books.
class _WalletDouble implements WalletRepository {
  Wallet wallet = const Wallet();
  int earnCalls = 0;

  @override
  Future<Wallet> earn({int talons = 0, int studyPoints = 0, int xp = 0}) async {
    earnCalls++;
    return wallet = wallet.copyWith(
      talons: wallet.talons + talons,
      studyPoints: wallet.studyPoints + studyPoints,
      xp: wallet.xp + xp,
    );
  }

  @override
  Future<Wallet> fetchWallet() async => wallet;

  @override
  Future<RewardProgress> fetchRewardProgress() => throw UnimplementedError();

  @override
  Future<Streak> fetchStreak() => throw UnimplementedError();

  @override
  Future<Wallet> spendTalons(int amount, {required String reason}) =>
      throw UnimplementedError();
}

void main() {
  late FakeQuizRepository quizzes;
  late FakeMistakeRepository mistakes;
  late _WalletDouble wallet;
  late FakeAttemptRepository repo;

  FakeAttemptRepository build(FakeConfig config) => FakeAttemptRepository(
    config,
    quizzes: quizzes,
    mistakes: mistakes,
    wallet: wallet,
    clock: () => _now,
  );

  setUp(() {
    quizzes = FakeQuizRepository(FakeConfig.instant);
    mistakes = FakeMistakeRepository(FakeConfig.instant);
    wallet = _WalletDouble();
    repo = build(FakeConfig.instant);
  });

  Future<Attempt> start() => repo.startAttempt(
    quizId: _quizId,
    mode: GameMode.standard,
    settings: const GameSettings(),
  );

  test('seeded attempts match 132', () async {
    final a0 = await repo.fetchAttempt('attempt-0');
    expect((a0.correctCount, a0.total, a0.percent), (12, 20, 60));
    final a1 = await repo.fetchAttempt('attempt-1');
    expect((a1.correctCount, a1.total, a1.percent), (16, 20, 80));
    expect((a1.studyPointsEarned, a1.xpEarned), (8, 40));
    expect(a1.quizId, _quizId);
    expect(a1.finishedAt, isNotNull);
    expect((await repo.fetchPreviousAttempt('attempt-1'))?.id, 'attempt-0');
    expect(await repo.fetchPreviousAttempt('attempt-0'), isNull);
  });

  test(
    'startAttempt creates attempt-2 with 5 hearts and 20 questions',
    () async {
      final a = await start();
      expect(a.id, 'attempt-2');
      expect(a.total, 20);
      expect(a.heartsLeft, 5);
      expect(a.startedAt, _now);
      expect(a.finishedAt, isNull);
      expect((await start()).id, 'attempt-3');
      expect((await repo.fetchPreviousAttempt('attempt-2'))?.id, 'attempt-1');
    },
  );

  test(
    'full flow: wrong, correct answers, finish books points and XP',
    () async {
      final a = await start();
      final qs = await quizzes.fetchQuestions(_quizId);

      // Question 3 wrong: a heart is lost and the miss is recorded.
      var r = await repo.recordAnswer(
        a.id,
        AnswerRecord(questionId: qs[2].id, chosenIndex: 1, isCorrect: false),
      );
      expect(r.heartsLeft, 4);
      var ram = (await mistakes.fetchMistakes()).firstWhere(
        (e) => e.questionId == qs[2].id,
      );
      expect(ram.missCount, 4);

      // Retry correctly: the record is replaced, no refund, no second miss.
      r = await repo.recordAnswer(
        a.id,
        AnswerRecord(
          questionId: qs[2].id,
          chosenIndex: qs[2].correctIndex,
          isCorrect: true,
          tries: 2,
        ),
      );
      expect(r.answers, hasLength(1));
      expect(r.answers.single.isCorrect, isTrue);
      expect(r.heartsLeft, 4);
      ram = (await mistakes.fetchMistakes()).firstWhere(
        (e) => e.questionId == qs[2].id,
      );
      expect(ram.missCount, 4);

      // Questions 1-2 and 4-16 correct, 17-19 wrong: 16 correct in all.
      for (var i = 0; i < 19; i++) {
        if (i == 2) continue;
        r = await repo.recordAnswer(
          a.id,
          AnswerRecord(
            questionId: qs[i].id,
            chosenIndex: qs[i].correctIndex,
            isCorrect: i < 16,
          ),
        );
      }
      final done = await repo.finishAttempt(a.id);
      expect(done.finishedAt, _now);
      expect(done.correctCount, 16);
      expect(done.percent, 80);
      expect((done.studyPointsEarned, done.xpEarned), (8, 40));
      expect((wallet.wallet.studyPoints, wallet.wallet.xp), (8, 40));

      // Finishing again changes nothing.
      await repo.finishAttempt(a.id);
      expect(wallet.earnCalls, 1);
      expect((await repo.fetchAttempt(a.id)).correctCount, 16);
    },
  );

  test('a reveal after a wrong answer keeps one miss and one heart', () async {
    final a = await start();
    final q = (await quizzes.fetchQuestions(_quizId)).first;
    await repo.recordAnswer(
      a.id,
      AnswerRecord(questionId: q.id, chosenIndex: 0, isCorrect: false),
    );
    final r = await repo.recordAnswer(
      a.id,
      AnswerRecord(
        questionId: q.id,
        chosenIndex: 0,
        isCorrect: false,
        tries: 2,
        wasRevealed: true,
      ),
    );
    expect(r.heartsLeft, 4);
    final added = (await mistakes.fetchMistakes()).firstWhere(
      (e) => e.questionId == q.id,
    );
    expect(
      (added.missCount, added.prompt, added.classCode),
      (1, q.prompt, 'ITE13'),
    );
  });

  test('a correct answer costs nothing and records no miss', () async {
    final a = await start();
    final q = (await quizzes.fetchQuestions(_quizId)).first;
    final r = await repo.recordAnswer(
      a.id,
      AnswerRecord(questionId: q.id, chosenIndex: 1, isCorrect: true),
    );
    expect(r.heartsLeft, 5);
    expect(
      (await mistakes.fetchMistakes()).where((e) => e.questionId == q.id),
      isEmpty,
    );
  });

  test('a perfect run earns +10 study points and +50 XP', () async {
    final a = await start();
    final qs = await quizzes.fetchQuestions(_quizId);
    for (final q in qs) {
      await repo.recordAnswer(
        a.id,
        AnswerRecord(
          questionId: q.id,
          chosenIndex: q.correctIndex,
          isCorrect: true,
        ),
      );
    }
    final done = await repo.finishAttempt(a.id);
    expect((done.studyPointsEarned, done.xpEarned), (10, 50));
  });

  test('unknown ids throw', () async {
    await expectLater(
      repo.fetchAttempt('nope'),
      throwsA(isA<RepositoryException>()),
    );
    await expectLater(
      repo.startAttempt(
        quizId: 'nope',
        mode: GameMode.standard,
        settings: const GameSettings(),
      ),
      throwsA(isA<RepositoryException>()),
    );
    final a = await start();
    await expectLater(
      repo.recordAnswer(
        a.id,
        const AnswerRecord(questionId: 'nope', chosenIndex: 0, isCorrect: true),
      ),
      throwsA(isA<RepositoryException>()),
    );
  });

  test('empty scenario still plays (attempts are not a list)', () async {
    final r = build(_empty);
    expect((await r.fetchAttempt('attempt-1')).percent, 80);
    expect(await r.fetchPreviousAttempt('attempt-1'), isNull);
  });

  test('error scenario throws RepositoryException', () async {
    final r = build(_error);
    await expectLater(
      r.fetchAttempt('attempt-1'),
      throwsA(isA<RepositoryException>()),
    );
    await expectLater(
      r.finishAttempt('attempt-1'),
      throwsA(isA<RepositoryException>()),
    );
    await expectLater(
      r.fetchPreviousAttempt('attempt-1'),
      throwsA(isA<RepositoryException>()),
    );
    final failing = FakeAttemptRepository(
      _error,
      quizzes: FakeQuizRepository(_error),
      mistakes: mistakes,
      wallet: wallet,
    );
    await expectLater(
      failing.startAttempt(
        quizId: _quizId,
        mode: GameMode.standard,
        settings: const GameSettings(),
      ),
      throwsA(isA<RepositoryException>()),
    );
    await expectLater(
      failing.recordAnswer(
        'attempt-1',
        const AnswerRecord(questionId: 'x', chosenIndex: 0, isCorrect: true),
      ),
      throwsA(isA<RepositoryException>()),
    );
    expect(wallet.earnCalls, 0);
  });
}
