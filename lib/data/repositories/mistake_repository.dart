import '../models/mistake.dart';

/// The mistake bank (127): missed questions until they are mastered.
abstract interface class MistakeRepository {
  /// [classCode] null means All.
  Future<List<MistakeEntry>> fetchMistakes({String? classCode});

  Future<MistakeBankSummary> fetchSummary();

  /// Records a practice answer and returns the updated entry.
  Future<MistakeEntry> recordPractice(
    String questionId, {
    required bool correct,
  });
}
