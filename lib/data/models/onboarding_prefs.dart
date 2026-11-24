/// Year level choice (96).
enum YearLevel {
  first('1st'),
  second('2nd'),
  third('3rd'),
  fourth('4th'),
  fifthPlus('5th+');

  const YearLevel(this.label);

  /// Exact chip copy.
  final String label;
}

/// Preferred learning language (96 shows placeholders, 99 the real copy).
enum LearningLanguage {
  english('English'),
  tagalog('Tagalog'),
  taglish('Taglish');

  const LearningLanguage(this.label);

  final String label;
}

/// Study method cards (98).
enum StudyMethod {
  flashcards('Flashcards', 'Review key terms and concepts'),
  practiceQuizzes('Practice quizzes', 'Test your knowledge as you go'),
  studyParty('Study Party', "Study with friends and see who's on top"),
  visualSummaries('Visual summaries', 'Learn with diagrams and mind maps'),
  readingSummaries('Reading summaries', 'Review the key points quickly'),
  stepByStep('Step-by-step explanations', 'Break down difficult topics');

  const StudyMethod(this.label, this.caption);

  final String label;
  final String caption;
}

/// Daily study goal cards (99).
enum DailyGoal {
  min15(15, '15 min', 'A little each day'),
  min30(30, '30 min', 'Stay on track'),
  min40(40, '40 min', 'More progress'),
  min60(60, '60 min', 'Go deeper');

  const DailyGoal(this.minutes, this.label, this.caption);

  final int minutes;
  final String label;
  final String caption;
}

/// How often the user studies (99).
enum StudyFrequency {
  everyDay('Every day'),
  weekdays('Weekdays'),
  fewDaysAWeek('A few days a week');

  const StudyFrequency(this.label);

  final String label;
}

/// When to remind the user (99).
enum ReminderTime {
  morning('Morning'),
  afternoon('Afternoon'),
  evening('Evening');

  const ReminderTime(this.label);

  final String label;
}

/// Choices collected across the onboarding steps (96-99).
final class OnboardingPrefs {
  const OnboardingPrefs({
    this.schoolId,
    this.collegeId,
    this.programId,
    this.yearLevel,
    this.subjectIds = const {},
    this.studyMethods = const {},
    this.dailyGoal,
    this.frequency,
    this.reminderTime,
    this.language,
  });

  /// Study methods can be picked up to this many (98 "2 of 3 selected").
  static const maxStudyMethods = 3;

  final String? schoolId;
  final String? collegeId;
  final String? programId;
  final YearLevel? yearLevel;
  final Set<String> subjectIds;
  final Set<StudyMethod> studyMethods;
  final DailyGoal? dailyGoal;
  final StudyFrequency? frequency;
  final ReminderTime? reminderTime;
  final LearningLanguage? language;

  /// True while another study method may still be picked.
  bool get canAddStudyMethod => studyMethods.length < maxStudyMethods;

  OnboardingPrefs copyWith({
    String? schoolId,
    String? collegeId,
    String? programId,
    YearLevel? yearLevel,
    Set<String>? subjectIds,
    Set<StudyMethod>? studyMethods,
    DailyGoal? dailyGoal,
    StudyFrequency? frequency,
    ReminderTime? reminderTime,
    LearningLanguage? language,
  }) {
    return OnboardingPrefs(
      schoolId: schoolId ?? this.schoolId,
      collegeId: collegeId ?? this.collegeId,
      programId: programId ?? this.programId,
      yearLevel: yearLevel ?? this.yearLevel,
      subjectIds: subjectIds ?? this.subjectIds,
      studyMethods: studyMethods ?? this.studyMethods,
      dailyGoal: dailyGoal ?? this.dailyGoal,
      frequency: frequency ?? this.frequency,
      reminderTime: reminderTime ?? this.reminderTime,
      language: language ?? this.language,
    );
  }
}
