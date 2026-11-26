/// Weekly Survey (frame 16): the copy, picking answers, submitting (what is
/// sent, the talons, double taps, failures, leaving mid-send), the way out, the
/// loading, empty and error states, the controller, and the layout. The last
/// group loads the real fonts for the designed sizes; the others run in the
/// wide test font, which wraps text earlier and so is the stricter overflow
/// check.
library;

import 'dart:async';
import 'dart:ui' show CheckedState, Tristate;

import 'package:classmeet/core/router/routes.dart';
import 'package:classmeet/core/theme/app_colors.dart';
import 'package:classmeet/core/theme/app_theme.dart';
import 'package:classmeet/core/theme/app_typography.dart';
import 'package:classmeet/core/widgets/buttons/app_button.dart';
import 'package:classmeet/core/widgets/feedback/app_alert.dart';
import 'package:classmeet/core/widgets/feedback/app_loader.dart';
import 'package:classmeet/core/widgets/feedback/empty_state.dart';
import 'package:classmeet/core/widgets/feedback/error_state.dart';
import 'package:classmeet/core/widgets/selection/app_answer_option.dart';
import 'package:classmeet/core/widgets/selection/app_chip.dart';
import 'package:classmeet/data/fakes/fake_config.dart';
import 'package:classmeet/data/fakes/fake_quest_repository.dart';
import 'package:classmeet/data/fakes/fake_wallet_repository.dart';
import 'package:classmeet/data/fakes/samples/quest_samples.dart';
import 'package:classmeet/data/models/quest.dart';
import 'package:classmeet/data/models/survey.dart';
import 'package:classmeet/data/models/wallet.dart';
import 'package:classmeet/data/providers.dart';
import 'package:classmeet/data/repositories/repository_exception.dart';
import 'package:classmeet/features/home/application/home_providers.dart';
import 'package:classmeet/features/home/application/weekly_survey_controller.dart';
import 'package:classmeet/features/home/presentation/screens/weekly_survey_screen.dart';
import 'package:classmeet/features/home/presentation/widgets/quest_card.dart';
import 'package:classmeet/features/home/presentation/widgets/survey_footer.dart';
import 'package:classmeet/features/home/presentation/widgets/survey_info_card.dart';
import 'package:classmeet/features/home/presentation/widgets/survey_intro.dart';
import 'package:classmeet/features/home/presentation/widgets/survey_question_block.dart';
import 'package:classmeet/features/home/presentation/widgets/survey_result_sheet.dart';
import 'package:classmeet/features/home/presentation/widgets/survey_reward_row.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/app_fonts.dart';
import 'home_test_helpers.dart';

/// The survey quest once this week's reward was taken (frame 14 "Reward
/// claimed"); the sample one is still open.
final _claimedQuest = Quest(
  id: surveyQuestId,
  title: 'Weekly Survey',
  kind: QuestKind.survey,
  rewardTalons: 5,
  total: 1,
  status: QuestStatus.claimed,
  availableUntil: DateTime(2026, 11, 29, 23, 59, 59),
);

/// The sample survey with text that is long everywhere, for the narrow
/// screens. It keeps the ids and option counts, so the fake takes its answers.
final _longSurvey = weeklySurvey.copyWith(
  title: 'How is your study week going so far, and what could we do better?',
  questions: [
    for (final q in weeklySurvey.questions)
      q.copyWith(
        prompt:
            'Thinking about the whole of this past week, and not only about '
            'today: ${q.prompt}',
        options: [
          for (final o in q.options)
            '$o, said in a deliberately long way so that it has to wrap over '
                'several lines on a small screen',
        ],
      ),
  ],
);

/// The quest fake with the sample survey, told to fail or to be slow, that
/// records what it was asked.
class _Quests extends FakeQuestRepository {
  _Quests({
    super.quests,
    this.survey,
    this.failFetches = 0,
    this.failSubmits = 0,
    this.failQuests = false,
    this.submitDelay = Duration.zero,
  }) : super(FakeConfig.instant, clock: () => evening);

  /// Served instead of the sample survey.
  final Survey? survey;

  /// How many of the first survey loads and submits fail.
  final int failFetches;
  final int failSubmits;

  /// The quest list cannot be read, so the page has no reward strip.
  final bool failQuests;
  final Duration submitDelay;

  int fetchCalls = 0;
  int claimCalls = 0;

  /// The answers of every submit, failed ones included.
  final submits = <Map<String, int>>[];

