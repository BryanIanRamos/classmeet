import 'package:classmeet/data/models/survey.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SurveyQuestion', () {
    const q = SurveyQuestion(
      id: 'q1',
      prompt: 'When do you usually study?',
      style: SurveyQuestionStyle.chips,
      options: ['Early morning', 'After class', 'Late night'],
    );

    test('copyWith() keeps every field', () {
      final c = q.copyWith();
      expect(c.id, 'q1');
      expect(c.prompt, 'When do you usually study?');
      expect(c.style, SurveyQuestionStyle.chips);
      expect(c.options, hasLength(3));
    });

    test('copyWith changes only the given field', () {
      final c = q.copyWith(style: SurveyQuestionStyle.radios);
      expect(c.style, SurveyQuestionStyle.radios);
      expect(c.options, hasLength(3));
      expect(c.prompt, 'When do you usually study?');
    });

    test('options default to empty', () {
      const e = SurveyQuestion(
        id: 'e',
        prompt: 'p',
        style: SurveyQuestionStyle.radios,
      );
      expect(e.options, isEmpty);
    });
  });

  group('Survey', () {
    const s = Survey(
      id: 's1',
      title: 'Weekly Survey',
      rewardTalons: 5,
      questions: [
        SurveyQuestion(id: 'q', prompt: 'p', style: SurveyQuestionStyle.chips),
      ],
    );

    test('copyWith() keeps every field', () {
      final c = s.copyWith();
      expect(c.id, 's1');
      expect(c.title, 'Weekly Survey');
      expect(c.rewardTalons, 5);
      expect(c.questions, hasLength(1));
    });

    test('copyWith changes only the given field', () {
      final c = s.copyWith(rewardTalons: 2);
      expect(c.rewardTalons, 2);
      expect(c.title, 'Weekly Survey');
      expect(c.questions, hasLength(1));
    });

    test('questions default to empty', () {
      const e = Survey(id: 'e', title: 't', rewardTalons: 0);
      expect(e.questions, isEmpty);
    });
  });
}
