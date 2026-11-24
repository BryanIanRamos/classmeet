import 'package:classmeet/data/models/mistake.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('MistakeEntry', () {
    const m = MistakeEntry(
      questionId: 'q',
      prompt: 'What does RAM stand for?',
      classCode: 'ITE13',
      missCount: 3,
    );
    expect(MistakeEntry.masteryStreak, 2);
    final c = m.copyWith();
    expect(
      [c.questionId, c.prompt, c.classCode, c.missCount],
      ['q', 'What does RAM stand for?', 'ITE13', 3],
    );
    expect(c.correctStreak, 0);
    final d = m.copyWith(missCount: 4);
    expect(d.missCount, 4);
    expect(d.prompt, m.prompt);
  });

  test('isMastered', () {
    const m = MistakeEntry(questionId: 'q', prompt: 'p', classCode: 'c');
    expect(m.isMastered, isFalse);
    expect(m.copyWith(correctStreak: 1).isMastered, isFalse);
    expect(m.copyWith(correctStreak: 2).isMastered, isTrue);
    expect(m.copyWith(correctStreak: 5).isMastered, isTrue);
  });

  test('MistakeBankSummary', () {
    const s = MistakeBankSummary(total: 38, mastered: 12);
    expect(s.fraction, closeTo(12 / 38, 1e-9));
    expect(s.copyWith().total, 38);
    expect(s.copyWith().mastered, 12);
    expect(s.copyWith(total: 0).fraction, 0);
    expect(s.copyWith(mastered: 99).fraction, 1);
  });
}