  @override
  Future<List<Quest>> fetchQuests() async {
    if (failQuests) throw const RepositoryException('quests offline');
    return super.fetchQuests();
  }

  @override
  Future<Survey> fetchWeeklySurvey() async {
    if (++fetchCalls <= failFetches) {
      throw const RepositoryException('survey offline');
    }
    return survey ?? await super.fetchWeeklySurvey();
  }

  @override
  Future<void> submitSurvey(String surveyId, Map<String, int> answers) async {
    submits.add(Map.of(answers));
    if (submitDelay > Duration.zero) await Future<void>.delayed(submitDelay);
    if (submits.length <= failSubmits) {
      throw const RepositoryException('offline');
    }
    return super.submitSurvey(surveyId, answers);
  }

  @override
  Future<Quest> claimQuest(String questId) {
    claimCalls++;
    return super.claimQuest(questId);
  }
}

/// A wallet whose first earn call fails.
class _FlakyWallet extends FakeWalletRepository {
  _FlakyWallet() : super(FakeConfig.instant);

  int earnCalls = 0;

  @override
  Future<Wallet> earn({int talons = 0, int studyPoints = 0, int xp = 0}) async {
    if (++earnCalls == 1) throw const RepositoryException('wallet offline');
    return super.earn(talons: talons, studyPoints: studyPoints, xp: xp);
  }
}

final _submitLabel = SurveyFooter.submitLabel(5);

/// The text of option [option] of the [question]-th question of [survey] (the
/// sample survey by default): 'After class' is question 0, option 1.
String _label(int question, int option, [Survey? survey]) =>
    (survey ?? weeklySurvey).questions[question].options[option];

Finder _chip(String label) =>
    find.byWidgetPredicate((w) => w is AppChip && w.label == label);

Finder _option(String label) =>
    find.byWidgetPredicate((w) => w is AppAnswerOption && w.label == label);

Finder _button(String label) => find.widgetWithText(AppButton, label);

bool _enabled(WidgetTester tester, String label) =>
    tester.widget<AppButton>(_button(label)).onPressed != null;

/// The index of the picked option of [question], or null.
int? _pickedIn(WidgetTester tester, SurveyQuestion question) {
  for (var i = 0; i < question.options.length; i++) {
    final label = question.options[i];
    final picked = switch (question.style) {
      SurveyQuestionStyle.chips =>
        tester.widget<AppChip>(_chip(label)).selected,
      SurveyQuestionStyle.radios =>
        tester.widget<AppAnswerOption>(_option(label)).state ==
            AppAnswerOptionState.selected,
    };
    if (picked) return i;
  }
  return null;
}

/// The picked option of each sample question, by index.
List<int?> _picks(WidgetTester tester) => [
  for (final q in weeklySurvey.questions) _pickedIn(tester, q),
];

/// The wallet's talons, after any pending reload.
Future<int> _talons(WidgetTester tester) async =>
    (await container(tester).read(walletProvider.future)).talons;

