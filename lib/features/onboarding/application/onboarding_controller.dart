import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/catalog.dart';
import '../../../data/models/onboarding_prefs.dart';
import '../../../data/providers.dart';
import '../../auth/application/session_controller.dart';

/// The onboarding answers across steps 96–99. It loads what the profile
/// already knows (the school, from sign-up), keeps edits in memory while the
/// user moves between steps, and saves them on [finish].
final onboardingControllerProvider =
    AsyncNotifierProvider<OnboardingController, OnboardingPrefs>(
      OnboardingController.new,
    );

/// Schools for the School dropdown (96).
final schoolsProvider = FutureProvider<List<School>>(
  (ref) => ref.watch(catalogRepositoryProvider).fetchSchools(),
);

/// Colleges of a school (96, enabled once a school is chosen).
final collegesProvider = FutureProvider.family<List<College>, String>(
  (ref, schoolId) =>
      ref.watch(catalogRepositoryProvider).fetchColleges(schoolId),
);

/// Programs of a college (96, enabled once a college is chosen).
final programsProvider = FutureProvider.family<List<Program>, String>(
  (ref, collegeId) =>
      ref.watch(catalogRepositoryProvider).fetchPrograms(collegeId),
);

/// Subject chips for step 97: the chosen program's subjects (or a general
/// list when no program is set).
final subjectsProvider = FutureProvider.family<List<Subject>, String?>(
  (ref, programId) =>
      ref.watch(catalogRepositoryProvider).fetchSubjects(programId: programId),
);

class OnboardingController extends AsyncNotifier<OnboardingPrefs> {
  @override
  Future<OnboardingPrefs> build() =>
      ref.watch(profileRepositoryProvider).fetchOnboardingPrefs();

  /// Changing the school clears the college and program, which depend on it.
  void selectSchool(String schoolId) => _edit(
    (p) => _rebuild(p, schoolId: schoolId, collegeId: null, programId: null),
  );

  /// Changing the college clears the program.
  void selectCollege(String collegeId) =>
      _edit((p) => _rebuild(p, collegeId: collegeId, programId: null));

  void selectProgram(String programId) =>
      _edit((p) => p.copyWith(programId: programId));

  void selectYearLevel(YearLevel level) =>
      _edit((p) => p.copyWith(yearLevel: level));

  void toggleSubject(String subjectId) => _edit((p) {
    final subjects = {...p.subjectIds};
    if (!subjects.remove(subjectId)) subjects.add(subjectId);
    return p.copyWith(subjectIds: subjects);
  });

  /// Adds or removes a study method (98). Adding a fourth is ignored:
  /// at most [OnboardingPrefs.maxStudyMethods].
  void toggleStudyMethod(StudyMethod method) => _edit((p) {
    final methods = {...p.studyMethods};
    if (methods.remove(method)) return p.copyWith(studyMethods: methods);
    if (!p.canAddStudyMethod) return p;
    return p.copyWith(studyMethods: methods..add(method));
  });

  void selectDailyGoal(DailyGoal goal) =>
      _edit((p) => p.copyWith(dailyGoal: goal));

  void selectFrequency(StudyFrequency frequency) =>
      _edit((p) => p.copyWith(frequency: frequency));

  void selectReminderTime(ReminderTime time) =>
      _edit((p) => p.copyWith(reminderTime: time));

  void selectLanguage(LearningLanguage language) =>
      _edit((p) => p.copyWith(language: language));

  /// Saves the answers and marks the session onboarded (step 99). The caller
  /// navigates to Home afterwards.
  Future<void> finish() async {
    final prefs = state.value;
    if (prefs == null) return;
    await ref.read(profileRepositoryProvider).saveOnboardingPrefs(prefs);
    ref.read(sessionProvider.notifier).finishOnboarding();
  }

  void _edit(OnboardingPrefs Function(OnboardingPrefs prefs) change) {
    final prefs = state.value;
    if (prefs == null) return; // still loading, or failed
    state = AsyncData(change(prefs));
  }
}

/// Step 96 is complete when school, college, program and year level are set.
extension AcademicStep on OnboardingPrefs {
  bool get academicComplete =>
      schoolId != null &&
      collegeId != null &&
      programId != null &&
      yearLevel != null;
}

const _keep = Object();

/// [OnboardingPrefs.copyWith] can't clear a field to null, so the dependent
/// dropdown resets go through here.
OnboardingPrefs _rebuild(
  OnboardingPrefs p, {
  Object? schoolId = _keep,
  Object? collegeId = _keep,
  Object? programId = _keep,
}) {
  return OnboardingPrefs(
    schoolId: identical(schoolId, _keep) ? p.schoolId : schoolId as String?,
    collegeId: identical(collegeId, _keep) ? p.collegeId : collegeId as String?,
    programId: identical(programId, _keep) ? p.programId : programId as String?,
    yearLevel: p.yearLevel,
    subjectIds: p.subjectIds,
    studyMethods: p.studyMethods,
    dailyGoal: p.dailyGoal,
    frequency: p.frequency,
    reminderTime: p.reminderTime,
    language: p.language,
  );
}
