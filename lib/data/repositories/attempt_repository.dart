import '../models/attempt.dart';
import '../models/quiz.dart';

/// Playing a quiz: start, answer, finish (124–126, 129, 132).
abstract interface class AttemptRepository {
  Future<Attempt> startAttempt({
    required String quizId,
    required GameMode mode,
    required GameSettings settings,
  });

  Future<Attempt> fetchAttempt(String attemptId);

  /// Records an answer (also a retry or a reveal) and returns the attempt.
  Future<Attempt> recordAnswer(String attemptId, AnswerRecord answer);

  /// Ends the attempt, scores it and books its points and XP.
  Future<Attempt> finishAttempt(String attemptId);

  /// The attempt before [attemptId] on the same quiz, for the comparison
  /// bars on the results screen (132).
  Future<Attempt?> fetchPreviousAttempt(String attemptId);
}
