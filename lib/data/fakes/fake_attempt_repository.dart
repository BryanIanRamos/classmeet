import '../models/attempt.dart';
import '../models/quiz.dart';
import '../repositories/attempt_repository.dart';
import '../repositories/quiz_repository.dart';
import '../repositories/repository_exception.dart';
import '../repositories/wallet_repository.dart';
import 'fake_config.dart';
import 'fake_mistake_repository.dart';
import 'samples/quiz_samples.dart';

/// In-memory [AttemptRepository]. Wrong and revealed answers go to the
/// [FakeMistakeRepository]; finishing books points and XP in the wallet.
///
/// Seeds `attempt-0` (12/20, 60%) and `attempt-1` (16/20, 80%, +8 study
/// points, +40 XP) on the sample quiz, as in 132.
class FakeAttemptRepository implements AttemptRepository {
  FakeAttemptRepository(
    this._config, {
    required this._quizzes,
    required this._mistakes,
    required this._wallet,
    DateTime Function()? clock,
  }) : _clock = clock ?? DateTime.now;

  final FakeConfig _config;
  final QuizRepository _quizzes;
  final FakeMistakeRepository _mistakes;
  final WalletRepository _wallet;
  final DateTime Function() _clock;

  final Map<String, Attempt> _attempts = {
    'attempt-0': Attempt(
      id: 'attempt-0',
      quizId: sampleQuizId,
      startedAt: DateTime(2026, 11, 10, 9),
      finishedAt: DateTime(2026, 11, 10, 9, 8),
      correctCount: 12,
      total: 20,
    ),
    'attempt-1': Attempt(
      id: 'attempt-1',
      quizId: sampleQuizId,
      startedAt: DateTime(2026, 11, 17, 9),
      finishedAt: DateTime(2026, 11, 17, 9, 7),
      studyPointsEarned: 8,
      xpEarned: 40,
      correctCount: 16,
      total: 20,
    ),
  };
  var _nextId = 2;

  Attempt _find(String id) =>
      _attempts[id] ?? (throw RepositoryException('Attempt "$id" not found'));

  @override
  Future<Attempt> startAttempt({
    required String quizId,
    required GameMode mode,
    required GameSettings settings,
  }) async {
    final quiz = await _quizzes.fetchQuiz(quizId);
    return _config.answer('startAttempt', () {
      final attempt = Attempt(
        id: 'attempt-${_nextId++}',
        quizId: quizId,
        mode: mode,
        startedAt: _clock(),
        total: quiz.questionCount,
      );
      return _attempts[attempt.id] = attempt;
    });
  }

  @override
  Future<Attempt> fetchAttempt(String attemptId) =>
      _config.answer('fetchAttempt', () => _find(attemptId));

  /// A wrong answer costs a heart; a reveal after a wrong answer does not
  /// cost another. A wrong or revealed answer is recorded as a miss once
  /// per question and attempt.
  @override
  Future<Attempt> recordAnswer(String attemptId, AnswerRecord answer) async {
    final attempt = _find(attemptId);
    final quiz = await _quizzes.fetchQuiz(attempt.quizId);
    final questions = await _quizzes.fetchQuestions(attempt.quizId);
    final question = questions.firstWhere(
      (q) => q.id == answer.questionId,
      orElse: () =>
          throw RepositoryException('Question "${answer.questionId}" unknown'),
    );
    return _config.answer('recordAnswer', () {
      final current = _find(attemptId);
      final i = current.answers.indexWhere(
        (a) => a.questionId == answer.questionId,
      );
      final before = i < 0 ? null : current.answers[i];
      final missed = !answer.isCorrect || answer.wasRevealed;
      final alreadyMissed =
          before != null && (!before.isCorrect || before.wasRevealed);
      if (missed && !alreadyMissed) {
        _mistakes.recordMiss(
          questionId: question.id,
          prompt: question.prompt,
          classCode: quiz.classCode,
        );
      }
      final answers = [...current.answers];
      if (i < 0) {
        answers.add(answer);
      } else {
        answers[i] = answer;
      }
      final costsHeart = !answer.isCorrect && !answer.wasRevealed;
      return _attempts[attemptId] = current.copyWith(
        answers: answers,
        heartsLeft: costsHeart
            ? (current.heartsLeft - 1).clamp(0, Attempt.maxHearts)
            : current.heartsLeft,
      );
    });
  }

  /// Awards by score: study points = percent / 10 (rounded down) and XP =
  /// percent / 2, so 16/20 (80%) earns +8 study points and +40 XP (132) and
  /// a perfect run +10 and +50. Finishing twice books the points once.
  @override
  Future<Attempt> finishAttempt(String attemptId) async {
    var award = false;
    final finished = await _config.answer('finishAttempt', () {
      final current = _find(attemptId);
      if (current.finishedAt != null) return current;
      award = true;
      final correct = current.answers.where((a) => a.isCorrect).length;
      final scored = current.copyWith(correctCount: correct);
      return _attempts[attemptId] = scored.copyWith(
        finishedAt: _clock(),
        studyPointsEarned: scored.percent ~/ 10,
        xpEarned: scored.percent ~/ 2,
      );
    });
    if (award) {
      await _wallet.earn(
        studyPoints: finished.studyPointsEarned,
        xp: finished.xpEarned,
      );
    }
    return finished;
  }

  /// The latest finished attempt on the same quiz that started earlier.
  @override
  Future<Attempt?> fetchPreviousAttempt(String attemptId) =>
      _config.answer<Attempt?>('fetchPreviousAttempt', () {
        final current = _find(attemptId);
        final earlier =
            _attempts.values
                .where(
                  (a) =>
                      a.quizId == current.quizId &&
                      a.finishedAt != null &&
                      a.startedAt.isBefore(current.startedAt),
                )
                .toList()
              ..sort((a, b) => b.startedAt.compareTo(a.startedAt));
        return earlier.isEmpty ? null : earlier.first;
      }, empty: () => null);
}
