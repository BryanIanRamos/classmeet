/// A missed question in the Mistake Bank (127).
final class MistakeEntry {
  const MistakeEntry({
    required this.questionId,
    required this.prompt,
    required this.classCode,
    this.missCount = 1,
    this.correctStreak = 0,
  });

  /// Correct answers in a row needed to master a question.
  static const masteryStreak = 2;

  final String questionId;
  final String prompt;
  final String classCode;
  final int missCount;
  final int correctStreak;

  bool get isMastered => correctStreak >= masteryStreak;

  MistakeEntry copyWith({
    String? questionId,
    String? prompt,
    String? classCode,
    int? missCount,
    int? correctStreak,
  }) => MistakeEntry(
    questionId: questionId ?? this.questionId,
    prompt: prompt ?? this.prompt,
    classCode: classCode ?? this.classCode,
    missCount: missCount ?? this.missCount,
    correctStreak: correctStreak ?? this.correctStreak,
  );
}

/// The "12 of 38 mastered" summary card (127).
final class MistakeBankSummary {
  const MistakeBankSummary({required this.total, required this.mastered});

  final int total;
  final int mastered;

  /// Mastered share, 0..1 (0 when total is 0).
  double get fraction => total <= 0 ? 0 : (mastered / total).clamp(0.0, 1.0);

  MistakeBankSummary copyWith({int? total, int? mastered}) =>
      MistakeBankSummary(
        total: total ?? this.total,
        mastered: mastered ?? this.mastered,
      );
}
