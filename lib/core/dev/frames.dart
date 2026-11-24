// The registry mixes const and function-built paths; keep it uniform.
// ignore_for_file: prefer_const_constructors

import '../router/routes.dart';

/// The Figma sections of the app, in canvas order.
enum DevSection {
  onboarding('Onboarding'),
  home('Home'),
  study('Study'),
  create('Create'),
  play('Play');

  const DevSection(this.title);

  final String title;
}

/// One Figma frame and the app location that shows it.
///
/// Frames that are only a state or a sheet of another screen point at the host
/// screen with a `state` or `sheet` query parameter; screens read it later.
final class DevFrame {
  const DevFrame({
    required this.figmaId,
    required this.section,
    required this.number,
    required this.slug,
    required this.title,
    required this.path,
    this.state,
    this.sheet,
  });

  final String figmaId;
  final DevSection section;

  /// Frame number as on the Figma canvas, e.g. `13.1`.
  final String number;
  final String slug;
  final String title;

  /// Host screen path (may already hold a query, such as `?tab=visual`).
  final String path;

  /// Value of the `state` query parameter, for frames that are a screen state.
  final String? state;

  /// Value of the `sheet` query parameter, for frames that are a sheet.
  final String? sheet;

  /// The full location to open: [path] plus the `state` / `sheet` parameter.
  String get location {
    final extra = state != null
        ? 'state=$state'
        : sheet != null
        ? 'sheet=$sheet'
        : null;
    if (extra == null) return path;
    return '$path${path.contains('?') ? '&' : '?'}$extra';
  }
}

const _course = 'ite13';
const _material = 'week-1';
const _quiz = 'intro-computing';
const _attempt = 'attempt-1';

