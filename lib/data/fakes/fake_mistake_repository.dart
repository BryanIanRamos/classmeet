import '../models/mistake.dart';
import '../repositories/mistake_repository.dart';
import '../repositories/repository_exception.dart';
import 'fake_config.dart';
import 'samples/mistake_samples.dart';

/// In-memory [MistakeRepository]. The attempt fake feeds it through
/// [recordMiss].
class FakeMistakeRepository implements MistakeRepository {
  FakeMistakeRepository(this._config);

  final FakeConfig _config;
  final List<MistakeEntry> _entries = List.of(sampleMistakes);

  /// Adds a missed question, or counts another miss and restarts its streak.
  /// Fake-only; called by the attempt fake for wrong and revealed answers.
  void recordMiss({
    required String questionId,
    required String prompt,
    required String classCode,
  }) {
    final i = _entries.indexWhere((e) => e.questionId == questionId);
    if (i < 0) {
      _entries.add(
        MistakeEntry(
          questionId: questionId,
          prompt: prompt,
          classCode: classCode,
        ),
      );
    } else {
      _entries[i] = _entries[i].copyWith(
        missCount: _entries[i].missCount + 1,
        correctStreak: 0,
      );
    }
  }

  @override
  Future<List<MistakeEntry>> fetchMistakes({String? classCode}) =>
      _config.answerList('fetchMistakes', () {
        final list = _entries
            .where((e) => classCode == null || e.classCode == classCode)
            .toList();
        // Not yet mastered first; each group keeps its order.
        return [
          ...list.where((e) => !e.isMastered),
          ...list.where((e) => e.isMastered),
        ];
      });

  @override
  Future<MistakeBankSummary> fetchSummary() => _config.answer(
    'fetchSummary',
    () => MistakeBankSummary(
      total: _entries.length,
      mastered: _entries.where((e) => e.isMastered).length,
    ),
    empty: () => const MistakeBankSummary(total: 0, mastered: 0),
  );

  /// A correct practice answer adds one to the streak (two in a row master
  /// the question); a wrong one counts as another miss and restarts it.
  @override
  Future<MistakeEntry> recordPractice(
    String questionId, {
    required bool correct,
  }) => _config.answer('recordPractice', () {
    final i = _entries.indexWhere((e) => e.questionId == questionId);
    if (i < 0) {
      throw RepositoryException('Question "$questionId" is not in the bank');
    }
    final e = _entries[i];
    return _entries[i] = correct
        ? e.copyWith(correctStreak: e.correctStreak + 1)
        : e.copyWith(missCount: e.missCount + 1, correctStreak: 0);
  });
}