Future<void> _tap(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

/// Picks option [option] of the [question]-th question.
Future<void> _pick(
  WidgetTester tester,
  int question,
  int option, [
  Survey? survey,
]) => _tap(tester, find.text(_label(question, option, survey)));

Future<void> _submit(WidgetTester tester) =>
    _tap(tester, _button(_submitLabel));

/// The survey opened over Home, as the app does.
Future<void> _openSurvey(
  WidgetTester tester, {
  FakeConfig config = FakeConfig.instant,
  Size size = const Size(428, 926),
  _Quests? quests,
}) => pumpHome(
  tester,
  config: config,
  size: size,
  location: Routes.weeklySurvey,
  overrides: [
    if (quests != null) questRepositoryProvider.overrideWithValue(quests),
  ],
);

/// The survey pushed from a plain button, without Home or the router. The
/// test is left to tap "open" so it can pace the loading.
Future<void> _openPlain(WidgetTester tester, List<Override> overrides) async {
  await tester.binding.setSurfaceSize(const Size(428, 926));
  addTearDown(() => tester.binding.setSurfaceSize(null));
  await tester.pumpWidget(
    ProviderScope(
      overrides: overrides,
      retry: (_, _) => null,
      child: MaterialApp(
        theme: AppTheme.light,
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const WeeklySurveyScreen(),
                ),
              ),
              child: const Text('open'),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('open'));
}

void main() {
  group('the survey', () {
    testWidgets('shows the survey as designed', (tester) async {
      await _openSurvey(tester);
      expect(location(tester), Routes.weeklySurvey);
      for (final text in [
        'Weekly Survey',
        'Available until Sunday',
        '+5 talons',
        "How's your study week going?",
        SurveyIntro.intro,
        '1.',
        'When do you usually study?',
        '2.',
        "What's your biggest study challenge?",
        '3.',
        'How much time did you spend studying this week?',
        for (final q in weeklySurvey.questions) ...q.options,
        SurveyInfoCard.title,
        SurveyInfoCard.body,
        'Submit survey · Earn 5 Talons',
        'Skip survey',
      ]) {
        expect(find.text(text), findsOneWidget, reason: text);
      }

      // The first question is chips, the others radio cards; nothing picked.
      expect(find.byType(AppChip), findsNWidgets(3));
      expect(find.byType(AppAnswerOption), findsNWidgets(7));
      for (final chip in tester.widgetList<AppChip>(find.byType(AppChip))) {
        expect(chip.style, AppChipStyle.neutral);
        expect(chip.kind, AppChipKind.choice);
      }
      expect(_picks(tester), [null, null, null]);
      // Every question can be skipped, so Submit works with nothing picked.
      expect(_enabled(tester, _submitLabel), isTrue);
      expect(find.byType(AppAlert), findsNothing);
      expect(find.byType(SurveyResultSheet), findsNothing);
    });

    testWidgets('picks one answer per question, each on its own', (
      tester,
    ) async {
      await _openSurvey(tester);
      await _pick(tester, 0, 1); // After class
      expect(_picks(tester), [1, null, null]);
      await _pick(tester, 0, 2); // Late night replaces it
      expect(_picks(tester), [2, null, null]);

      await _pick(tester, 1, 0);
      await _pick(tester, 2, 3);
      expect(_picks(tester), [2, 0, 3]);
      await _pick(tester, 1, 2); // replaces the first pick of question 2 only
      expect(_picks(tester), [2, 2, 3]);

      // Tapping the picked one again keeps it.
      await _pick(tester, 0, 2);
      await _pick(tester, 1, 2);
      expect(_picks(tester), [2, 2, 3]);
    });

    testWidgets('the reward strip hides while the quests are unavailable', (
      tester,
    ) async {
      await _openSurvey(tester, quests: _Quests(failQuests: true));
      expect(find.text("How's your study week going?"), findsOneWidget);
      expect(find.byType(SurveyRewardRow), findsNothing);
      // The button falls back on the survey's own reward.
      expect(find.text('Submit survey · Earn 5 Talons'), findsOneWidget);
    });
  });

  group('submitting', () {
    testWidgets('sends only what was picked, in question order', (
      tester,
    ) async {
      final quests = _Quests();
      await _openSurvey(tester, quests: quests);
      await _pick(tester, 2, 3); // the last question first
      await _pick(tester, 0, 1);
      await _submit(tester);

      expect(quests.submits, hasLength(1));
      expect(quests.submits.single, {'when': 1, 'hours': 3});
      expect(quests.submits.single.keys, ['when', 'hours']);
    });

    testWidgets('with nothing picked it sends nothing and earns the talons', (
      tester,
    ) async {
      final quests = _Quests();
      await _openSurvey(tester, quests: quests);
      expect(await _talons(tester), 24);
      await _submit(tester);

      expect(quests.submits, [<String, int>{}]);
      expect(find.text('Thanks for sharing!'), findsOneWidget);
      expect(find.text('+5 talons earned'), findsOneWidget);
      expect(find.text(SurveyResultSheet.alreadyEarned), findsNothing);
      expect(await _talons(tester), 29);
      expect(quests.claimCalls, 1);
      final quest = (await container(tester).read(
        questsProvider.future,
      )).firstWhere((q) => q.kind == QuestKind.survey);
      expect(quest.status, QuestStatus.claimed);

      // "Done" goes back to where the survey was opened: Home shows the new
      // balance, and Talon credits the claimed reward.
      await _tap(tester, _button('Done'));
      expect(location(tester), Routes.home);
      expect(find.text('29'), findsOneWidget);
      unawaited(router(tester).push(Routes.talonCredits));
      await tester.pumpAndSettle();
      final card = find.byWidgetPredicate(
        (w) => w is QuestCard && w.quest.id == surveyQuestId,
      );
      await reveal(tester, card); // the list builds its cards as they come
      expect(
        find.descendant(of: card, matching: find.text('Reward claimed')),
        findsOneWidget,
      );
      expect(find.text('Answer survey'), findsNothing);
    });

    testWidgets('a reward already taken pays nothing again', (tester) async {
      final quests = _Quests(quests: [_claimedQuest]);
      await _openSurvey(tester, quests: quests);
      await _pick(tester, 1, 1);
      await _submit(tester);

      expect(find.text('Thanks for sharing!'), findsOneWidget);
      expect(find.text(SurveyResultSheet.alreadyEarned), findsOneWidget);
      expect(find.textContaining('talons earned'), findsNothing);
      expect(quests.submits, [
        {'challenge': 1},
      ]); // the answers still count
      expect((quests.claimCalls, await _talons(tester)), (0, 24));
    });

    testWidgets('a double tap sends once', (tester) async {
      final quests = _Quests(submitDelay: const Duration(seconds: 1));
      await _openSurvey(tester, quests: quests);
      final button = _button(_submitLabel);
      await tester.ensureVisible(button);
      await tester.tap(button);
      await tester.tap(button); // before any frame: it still looks enabled
      await tester.pump();
      expect(_enabled(tester, _submitLabel), isFalse); // sending
      await tester.pump(const Duration(seconds: 2));
      await tester.pumpAndSettle();

      expect((quests.submits.length, quests.claimCalls), (1, 1));
      expect(find.text('+5 talons earned'), findsOneWidget);
      expect(await _talons(tester), 29);
    });

    testWidgets('a failed submit shows a notice and can be tried again', (
      tester,
    ) async {
      final quests = _Quests(failSubmits: 1);
      await _openSurvey(tester, quests: quests);
      await _pick(tester, 0, 0);
      await _submit(tester); // fails

      expect(find.text('Could not submit the survey'), findsOneWidget);
      expect(find.text('Thanks for sharing!'), findsNothing);
      expect(_enabled(tester, _submitLabel), isTrue);
      expect(_picks(tester), [0, null, null]); // the pick is kept
      expect(await _talons(tester), 24);
      // The notice pushed the button down; the page brought both back in view.
      expect(
        tester.getRect(find.byType(AppAlert)).top,
        greaterThanOrEqualTo(0),
      );
      expect(
        tester.getBottomLeft(find.byType(SurveyFooter)).dy,
        lessThanOrEqualTo(926),
      );

      await _submit(tester);
      expect(find.text('Could not submit the survey'), findsNothing);
      expect(find.text('+5 talons earned'), findsOneWidget);
      expect(quests.submits, [
        {'when': 0},
        {'when': 0},
      ]);
      expect(await _talons(tester), 29);
    });

    testWidgets('the sheet ends with Done or the back key only', (
      tester,
    ) async {
      await _openSurvey(tester);
      await _submit(tester);

      await tester.tapAt(const Offset(20, 20)); // the scrim does nothing
      await tester.pumpAndSettle();
      expect(find.text('Thanks for sharing!'), findsOneWidget);
      expect(location(tester), Routes.weeklySurvey);

      await tester.binding.handlePopRoute(); // the back key leaves the survey
      await tester.pumpAndSettle();
      expect(find.text('Thanks for sharing!'), findsNothing);
      expect(location(tester), Routes.home);
    });

    testWidgets('leaving while the survey is sent does not throw, and the '
        'talons still arrive', (tester) async {
      final quests = _Quests(submitDelay: const Duration(seconds: 2));
      await _openPlain(tester, [
        fakeConfigProvider.overrideWithValue(FakeConfig.instant),
        questRepositoryProvider.overrideWithValue(quests),
      ]);
      await tester.pumpAndSettle();

      await tester.ensureVisible(_button(_submitLabel));
      await tester.tap(_button(_submitLabel));
      await tester.pump(); // the 2 s send starts
      await tester.tap(find.bySemanticsLabel('Back'));
      await tester.pump();
      await tester.pump(const Duration(seconds: 1)); // route out
      await tester.pump();
      expect(find.byType(WeeklySurveyScreen), findsNothing);

      await tester.pump(const Duration(seconds: 2)); // the late answer lands
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.text('Thanks for sharing!'), findsNothing);
      // Claimed and paid together, although nobody was there to see it.
      final scope = ProviderScope.containerOf(
        tester.element(find.text('open')),
      );
      expect(quests.claimCalls, 1);
      expect((await scope.read(walletProvider.future)).talons, 29);
    });
  });

  group('around the survey', () {
    // Finders are built inside the test: a semantics finder needs a running
    // test.
    for (final (way, finder) in <(String, Finder Function())>[
      ('Skip survey', () => find.text('Skip survey')),
      ('Back', () => find.bySemanticsLabel('Back')),
    ]) {
      testWidgets('$way leaves without sending', (tester) async {
        final quests = _Quests();
        await _openSurvey(tester, quests: quests);
        await _pick(tester, 0, 1);
        await _tap(tester, finder());

        expect(location(tester), Routes.home);
        expect(find.byType(WeeklySurveyScreen), findsNothing);
        expect(quests.submits, isEmpty);
        expect(await _talons(tester), 24);

        // Opened again it starts over.
        unawaited(router(tester).push(Routes.weeklySurvey));
        await tester.pumpAndSettle();
        expect(_picks(tester), [null, null, null]);
      });
    }

    testWidgets('loading shows a loader, then the survey', (tester) async {
      await _openPlain(tester, [
        fakeConfigProvider.overrideWithValue(
          const FakeConfig(latency: Duration(seconds: 1)),
        ),
      ]);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
      expect(find.byType(AppLoader), findsOneWidget);
      expect(find.text('Weekly Survey'), findsOneWidget);
      expect(find.text(_submitLabel), findsNothing);

      await tester.pump(const Duration(seconds: 2));
      await tester.pumpAndSettle();
      expect(find.byType(AppLoader), findsNothing);
      expect(find.text("How's your study week going?"), findsOneWidget);
    });

    testWidgets('empty scenario: no survey this week', (tester) async {
      await _openSurvey(tester, config: emptyConfig);
      expect(find.byType(EmptyState), findsOneWidget);
      expect(find.text('No survey this week'), findsOneWidget);
      expect(find.text('Check back on Monday for a new one.'), findsOneWidget);
      expect(find.text(_submitLabel), findsNothing);
      expect(find.byType(SurveyRewardRow), findsNothing); // no quests either
      expect(tester.takeException(), isNull);

      await tester.tap(find.bySemanticsLabel('Back'));
      await tester.pumpAndSettle();
      expect(location(tester), Routes.home);
    });

    testWidgets('error scenario: a retryable error', (tester) async {
      await _openSurvey(tester, config: errorConfig);
      expect(find.byType(ErrorState), findsOneWidget);
      expect(find.text(_submitLabel), findsNothing);
      expect(find.byType(SurveyRewardRow), findsNothing);

      await tester.tap(find.text('Try again'));
      await tester.pumpAndSettle();
      expect(find.byType(ErrorState), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('retry loads the survey again', (tester) async {
      final quests = _Quests(failFetches: 1);
      await _openSurvey(tester, quests: quests);
      expect(find.byType(ErrorState), findsOneWidget);

      await tester.tap(find.text('Try again'));
      await tester.pumpAndSettle();
      expect(quests.fetchCalls, 2);
      expect(find.byType(ErrorState), findsNothing);
      expect(find.text("How's your study week going?"), findsOneWidget);
    });
  });

  group('WeeklySurveyController', () {
    ProviderContainer makeContainer({
      FakeConfig config = FakeConfig.instant,
      _Quests? quests,
      _FlakyWallet? wallet,
    }) {
      final container = ProviderContainer(
        overrides: [
          fakeConfigProvider.overrideWithValue(config),
          if (quests != null) questRepositoryProvider.overrideWithValue(quests),
          if (wallet != null)
            walletRepositoryProvider.overrideWithValue(wallet),
        ],
        retry: (_, _) => null,
      );
      addTearDown(container.dispose);
      // Auto-disposed: a listener keeps it alive between calls.
      final subscription = container.listen(
        weeklySurveyControllerProvider,
        (_, _) {},
      );
      addTearDown(subscription.close);
      return container;
    }

    WeeklySurveyState stateOf(ProviderContainer container) =>
        container.read(weeklySurveyControllerProvider).requireValue;

    Future<WeeklySurveyController> ready(ProviderContainer container) async {
      await container.read(weeklySurveyControllerProvider.future);
      return container.read(weeklySurveyControllerProvider.notifier);
    }

    test('picks only take known questions and options', () async {
      final container = makeContainer();
      final controller = await ready(container);
      expect(stateOf(container).survey.questions, hasLength(3));
      expect(stateOf(container).answers, isEmpty);

      controller
        ..select('nope', 0)
        ..select('when', -1)
        ..select('when', 3)
        ..select('when', 1); // only the last one is a pick
      expect(stateOf(container).answers, {'when': 1});

      final before = container.read(weeklySurveyControllerProvider);
      controller.select('when', 1); // the picked one again: nothing changes
      expect(container.read(weeklySurveyControllerProvider), same(before));

      controller
        ..select('when', 2)
        ..select('hours', 0);
      expect(stateOf(container).answers, {'when': 2, 'hours': 0});
    });

    test('the picks are locked while it is sent and after', () async {
      final quests = _Quests(submitDelay: const Duration(milliseconds: 20));
      final container = makeContainer(quests: quests);
      final controller = await ready(container);
      controller.select('when', 0);

      final sending = controller.submit();
      expect(stateOf(container).submitting, isTrue);
      controller.select('when', 2);
      expect(stateOf(container).answers, {'when': 0});

      final result = (await sending)!;
      expect(result.talonsEarned, 5);
      expect(stateOf(container).result, same(result));
      controller.select('hours', 1);
      expect(stateOf(container).answers, {'when': 0});
      expect(await controller.submit(), isNull); // sent already
      expect(quests.submits, hasLength(1));
    });

    test('talons claimed but not yet paid are paid on the retry', () async {
      final quests = _Quests();
      final wallet = _FlakyWallet();
      final container = makeContainer(quests: quests, wallet: wallet);
      final controller = await ready(container);

      // 1: the quest is claimed, adding the talons fails.
      expect(await controller.submit(), isNull);
      final failed = stateOf(container);
      expect(
        (failed.submitFailed, failed.submitting, failed.isOpen),
        (true, false, true),
      );
      final quest = (await quests.fetchQuests()).firstWhere(
        (q) => q.kind == QuestKind.survey,
      );
      expect(quest.status, QuestStatus.claimed);
      expect((await wallet.fetchWallet()).talons, 24);

      // 2: asking the quest again would say "claimed" and pay nothing, so the
      // owed talons are paid instead, without sending the answers twice.
      final result = (await controller.submit())!;
      expect(result.talonsEarned, 5);
      expect((await wallet.fetchWallet()).talons, 29);
      expect(
        (quests.submits.length, quests.claimCalls, wallet.earnCalls),
        (1, 1, 2),
      );
      expect(stateOf(container).submitFailed, isFalse);
    });

    test('no survey this week leaves nothing to answer', () async {
      final container = makeContainer(config: emptyConfig);
      final controller = await ready(container);
      final state = stateOf(container);
      expect((state.hasQuestions, state.isOpen), (false, false));
      controller.select('when', 0);
      expect(stateOf(container).answers, isEmpty);
      expect(await controller.submit(), isNull);
    });
  });

  group('narrow screens', () {
    // Long text at two widths, and the sample survey.
    for (final (size, survey) in [
      (const Size(360, 640), _longSurvey),
      (const Size(320, 568), _longSurvey),
      (const Size(360, 800), null),
    ]) {
      testWidgets('no overflow at ${size.width.round()} dp, '
          '${survey == null ? 'sample' : 'long'} text', (tester) async {
        final quests = _Quests(survey: survey, failSubmits: 1);
        await _openSurvey(tester, size: size, quests: quests);
        expect(tester.takeException(), isNull);

        // The last option of every question: the longest text, picked.
        final questions = (survey ?? weeklySurvey).questions;
        for (var q = 0; q < questions.length; q++) {
          await _pick(tester, q, questions[q].options.length - 1, survey);
          expect(tester.takeException(), isNull);
        }

        // The tallest foot (the failure notice), then the sheet.
        await _submit(tester);
        expect(find.text('Could not submit the survey'), findsOneWidget);
        await _submit(tester);
        expect(find.text('Thanks for sharing!'), findsOneWidget);
        expect(tester.takeException(), isNull);
      });
    }
  });

  // The test font is wide and square, so text wraps earlier than in the real
  // font; the designed sizes only hold with the real fonts loaded. Keep this
  // group last: loading fonts changes every test after it.
  group('the design, with the real fonts', () {
    setUpAll(() async {
      TestWidgetsFlutterBinding.ensureInitialized();
      await loadAppFonts();
    });

    testWidgets('lays out like frame 16 at 428 dp', (tester) async {
      await _openSurvey(tester, size: const Size(428, 1400));
      Rect rect(Finder finder) => tester.getRect(finder);

      // Reward strip: 48 tall under the 48 bar, 16 in from each side.
      final strip = rect(find.byType(SurveyRewardRow));
      expect((strip.top, strip.height), (48, 48));
      expect(rect(find.text('Available until Sunday')).left, 16);
      expect(rect(find.text('+5 talons')).right, 428 - 16);

      // Heading: 12 of page and 12 of its own; the line 4 under the title.
      final heading = rect(find.byType(SurveyIntro));
      expect((heading.top, heading.height), (108, 76));
      final title = rect(find.text("How's your study week going?"));
      expect((title.left, title.top, title.height), (24, 120, 28));
      final line = rect(find.text(SurveyIntro.intro));
      expect((line.left, line.top - title.bottom, line.height), (24, 4, 20));

      // The questions: 97, 243 and 332 tall (the design's 97, 241 and 330,
      // 2 more each for the selected radio card, INC-15); the first two end
      // in the 1 tall divider.
      final blocks = [
        for (var i = 0; i < 3; i++)
          rect(find.byType(SurveyQuestionBlock).at(i)),
      ];
      expect([for (final b in blocks) b.height], [97, 243, 332]);
      expect(blocks[0].top, heading.bottom);
      expect(blocks[1].top, blocks[0].bottom);
      expect(blocks[2].top, blocks[1].bottom);

      // Prompts: the number 4 in, the text 24 in, 12 under the block's top.
      for (var i = 0; i < 3; i++) {
        final marker = rect(find.text('${i + 1}.'));
        final prompt = rect(find.text(weeklySurvey.questions[i].prompt));
        expect((marker.left, prompt.left), (28, 48), reason: 'question $i');
        expect(prompt.top, blocks[i].top + 12, reason: 'question $i');
        expect(prompt.height, i == 2 ? 48 : 24, reason: 'question $i');
      }

      // Chips: 36 tall, 8 under the prompt, 16 apart, as wide as the design.
      final chips = [
        for (final label in weeklySurvey.questions[0].options)
          rect(_chip(label)),
      ];
      expect([for (final c in chips) c.height], [36, 36, 36]);
      expect(chips[0].left, 24);
      expect(chips[0].top, blocks[0].top + 12 + 24 + 8);
      for (var i = 1; i < 3; i++) {
        expect(chips[i].left - chips[i - 1].right, closeTo(16, 0.001));
        expect(chips[i].top, chips[0].top);
      }
      expect(chips[0].width, closeTo(122, 1));
      expect(chips[1].width, closeTo(102, 1));
      expect(chips[2].width, closeTo(98, 1));

      // Radio cards: 50 tall, 16 apart, 24 from each edge, 8 under a prompt.
      for (final (question, promptHeight) in [(1, 24.0), (2, 48.0)]) {
        final options = weeklySurvey.questions[question].options;
        final cards = [for (final label in options) rect(_option(label))];
        final top = blocks[question].top + 12 + promptHeight + 8;
        expect(cards.first.top, top, reason: 'question $question');
        for (var i = 0; i < cards.length; i++) {
          expect(cards[i].left, 24);
          expect(cards[i].right, 428 - 24);
          expect(cards[i].height, 50);
          if (i > 0) expect(cards[i].top - cards[i - 1].bottom, 16);
        }
      }

      // The card: 16 under the questions, 16 in, 84 tall.
      final card = rect(find.byType(SurveyInfoCard));
      expect((card.left, card.right, card.height), (28, 428 - 28, 84));
      expect(card.top - blocks[2].bottom, 16);
      expect(rect(find.text(SurveyInfoCard.title)).top, card.top + 16);
      expect(rect(find.text(SurveyInfoCard.body)).left, card.left + 16);

      // The foot: 96 tall, the large button 12 in and 24 from the edges, the
      // link centred 8 under it.
      final foot = rect(find.byType(SurveyFooter));
      expect(foot.top - card.bottom, 16);
      expect(foot.height, 96);
      final button = rect(_button(_submitLabel));
      expect((button.left, button.right, button.height), (24, 404, 48));
      expect(button.top - foot.top, 12);
      final skip = rect(find.text('Skip survey'));
      expect(skip.center.dx, 214);
      expect(skip.top - button.bottom, 8);
      expect(tester.takeException(), isNull);
    });

    testWidgets('wraps the long question at 360 and keeps its hanging number', (
      tester,
    ) async {
      await _openSurvey(tester, size: const Size(360, 1700));
      Rect rect(Finder finder) => tester.getRect(finder);

      // The prompt of question 3 wraps to two lines at 428 and at 360, both
      // starting at the text's edge, 24 in; the number sits 4 in.
      final prompt = rect(find.text(weeklySurvey.questions[2].prompt));
      expect(prompt.height, 48);
      expect(prompt.left, 48);
      expect(rect(find.text('3.')).left, 28);

      // The second chip row: "Late night" wraps under the first two.
      final first = rect(_chip(_label(0, 0)));
      final third = rect(_chip(_label(0, 2)));
      expect(third.left, first.left);
      expect(third.top - first.bottom, 16);

      // The button's label still fits one line.
      expect(tester.getSize(find.text(_submitLabel)).height, 20);
      expect(tester.takeException(), isNull);
    });

    testWidgets('uses the spec text styles and colours', (tester) async {
      await _openSurvey(tester);
      void expectStyle(String text, TextStyle base, Color color) {
        final style = tester.widget<Text>(find.text(text)).style!;
        expect(style.fontSize, base.fontSize, reason: text);
        expect(style.fontWeight, base.fontWeight, reason: text);
        expect(style.height, base.height, reason: text);
        expect(style.fontFamily, base.fontFamily, reason: text);
        expect(style.color, color, reason: text);
      }

      expectStyle(
        'Available until Sunday',
        AppTypography.c1,
        AppColors.grey500,
      );
      // The one Bold override of the frame.
      expectStyle('+5 talons', AppTypography.c1Bold, AppColors.talon500);
      expectStyle(
        "How's your study week going?",
        AppTypography.s1,
        AppColors.grey900,
      );
      expectStyle(SurveyIntro.intro, AppTypography.b3, AppColors.grey500);
      for (var i = 0; i < 3; i++) {
        expectStyle('${i + 1}.', AppTypography.b2, AppColors.grey900);
        expectStyle(
          weeklySurvey.questions[i].prompt,
          AppTypography.b2,
          AppColors.grey900,
        );
      }
      expectStyle(SurveyInfoCard.title, AppTypography.c1, AppColors.sage500);
      expectStyle(SurveyInfoCard.body, AppTypography.c3, AppColors.sage500);
      expectStyle('Skip survey', AppTypography.c1, AppColors.grey500);

      // The card is Sage-100 with a 16 radius.
      final box = tester.widget<DecoratedBox>(
        find
            .descendant(
              of: find.byType(SurveyInfoCard),
              matching: find.byType(DecoratedBox),
            )
            .first,
      );
      final decoration = box.decoration as BoxDecoration;
      expect(decoration.color, AppColors.sage100);
      expect(decoration.borderRadius, BorderRadius.circular(16));

      // A 1 Grey-200 line closes the first two questions, not the last.
      for (var i = 0; i < 3; i++) {
        final block = tester.widget<Container>(
          find
              .descendant(
                of: find.byType(SurveyQuestionBlock).at(i),
                matching: find.byType(Container),
              )
              .first,
        );
        final border = (block.decoration as BoxDecoration?)?.border;
        if (i == 2) {
          expect(border, isNull);
        } else {
          expect(
            border,
            const Border(bottom: BorderSide(color: AppColors.grey200)),
          );
        }
      }
    });

    testWidgets('semantics: each question as one label, the picks announced', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await _openSurvey(tester);
      for (var i = 0; i < 3; i++) {
        final prompt = weeklySurvey.questions[i].prompt;
        expect(find.bySemanticsLabel('${i + 1}. $prompt'), findsOneWidget);
      }
      expect(find.bySemanticsLabel('1.'), findsNothing); // not on its own
      expect(
        tester
            .getSemantics(find.text('Skip survey'))
            .getSemanticsData()
            .flagsCollection
            .isButton,
        isTrue,
      );

      await _pick(tester, 0, 1);
      await _pick(tester, 1, 0);
      Tristate chipSelected(String label) => tester
          .getSemantics(_chip(label))
          .getSemanticsData()
          .flagsCollection
          .isSelected;
      expect(chipSelected(_label(0, 1)), Tristate.isTrue);
      expect(chipSelected(_label(0, 0)), Tristate.isFalse);
      CheckedState optionChecked(String label) => tester
          .getSemantics(_option(label))
          .getSemanticsData()
          .flagsCollection
          .isChecked;
      expect(optionChecked(_label(1, 0)), CheckedState.isTrue);
      expect(optionChecked(_label(1, 1)), CheckedState.isFalse);
      handle.dispose();
    });
  });
}
