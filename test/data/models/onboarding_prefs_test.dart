import 'package:classmeet/data/models/onboarding_prefs.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('OnboardingPrefs', () {
    const full = OnboardingPrefs(
      schoolId: 's',
      collegeId: 'c',
      programId: 'p',
      yearLevel: YearLevel.second,
      subjectIds: {'a'},
      studyMethods: {StudyMethod.flashcards},
      dailyGoal: DailyGoal.min15,
      frequency: StudyFrequency.weekdays,
      reminderTime: ReminderTime.morning,
      language: LearningLanguage.taglish,
    );

    test('defaults are empty', () {
      const p = OnboardingPrefs();
      expect(p.schoolId, isNull);
      expect(p.subjectIds, isEmpty);
      expect(p.studyMethods, isEmpty);
      expect(p.canAddStudyMethod, isTrue);
    });

    test('copyWith() keeps every field', () {
      final c = full.copyWith();
      expect(c.schoolId, 's');
      expect(c.collegeId, 'c');
      expect(c.programId, 'p');
      expect(c.yearLevel, YearLevel.second);
      expect(c.subjectIds, {'a'});
      expect(c.studyMethods, {StudyMethod.flashcards});
      expect(c.dailyGoal, DailyGoal.min15);
      expect(c.frequency, StudyFrequency.weekdays);
      expect(c.reminderTime, ReminderTime.morning);
      expect(c.language, LearningLanguage.taglish);
    });

    test('copyWith changes only the given field', () {
      final c = full.copyWith(dailyGoal: DailyGoal.min60);
      expect(c.dailyGoal, DailyGoal.min60);
      expect(c.schoolId, 's');
      expect(c.language, LearningLanguage.taglish);
    });

    test('max study methods is 3', () {
      expect(OnboardingPrefs.maxStudyMethods, 3);
      final three = full.copyWith(
        studyMethods: {
          StudyMethod.flashcards,
          StudyMethod.studyParty,
          StudyMethod.stepByStep,
        },
      );
      expect(three.canAddStudyMethod, isFalse);
    });
  });

  group('enum copy', () {
    test('year levels', () {
      expect(YearLevel.values.map((e) => e.label), [
        '1st',
        '2nd',
        '3rd',
        '4th',
        '5th+',
      ]);
    });
    test('languages', () {
      expect(LearningLanguage.values.map((e) => e.label), [
        'English',
        'Tagalog',
        'Taglish',
      ]);
    });
    test('study methods', () {
      expect(StudyMethod.values.map((e) => e.label), [
        'Flashcards',
        'Practice quizzes',
        'Study Party',
        'Visual summaries',
        'Reading summaries',
        'Step-by-step explanations',
      ]);
      expect(StudyMethod.values.map((e) => e.caption), [
        'Review key terms and concepts',
        'Test your knowledge as you go',
        "Compete with friends and see who's on top",
        'Learn with diagrams and mind maps',
        'Review the key points quickly',
        'Break down difficult topics',
      ]);
    });
    test('daily goals', () {
      expect(DailyGoal.values.map((e) => e.minutes), [15, 30, 40, 60]);
      expect(DailyGoal.values.map((e) => e.label), [
        '15 min',
        '30 min',
        '40 min',
        '60 min',
      ]);
      expect(DailyGoal.values.map((e) => e.caption), [
        'A little each day',
        'Stay on track',
        'More progress',
        'Go deeper',
      ]);
    });
    test('frequency', () {
      expect(StudyFrequency.values.map((e) => e.label), [
        'Every day',
        'Weekdays',
        'A few days a week',
      ]);
    });
    test('reminder time', () {
      expect(ReminderTime.values.map((e) => e.label), [
        'Morning',
        'Afternoon',
        'Evening',
      ]);
    });
  });
}