/// All 43 Figma frames, in canvas order.
final devFrames = <DevFrame>[
  DevFrame(
    figmaId: '5444:10019',
    section: DevSection.onboarding,
    number: '94',
    slug: 'splash_welcome',
    title: 'Splash',
    path: Routes.splash,
  ),
  DevFrame(
    figmaId: '5444:10033',
    section: DevSection.onboarding,
    number: '95',
    slug: 'welcome_auth_choice',
    title: 'Welcome',
    path: Routes.welcome,
  ),
  DevFrame(
    figmaId: '5444:10062',
    section: DevSection.onboarding,
    number: '3.1',
    slug: 'sign_up',
    title: 'Sign up',
    path: Routes.signUp,
  ),
  DevFrame(
    figmaId: '5444:10106',
    section: DevSection.onboarding,
    number: '96',
    slug: 'academic_profile',
    title: 'Academic profile',
    path: Routes.onboardingAcademic,
  ),
  DevFrame(
    figmaId: '5444:10175',
    section: DevSection.onboarding,
    number: '97',
    slug: 'study_subjects',
    title: 'Study subjects',
    path: Routes.onboardingSubjects,
  ),
  DevFrame(
    figmaId: '5444:10219',
    section: DevSection.onboarding,
    number: '98',
    slug: 'learning_preferences',
    title: 'Learning preferences',
    path: Routes.onboardingPreferences,
  ),
  DevFrame(
    figmaId: '5444:10273',
    section: DevSection.onboarding,
    number: '99',
    slug: 'study_routine',
    title: 'Study routine',
    path: Routes.onboardingRoutine,
  ),
  DevFrame(
    figmaId: '5444:10350',
    section: DevSection.onboarding,
    number: '3.2',
    slug: 'state_of_3_1',
    title: 'Sign up, focused',
    path: Routes.signUp,
    state: 'focused',
  ),
  DevFrame(
    figmaId: '5438:7282',
    section: DevSection.home,
    number: '8',
    slug: 'home_dashboard',
    title: 'Home',
    path: Routes.home,
  ),
  DevFrame(
    figmaId: '5438:9575',
    section: DevSection.home,
    number: '11',
    slug: 'notifications',
    title: 'Notifications',
    path: Routes.notifications,
  ),
  DevFrame(
    figmaId: '5438:9662',
    section: DevSection.home,
    number: '12',
    slug: 'search',
    title: 'Search',
    path: Routes.search,
  ),
  DevFrame(
    figmaId: '5438:9777',
    section: DevSection.home,
    number: '13.1',
    slug: 'join_class',
    title: 'Join class',
    path: Routes.joinClass,
  ),
  DevFrame(
    figmaId: '5438:9872',
    section: DevSection.home,
    number: '13.2',
    slug: 'state_of_13_1',
    title: 'Join class, code entered',
    path: Routes.joinClass,
    state: 'entered',
  ),
  DevFrame(
    figmaId: '5438:9959',
    section: DevSection.home,
    number: '14',
    slug: 'talon_credits',
    title: 'Talon credits',
    path: Routes.talonCredits,
  ),
  DevFrame(
    figmaId: '5438:10183',
    section: DevSection.home,
    number: '15',
    slug: 'daily_gk_quiz',
    title: 'Daily GK quiz',
    path: Routes.dailyQuiz,
  ),
  DevFrame(
    figmaId: '5438:10240',
    section: DevSection.home,
    number: '16',
    slug: 'weekly_survey',
    title: 'Weekly survey',
    path: Routes.weeklySurvey,
  ),
  DevFrame(
    figmaId: '5442:14586',
    section: DevSection.study,
    number: '92',
    slug: 'study_materials',
    title: 'Study, materials',
    path: Routes.study,
  ),
  DevFrame(
    figmaId: '5442:14796',
    section: DevSection.study,
    number: '93',
    slug: 'study_classes',
    title: 'Study, classes',
    path: Routes.studyClasses,
  ),
  DevFrame(
    figmaId: '5442:8116',
    section: DevSection.study,
    number: '85',
    slug: 'course_overview',
    title: 'Course overview',
    path: Routes.course(_course),
  ),
  DevFrame(
    figmaId: '5442:8226',
    section: DevSection.study,
    number: '86',
    slug: 'add_reviewer',
    title: 'Add reviewer',
    path: Routes.addReviewer,
  ),
  DevFrame(
    figmaId: '5442:8328',
    section: DevSection.study,
    number: '87',
    slug: 'reviewer_reader',
    title: 'Reviewer, read',
    path: Routes.reader(_material, tab: 'read'),
  ),
  DevFrame(
    figmaId: '5442:8379',
    section: DevSection.study,
    number: '91',
    slug: 'explain_sheet',
    title: 'Explain sheet',
    path: Routes.reader(_material),
    sheet: 'explain',
  ),
  DevFrame(
    figmaId: '5442:8460',
    section: DevSection.study,
    number: '88',
    slug: 'reader_mind_map',
    title: 'Reviewer, mind map',
    path: Routes.reader(_material, tab: 'visual'),
  ),
  DevFrame(
    figmaId: '5442:8561',
    section: DevSection.study,
    number: '90',
    slug: 'downloads',
    title: 'Downloads',
    path: Routes.downloads,
  ),
  DevFrame(
    figmaId: '5443:15332',
    section: DevSection.study,
    number: '89',
    slug: 'reader_listen',
    title: 'Reviewer, listen',
    path: Routes.reader(_material, tab: 'listen'),
  ),
  DevFrame(
    figmaId: '5444:10922',
    section: DevSection.create,
    number: '119',
    slug: 'create_sheet',
    title: 'Create sheet, on Study',
    path: Routes.study,
    sheet: 'create',
  ),
  DevFrame(
    figmaId: '5444:11163',
    section: DevSection.create,
    number: '120',
    slug: 'variant_of_119',
    title: 'Create sheet, on Home',
    path: Routes.home,
    sheet: 'create',
  ),
  DevFrame(
    figmaId: '5444:11404',
    section: DevSection.create,
    number: '121',
    slug: 'create_screen',
    title: 'Create',
    path: Routes.create,
  ),
  DevFrame(
    figmaId: '5444:11516',
    section: DevSection.create,
    number: '114',
    slug: 'quiz_source',
    title: 'Quiz source',
    path: Routes.quizSource,
  ),
  DevFrame(
    figmaId: '5444:11599',
    section: DevSection.create,
    number: '115',
    slug: 'quiz_customize',
    title: 'Quiz customize',
    path: Routes.quizCustomize,
  ),
  DevFrame(
    figmaId: '5444:11718',
    section: DevSection.create,
    number: '116',
    slug: 'quiz_preview',
    title: 'Quiz preview',
    path: Routes.quizPreview,
  ),
  DevFrame(
    figmaId: '5444:11830',
    section: DevSection.create,
    number: '117',
    slug: 'quiz_generating',
    title: 'Quiz generating',
    path: Routes.quizGenerating,
  ),
  DevFrame(
    figmaId: '5444:12094',
    section: DevSection.create,
    number: '118',
    slug: 'quiz_ready',
    title: 'Quiz ready',
    path: Routes.quizReady,
  ),
  DevFrame(
    figmaId: '5453:13881',
    section: DevSection.play,
    number: '122',
    slug: 'play_hub',
    title: 'Play hub',
    path: Routes.play,
  ),
  DevFrame(
    figmaId: '5453:16158',
    section: DevSection.play,
    number: '123',
    slug: 'quiz_setup',
    title: 'Quiz setup',
    path: Routes.quizSetup(_quiz),
  ),
  DevFrame(
    figmaId: '5453:16270',
    section: DevSection.play,
    number: '124',
    slug: 'question',
    title: 'Question',
    path: Routes.question(_attempt),
  ),
  DevFrame(
    figmaId: '5453:16359',
    section: DevSection.play,
    number: '125',
    slug: 'correct_state',
    title: 'Question, correct',
    path: Routes.question(_attempt),
    state: 'correct',
  ),
  DevFrame(
    figmaId: '5453:16461',
    section: DevSection.play,
    number: '126',
    slug: 'revealed_state',
    title: 'Question, revealed',
    path: Routes.question(_attempt),
    state: 'revealed',
  ),
  DevFrame(
    figmaId: '5453:16618',
    section: DevSection.play,
    number: '127',
    slug: 'mistake_bank',
    title: 'Mistake bank',
    path: Routes.mistakeBank,
  ),
  DevFrame(
    figmaId: '5453:16711',
    section: DevSection.play,
    number: '128',
    slug: 'discussion_sheet',
    title: 'Discussion sheet',
    path: Routes.question(_attempt),
    sheet: 'discussion',
  ),
  DevFrame(
    figmaId: '5453:17004',
    section: DevSection.play,
    number: '129',
    slug: 'wrong_answer_sheet',
    title: 'Wrong answer sheet',
    path: Routes.question(_attempt),
    sheet: 'wrong-answer',
  ),
  DevFrame(
    figmaId: '5453:17116',
    section: DevSection.play,
    number: '132',
    slug: 'quiz_results',
    title: 'Quiz results',
    path: Routes.quizResults(_attempt),
  ),
  DevFrame(
    figmaId: '5453:17677',
    section: DevSection.play,
    number: '133',
    slug: 'ranking_privacy_sheet',
    title: 'Ranking privacy sheet',
    path: Routes.quizResults(_attempt),
    sheet: 'ranking-privacy',
  ),
];
