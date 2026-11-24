import 'quiz.dart';

/// The result of one answered question (124, 125, 126, 129).
final class AnswerRecord {
  const AnswerRecord({
    required this.questionId,
    required this.chosenIndex,
    required this.isCorrect,
    this.tries = 1,
    this.wasRevealed = false,
  });

  final String questionId;
  final int chosenIndex;
  final bool isCorrect;
  final int tries;
  final bool wasRevealed;

  AnswerRecord copyWith({
    String? questionId,
    int? chosenIndex,
    bool? isCorrect,
    int? tries,
    bool? wasRevealed,
  }) => AnswerRecord(
    questionId: questionId ?? this.questionId,
    chosenIndex: chosenIndex ?? this.chosenIndex,
    isCorrect: isCorrect ?? this.isCorrect,
    tries: tries ?? this.tries,
    wasRevealed: wasRevealed ?? this.wasRevealed,
  );
}

/// One play-through of a quiz (124, 125, 126, 129, 132).
final class Attempt {
  const Attempt({
    required this.id,
    required this.quizId,
    this.mode = GameMode.standard,
    this.answers = const [],
    this.heartsLeft = maxHearts,
    required this.startedAt,
    this.finishedAt,
    this.studyPointsEarned = 0,
    this.xpEarned = 0,
    this.correctCount = 0,
    this.total = 0,
  });

  /// Lives at the start of an attempt.
  static const maxHearts = 5;

  final String id;
  final String quizId;
  final GameMode mode;
  final List<AnswerRecord> answers;
  final int heartsLeft;
  final DateTime startedAt;
  final DateTime? finishedAt;
  final int studyPointsEarned;
  final int xpEarned;
  final int correctCount;
  final int total;

  /// Score as a whole percent, 0..100 (0 when total is 0).
  int get percent =>
      total <= 0 ? 0 : (correctCount * 100 / total).round().clamp(0, 100);

  Attempt copyWith({
    String? id,
    String? quizId,
    GameMode? mode,
    List<AnswerRecord>? answers,
    int? heartsLeft,
    DateTime? startedAt,
    DateTime? finishedAt,
    int? studyPointsEarned,
    int? xpEarned,
    int? correctCount,
    int? total,
  }) => Attempt(
    id: id ?? this.id,
    quizId: quizId ?? this.quizId,
    mode: mode ?? this.mode,
    answers: answers ?? this.answers,
    heartsLeft: heartsLeft ?? this.heartsLeft,
    startedAt: startedAt ?? this.startedAt,
    finishedAt: finishedAt ?? this.finishedAt,
    studyPointsEarned: studyPointsEarned ?? this.studyPointsEarned,
    xpEarned: xpEarned ?? this.xpEarned,
    correctCount: correctCount ?? this.correctCount,
    total: total ?? this.total,
  );
}
