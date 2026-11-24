import 'package:classmeet/data/fakes/fake_config.dart';
import 'package:classmeet/data/fakes/fake_mistake_repository.dart';
import 'package:classmeet/data/repositories/repository_exception.dart';
import 'package:flutter_test/flutter_test.dart';

const _empty = FakeConfig(scenario: FakeScenario.empty, latency: Duration.zero);
const _error = FakeConfig(scenario: FakeScenario.error, latency: Duration.zero);

void main() {
  late FakeMistakeRepository repo;
  setUp(() => repo = FakeMistakeRepository(FakeConfig.instant));

  test('38 entries, 12 mastered, derived summary', () async {
    final all = await repo.fetchMistakes();
    expect(all, hasLength(38));
    expect(all.where((e) => e.isMastered), hasLength(12));
    expect(all.map((e) => e.questionId).toSet(), hasLength(38));
    final s = await repo.fetchSummary();
    expect((s.total, s.mastered), (38, 12));
    expect(all.map((e) => e.classCode).toSet(), {'ITE13', 'CSC126', 'IS109'});
  });

  test('design rows come first, mastered ones last', () async {
    final all = await repo.fetchMistakes();
    expect(all[0].prompt, 'What does RAM stand for?');
    expect(all[0].classCode, 'ITE13');
    expect(all[0].missCount, 3);
    expect(all[1].prompt, 'List four functions of a computer');
    expect(all[2].prompt, 'Explain the if–else syntax in C');
    expect(all[4].prompt, 'Convert binary 1011 to decimal');
    expect(all.take(26).every((e) => !e.isMastered), isTrue);
    expect(all.skip(26).every((e) => e.isMastered), isTrue);
  });

  test('filters by course', () async {
    for (final code in ['ITE13', 'CSC126', 'IS109']) {
      final list = await repo.fetchMistakes(classCode: code);
      expect(list, isNotEmpty);
      expect(list.every((e) => e.classCode == code), isTrue);
    }
    expect(await repo.fetchMistakes(classCode: 'XYZ'), isEmpty);
  });

  test('two correct practices in a row master a question', () async {
    const id = 'intro-computing-q3';
    final one = await repo.recordPractice(id, correct: true);
    expect(one.isMastered, isFalse);
    final two = await repo.recordPractice(id, correct: true);
    expect(two.isMastered, isTrue);
    expect((await repo.fetchSummary()).mastered, 13);
  });

  test('a wrong practice restarts the streak and counts a miss', () async {
    const id = 'intro-computing-q3';
    await repo.recordPractice(id, correct: true);
    final e = await repo.recordPractice(id, correct: false);
    expect((e.correctStreak, e.missCount), (0, 4));
    expect((await repo.recordPractice(id, correct: true)).isMastered, isFalse);
  });

  test('recordMiss adds new entries and restarts a mastered one', () async {
    repo.recordMiss(questionId: 'new', prompt: 'P?', classCode: 'ITE13');
    expect((await repo.fetchSummary()).total, 39);
    final mastered = (await repo.fetchMistakes()).last;
    expect(mastered.isMastered, isTrue);
    repo.recordMiss(
      questionId: mastered.questionId,
      prompt: mastered.prompt,
      classCode: mastered.classCode,
    );
    final s = await repo.fetchSummary();
    expect((s.total, s.mastered), (39, 11));
  });

  test('practice on an unknown question throws', () async {
    await expectLater(
      repo.recordPractice('nope', correct: true),
      throwsA(isA<RepositoryException>()),
    );
  });

  test('empty scenario returns empty lists and an empty summary', () async {
    final r = FakeMistakeRepository(_empty);
    expect(await r.fetchMistakes(), isEmpty);
    final s = await r.fetchSummary();
    expect((s.total, s.mastered), (0, 0));
  });

  test('error scenario throws RepositoryException', () async {
    final r = FakeMistakeRepository(_error);
    await expectLater(r.fetchMistakes(), throwsA(isA<RepositoryException>()));
    await expectLater(r.fetchSummary(), throwsA(isA<RepositoryException>()));
    await expectLater(
      r.recordPractice('intro-computing-q3', correct: true),
      throwsA(isA<RepositoryException>()),
    );
  });
}
