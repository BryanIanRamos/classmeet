import 'dart:async';

import 'package:classmeet/core/router/routes.dart';
import 'package:classmeet/core/theme/app_colors.dart';
import 'package:classmeet/core/theme/app_theme.dart';
import 'package:classmeet/core/theme/app_typography.dart';
import 'package:classmeet/core/widgets/buttons/app_button.dart';
import 'package:classmeet/core/widgets/feedback/app_loader.dart';
import 'package:classmeet/core/widgets/feedback/app_progress_bar.dart';
import 'package:classmeet/core/widgets/feedback/empty_state.dart';
import 'package:classmeet/core/widgets/feedback/error_state.dart';
import 'package:classmeet/core/widgets/selection/app_answer_option.dart';
import 'package:classmeet/data/fakes/fake_config.dart';
import 'package:classmeet/data/fakes/fake_quest_repository.dart';
import 'package:classmeet/data/fakes/fake_wallet_repository.dart';
import 'package:classmeet/data/fakes/samples/quest_samples.dart';
import 'package:classmeet/data/models/quest.dart';
import 'package:classmeet/data/models/quiz.dart';
import 'package:classmeet/data/models/wallet.dart';
import 'package:classmeet/data/providers.dart';
import 'package:classmeet/data/repositories/repository_exception.dart';
import 'package:classmeet/features/home/application/daily_quiz_controller.dart';
import 'package:classmeet/features/home/application/home_providers.dart';
import 'package:classmeet/features/home/presentation/screens/daily_quiz_screen.dart';
import 'package:classmeet/features/home/presentation/widgets/daily_quiz_counter.dart';
import 'package:classmeet/features/home/presentation/widgets/daily_quiz_feedback_card.dart';
import 'package:classmeet/features/home/presentation/widgets/daily_quiz_footer.dart';
import 'package:classmeet/features/home/presentation/widgets/daily_quiz_info_card.dart';
import 'package:classmeet/features/home/presentation/widgets/daily_quiz_question_view.dart';
import 'package:classmeet/features/home/presentation/widgets/daily_quiz_result_sheet.dart';
import 'package:classmeet/features/home/presentation/widgets/daily_quiz_reward_row.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';

import 'home_test_helpers.dart';

/// Today's quest with the reward still to earn. The sample quest is already
/// claimed (frame 14), so earning needs this one.
const _openQuest = Quest(
  id: dailyQuizQuestId,
  title: 'Daily General Knowledge Quiz',
  kind: QuestKind.daily,
  rewardTalons: 5,
  done: 5,
  total: 7,
);

/// The quest fake with the sample quiz, told to fail or to be slow, that
/// counts what it was asked.
class _Quests extends FakeQuestRepository {
  _Quests({
    super.quests,
    this.quiz,
    this.failFetches = 0,
    this.failFinishes = 0,
    this.failQuests = false,
    this.finishDelay = Duration.zero,
  }) : super(FakeConfig.instant);

  /// Served instead of the sample quiz.
  final List<Question>? quiz;

  /// How many of the first quiz loads and finishes fail.
  final int failFetches;
  final int failFinishes;
  final bool failQuests;
  final Duration finishDelay;

  int fetchCalls = 0;
  int finishCalls = 0;
  int claimCalls = 0;

  @override
  Future<List<Quest>> fetchQuests() async {
    if (failQuests) throw const RepositoryException('quests offline');
    return super.fetchQuests();
  }

  @override
  Future<List<Question>> fetchDailyQuiz() async {
    if (++fetchCalls <= failFetches) {
      throw const RepositoryException('quiz offline');
    }
    return quiz ?? await super.fetchDailyQuiz();
  }

  @override
  Future<Quest> finishDailyQuiz() async {
    final calls = ++finishCalls;
    if (finishDelay > Duration.zero) await Future<void>.delayed(finishDelay);
    if (calls <= failFinishes) throw const RepositoryException('offline');
    return super.finishDailyQuiz();
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

/// Two questions whose text is long everywhere, for the narrow screens. The
/// right option is B.
final _longQuiz = [
  for (var i = 1; i <= 2; i++)
    Question(
      id: 'long-$i',
      prompt:
          'Which of the following statements about the long and winding '
          'history of the Philippine archipelago, from the first settlers to '
          'the present day, is the most accurate one of them all?',
      category: 'Understanding the Self, Society and the Modern World',
      options: [
        for (final n in ['first', 'second', 'third', 'fourth'])
          'The $n answer, phrased in a deliberately long way so that it has '
              'to wrap over several lines on a small screen',
      ],
      correctIndex: 1,
      explanation:
          'The second answer is the right one because the explanation says '
          'so at some length, and it has to wrap over several lines too.',
    ),
];

const _idle = AppAnswerOptionState.idle;
const _picked = AppAnswerOptionState.selected;
const _correct = AppAnswerOptionState.correct;
const _wrong = AppAnswerOptionState.wrong;

/// The sample quiz's right options, question by question: A, A, B, C, D.
List<int> get _right => [for (final q in dailyQuizQuestions) q.correctIndex];

String _label(int question, int option, [List<Question>? quiz]) =>
    DailyQuizQuestionView.optionLabel(
      option,
      (quiz ?? dailyQuizQuestions)[question].options[option],
    );

Finder _option(String label) =>
    find.byWidgetPredicate((w) => w is AppAnswerOption && w.label == label);

AppAnswerOptionState _stateOf(WidgetTester tester, String label) =>
    tester.widget<AppAnswerOption>(_option(label)).state;

/// The four options' states of the [question]-th sample question.
List<AppAnswerOptionState> _states(WidgetTester tester, int question) => [
  for (var i = 0; i < 4; i++) _stateOf(tester, _label(question, i)),
];

Finder _button(String label) => find.widgetWithText(AppButton, label);

bool _enabled(WidgetTester tester, String label) =>
    tester.widget<AppButton>(_button(label)).onPressed != null;

AppProgressBar _bar(WidgetTester tester) =>
    tester.widget<AppProgressBar>(find.byType(AppProgressBar));

/// The wallet's talons, after any pending reload.
Future<int> _talons(WidgetTester tester) async =>
    (await container(tester).read(walletProvider.future)).talons;

Future<void> _tap(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

Future<void> _press(WidgetTester tester, String button) =>
    _tap(tester, _button(button));

/// Picks [option] of the [question]-th question and checks it.
Future<void> _answer(
  WidgetTester tester,
  int question,
  int option, {
  List<Question>? quiz,
}) async {
  await _tap(tester, _option(_label(question, option, quiz)));
  await _press(tester, 'Check answer');
}

/// Plays the sample quiz with one pick per question and stops after the last
/// check, where the button reads "Finish quiz".
Future<void> _playToTheEnd(WidgetTester tester, List<int> picks) async {
  for (var i = 0; i < picks.length; i++) {
    await _answer(tester, i, picks[i]);
    if (i < picks.length - 1) await _press(tester, 'Next question');
  }
}

/// The quiz opened over Home, as the app does.
Future<void> _openQuiz(
  WidgetTester tester, {
  FakeConfig config = FakeConfig.instant,
  Size size = const Size(428, 926),
  _Quests? quests,
}) => pumpHome(
  tester,
  config: config,
  size: size,
  location: Routes.dailyQuiz,
  overrides: [
    if (quests != null) questRepositoryProvider.overrideWithValue(quests),
  ],
);

/// The quiz pushed from a plain button, without Home or the router. The
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
                  builder: (_) => const DailyQuizScreen(),
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
  group('the question', () {
    testWidgets('shows the first question as designed', (tester) async {
      await _openQuiz(tester);
      final first = dailyQuizQuestions.first;
      expect(location(tester), Routes.dailyQuiz);
      for (final text in [
        'Daily General Knowledge Quiz',
        'Resets at midnight',
        '+5 talons',
        'Question 1 of 5',
        first.category!,
        first.prompt,
        'Please select the correct answer',
        'A. June 12', // the letters come from the screen
        'B. July 4',
        'C. August 21',
        'D. November 30',
        "About today's quiz",
        DailyQuizInfoCard.body,
        'Check answer',
        DailyQuizFooter.note,
      ]) {
        expect(find.text(text), findsOneWidget, reason: text);
      }
      expect(find.byType(DailyQuizFeedbackCard), findsNothing);
      expect(_states(tester, 0), everyElement(_idle));
      expect(_enabled(tester, 'Check answer'), isFalse);

      // Five separate 6-tall pills, one filled on the first question.
      final bar = _bar(tester);
      expect(bar.segments, 5);
      expect((bar.segmentGap, bar.height), (6, 6));
      expect(bar.trackColor, AppColors.grey300);
      expect(bar.filledSegments, 1);
    });

    testWidgets('Check answer needs a pick, and the pick can change', (
      tester,
    ) async {
      await _openQuiz(tester);
      expect(_enabled(tester, 'Check answer'), isFalse);

      await _tap(tester, _option(_label(0, 0)));
      expect(_enabled(tester, 'Check answer'), isTrue);
      await _tap(tester, _option(_label(0, 2)));
      expect(_states(tester, 0), [_idle, _idle, _picked, _idle]);
      expect(_enabled(tester, 'Check answer'), isTrue);
    });
  });

  group('checking an answer', () {
    testWidgets('a right answer turns Sprout and says Nice work!', (
      tester,
    ) async {
      await _openQuiz(tester);
      await _answer(tester, 0, 0);

      expect(_states(tester, 0), [_correct, _idle, _idle, _idle]);
      final card = find.byType(DailyQuizFeedbackCard);
      expect(tester.widget<DailyQuizFeedbackCard>(card).correct, isTrue);
      expect(find.text('Nice work!'), findsOneWidget);
      expect(find.text(dailyQuizQuestions[0].explanation!), findsOneWidget);
      // The feedback takes the info card's place; the question stays.
      expect(find.text("About today's quiz"), findsNothing);
      expect(find.text('Question 1 of 5'), findsOneWidget);
      expect(find.text('Check answer'), findsNothing);
      expect(find.text('Next question'), findsOneWidget);
      // Locked: the options take no more taps.
      for (var i = 0; i < 4; i++) {
        final option = tester.widget<AppAnswerOption>(_option(_label(0, i)));
        expect(option.onTap, isNull);
      }
    });

    testWidgets('a wrong pick turns Talon; the card names the right one', (
      tester,
    ) async {
      await _openQuiz(tester);
      await _answer(tester, 0, 1);

      expect(_states(tester, 0), [_correct, _wrong, _idle, _idle]);
      final card = find.byType(DailyQuizFeedbackCard);
      expect(tester.widget<DailyQuizFeedbackCard>(card).correct, isFalse);
      expect(
        find.text('Correct answer: ${dailyQuizQuestions[0].options[0]}'),
        findsOneWidget,
      );
      expect(find.text('Nice work!'), findsNothing);
      expect(find.text(dailyQuizQuestions[0].explanation!), findsOneWidget);

      await tester.tap(_option(_label(0, 2)));
      await tester.pumpAndSettle();
      expect(_stateOf(tester, _label(0, 2)), _idle);
      expect(_stateOf(tester, _label(0, 1)), _wrong);
    });

    testWidgets('Next question moves on; the bar fills a pill a question', (
      tester,
    ) async {
      await _openQuiz(tester);
      for (var i = 0; i < 5; i++) {
        expect(find.text('Question ${i + 1} of 5'), findsOneWidget);
        expect(find.text(dailyQuizQuestions[i].prompt), findsOneWidget);
        // A new question starts clean: nothing picked, the info card back.
        expect(_states(tester, i), everyElement(_idle));
        expect(_enabled(tester, 'Check answer'), isFalse);
        expect(find.text("About today's quiz"), findsOneWidget);
        // The first i + 1 pills are filled Sage-500, the rest Grey-300.
        expect(_bar(tester).filledSegments, i + 1);
        for (var pill = 0; pill < 5; pill++) {
          final box = tester.widget<DecoratedBox>(
            find.byKey(ValueKey('progress-segment-$pill')),
          );
          expect(
            (box.decoration as BoxDecoration).color,
            pill <= i ? AppColors.sage500 : AppColors.grey300,
          );
        }

        await _answer(tester, i, _right[i]);
        if (i < 4) await _press(tester, 'Next question');
      }
      // The last question finishes the quiz instead of moving on.
      expect(find.text('Finish quiz'), findsOneWidget);
      expect(find.text('Next question'), findsNothing);
    });
  });

  group('finishing', () {
    testWidgets('already rewarded today: the sheet says so, nothing is paid', (
      tester,
    ) async {
      await _openQuiz(tester);
      expect(await _talons(tester), 24);

      await _playToTheEnd(tester, [0, 1, 1, 2, 0]); // 3 of 5 right
      await _press(tester, 'Finish quiz');

      expect(find.text('Quiz complete!'), findsOneWidget);
      expect(find.text('You got 3 of 5 right.'), findsOneWidget);
      expect(find.text(DailyQuizResultSheet.alreadyEarned), findsOneWidget);
      expect(find.textContaining('talons earned'), findsNothing);
      expect(await _talons(tester), 24);
      final quests = await container(tester).read(questsProvider.future);
      expect(
        (quests.first.status, quests.first.done),
        (QuestStatus.claimed, 6),
      );

      await _press(tester, 'Done');
      expect(location(tester), Routes.home);
      expect(find.text('24'), findsOneWidget);
    });

    testWidgets('with the reward open: pays it once, whatever the score', (
      tester,
    ) async {
      final quests = _Quests(quests: [_openQuest]);
      await _openQuiz(tester, quests: quests);
      // The open quest has no reset time, so the strip shows only the reward.
      expect(find.text('+5 talons'), findsOneWidget);
      expect(find.text('Resets at midnight'), findsNothing);

      await _playToTheEnd(tester, [1, 1, 0, 0, 0]); // every pick wrong
      await _press(tester, 'Finish quiz');

      expect(find.text('You got 0 of 5 right.'), findsOneWidget);
      expect(find.text('+5 talons earned'), findsOneWidget);
      expect(find.text(DailyQuizResultSheet.alreadyEarned), findsNothing);
      expect(await _talons(tester), 29);
      final quest = (await container(
        tester,
      ).read(questsProvider.future)).single;
      expect((quest.status, quest.done), (QuestStatus.claimed, 6));

      await _press(tester, 'Done');
      expect(location(tester), Routes.home);
      expect(find.text('29'), findsOneWidget); // Home shows the new balance

      // The same day again: finished, and nothing more is paid.
      unawaited(router(tester).push(Routes.dailyQuiz));
      await tester.pumpAndSettle();
      await _playToTheEnd(tester, _right);
      await _press(tester, 'Finish quiz');
      expect(find.text(DailyQuizResultSheet.alreadyEarned), findsOneWidget);
      expect(await _talons(tester), 29);
      expect((quests.finishCalls, quests.claimCalls), (2, 1));
    });

    testWidgets('the sheet ends with Done or the back key only', (
      tester,
    ) async {
      await _openQuiz(tester);
      await _playToTheEnd(tester, _right);
      await _press(tester, 'Finish quiz');

      await tester.tapAt(const Offset(20, 20)); // the scrim does nothing
      await tester.pumpAndSettle();
      expect(find.text('Quiz complete!'), findsOneWidget);
      expect(location(tester), Routes.dailyQuiz);

      await tester.binding.handlePopRoute(); // the back key leaves the quiz
      await tester.pumpAndSettle();
      expect(find.text('Quiz complete!'), findsNothing);
      expect(location(tester), Routes.home);
    });

    testWidgets('a failed save shows a notice and can be tried again', (
      tester,
    ) async {
      final quests = _Quests(
        quests: [_openQuest],
        failFinishes: 1,
        finishDelay: const Duration(seconds: 1),
      );
      await _openQuiz(tester, quests: quests);
      await _playToTheEnd(tester, _right);

      /// Taps Finish quiz and lets the 1 s save answer.
      Future<void> finish() async {
        await tester.tap(_button('Finish quiz'));
        await tester.pump();
        if (quests.finishCalls == 1) {
          expect(_enabled(tester, 'Finish quiz'), isFalse); // saving
        }
        await tester.pump(const Duration(seconds: 2));
        await tester.pumpAndSettle();
      }

      await finish(); // fails
      expect(find.text('Could not finish the quiz'), findsOneWidget);
      expect(find.text('Quiz complete!'), findsNothing);
      expect(_enabled(tester, 'Finish quiz'), isTrue);
      expect(await _talons(tester), 24);

      await finish();
      expect(find.text('Could not finish the quiz'), findsNothing);
      expect(find.text('+5 talons earned'), findsOneWidget);
      expect((quests.finishCalls, await _talons(tester)), (2, 29));
    });

    testWidgets('leaving while the quiz is saved does not throw, and the '
        'talons still arrive', (tester) async {
      final quests = _Quests(
        quests: [_openQuest],
        finishDelay: const Duration(seconds: 2),
      );
      await _openPlain(tester, [
        fakeConfigProvider.overrideWithValue(FakeConfig.instant),
        questRepositoryProvider.overrideWithValue(quests),
      ]);
      await tester.pumpAndSettle();
      await _playToTheEnd(tester, _right);

      await tester.tap(_button('Finish quiz'));
      await tester.pump(); // the 2 s save starts
      await tester.tap(find.bySemanticsLabel('Back'));
      await tester.pump();
      await tester.pump(const Duration(seconds: 1)); // route out
      await tester.pump();
      expect(find.byType(DailyQuizScreen), findsNothing);

      await tester.pump(const Duration(seconds: 2)); // the late answer lands
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.text('Quiz complete!'), findsNothing);
      // Claimed and paid together, although nobody was there to see it.
      final scope = ProviderScope.containerOf(
        tester.element(find.text('open')),
      );
      expect(quests.claimCalls, 1);
      expect((await scope.read(walletProvider.future)).talons, 29);
    });
  });

  group('around the question', () {
    testWidgets('back leaves and forgets the progress, a link leads Home', (
      tester,
    ) async {
      await _openQuiz(tester);
      await _answer(tester, 0, 0);
      await _press(tester, 'Next question');
      expect(find.text('Question 2 of 5'), findsOneWidget);

      await tester.tap(find.bySemanticsLabel('Back'));
      await tester.pumpAndSettle();
      expect(location(tester), Routes.home);
      expect(find.byType(DailyQuizScreen), findsNothing);

      // Opened again, here by a link: it starts over, and back leads Home.
      router(tester).go(Routes.dailyQuiz);
      await tester.pumpAndSettle();
      expect(find.text('Question 1 of 5'), findsOneWidget);
      await tester.tap(find.bySemanticsLabel('Back'));
      await tester.pumpAndSettle();
      expect(location(tester), Routes.home);
    });

    testWidgets('the reward strip hides while the quests are unavailable', (
      tester,
    ) async {
      await _openQuiz(tester, quests: _Quests(failQuests: true));
      expect(find.text('Question 1 of 5'), findsOneWidget);
      expect(find.byType(DailyQuizRewardRow), findsNothing);
    });

    testWidgets('loading shows a loader, then the question', (tester) async {
      await _openPlain(tester, [
        fakeConfigProvider.overrideWithValue(
          const FakeConfig(latency: Duration(seconds: 1)),
        ),
      ]);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
      expect(find.byType(AppLoader), findsOneWidget);
      expect(find.text('Daily General Knowledge Quiz'), findsOneWidget);
      expect(find.text('Check answer'), findsNothing);

      await tester.pump(const Duration(seconds: 2));
      await tester.pumpAndSettle();
      expect(find.byType(AppLoader), findsNothing);
      expect(find.text('Question 1 of 5'), findsOneWidget);
    });

    testWidgets('empty scenario: no quiz today', (tester) async {
      await _openQuiz(tester, config: emptyConfig);
      expect(find.byType(EmptyState), findsOneWidget);
      expect(find.text('No quiz today'), findsOneWidget);
      expect(
        find.text('Check back tomorrow for a new set of questions.'),
        findsOneWidget,
      );
      expect(find.text('Check answer'), findsNothing);
      expect(find.byType(DailyQuizRewardRow), findsNothing); // no quests either
      expect(tester.takeException(), isNull);
    });

    testWidgets('error scenario: a retryable error', (tester) async {
      await _openQuiz(tester, config: errorConfig);
      expect(find.byType(ErrorState), findsOneWidget);
      expect(find.text('Check answer'), findsNothing);
      expect(find.byType(DailyQuizRewardRow), findsNothing);

      await tester.tap(find.text('Try again'));
      await tester.pumpAndSettle();
      expect(find.byType(ErrorState), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('retry loads the quiz again', (tester) async {
      final quests = _Quests(failFetches: 1);
      await _openQuiz(tester, quests: quests);
      expect(find.byType(ErrorState), findsOneWidget);

      await tester.tap(find.text('Try again'));
      await tester.pumpAndSettle();
      expect(quests.fetchCalls, 2);
      expect(find.byType(ErrorState), findsNothing);
      expect(find.text('Question 1 of 5'), findsOneWidget);
    });
  });

  group('narrow screens', () {
    // Long text (the right option is B) at two widths, and the sample quiz.
    for (final (size, quiz) in [
      (const Size(360, 640), _longQuiz),
      (const Size(320, 568), _longQuiz),
      (const Size(360, 800), null),
    ]) {
      testWidgets('no overflow at ${size.width.round()} dp, '
          '${quiz == null ? 'sample' : 'long'} text', (tester) async {
        final quests = _Quests(
          quests: [_openQuest],
          quiz: quiz,
          failFinishes: 1,
        );
        await _openQuiz(tester, size: size, quests: quests);
        expect(tester.takeException(), isNull);

        // Picks A, B, A, ...: a mix of right and wrong feedback.
        final count = (quiz ?? dailyQuizQuestions).length;
        for (var i = 0; i < count; i++) {
          await _answer(tester, i, i.isEven ? 0 : 1, quiz: quiz);
          expect(tester.takeException(), isNull);
          if (i < count - 1) await _press(tester, 'Next question');
        }

        // The tallest footer (the failed-save notice), then the sheet.
        await _press(tester, 'Finish quiz');
        expect(find.text('Could not finish the quiz'), findsOneWidget);
        await _press(tester, 'Finish quiz');
        expect(find.text('Quiz complete!'), findsOneWidget);
        expect(tester.takeException(), isNull);
      });
    }

    testWidgets('checking scrolls the feedback into view; the next question '
        'starts at the top', (tester) async {
      await _openQuiz(
        tester,
        size: const Size(360, 640),
        quests: _Quests(quiz: _longQuiz),
      );
      ScrollPosition position() =>
          tester.state<ScrollableState>(find.byType(Scrollable).first).position;

      await _answer(tester, 0, 1, quiz: _longQuiz);
      // The card sits above the pinned footer, on the screen.
      final footerTop = tester.getTopLeft(find.byType(DailyQuizFooter)).dy;
      final card = tester.getRect(find.byType(DailyQuizFeedbackCard));
      expect(card.bottom, lessThanOrEqualTo(footerTop));
      expect(card.top, greaterThanOrEqualTo(0));
      expect(position().pixels, greaterThan(0));

      await _press(tester, 'Next question');
      expect(position().pixels, 0);
    });
  });

  group('the design', () {
    testWidgets('lays out like frame 15 at 428 dp', (tester) async {
      await _openQuiz(tester);
      Rect rect(Finder finder) => tester.getRect(finder);

      // Reward strip: 48 tall under the 48 bar, 16 in from each side.
      final strip = rect(find.byType(DailyQuizRewardRow));
      expect((strip.top, strip.height), (48, 48));
      expect(rect(find.text('Resets at midnight')).left, 16);
      expect(rect(find.text('+5 talons')).right, 428 - 16);

      // Counter: 64 tall; the bar from 28 to 400, five 6-tall pills 6 apart.
      expect(rect(find.byType(DailyQuizCounter)).height, 64);
      final bar = rect(find.byType(AppProgressBar));
      expect((bar.left, bar.right, bar.height), (28, 400, 6));
      final pills = [
        for (var i = 0; i < 5; i++)
          rect(find.byKey(ValueKey('progress-segment-$i'))),
      ];
      for (var i = 0; i < 5; i++) {
        expect(pills[i].height, 6);
        expect(pills[i].width, closeTo((372 - 4 * 6) / 5, 1e-6));
        if (i > 0) expect(pills[i].left - pills[i - 1].right, 6);
      }

      // The question and the hint start 24 in; the options 28, 16 apart.
      expect(rect(find.text(dailyQuizQuestions.first.prompt)).left, 24);
      expect(rect(find.text('Please select the correct answer')).left, 24);
      final a = rect(_option(_label(0, 0)));
      final b = rect(_option(_label(0, 1)));
      final d = rect(_option(_label(0, 3)));
      expect((a.left, a.right), (28, 400));
      expect(b.top - a.bottom, 16);

      // The info card: 24 under the options, 16 inside.
      final info = rect(find.byType(DailyQuizInfoCard));
      expect((info.left, info.right), (28, 400));
      expect(info.top - d.bottom, 24);
      expect(rect(find.text("About today's quiz")).top, info.top + 16);
      expect(rect(find.text(DailyQuizInfoCard.body)).left, info.left + 16);

      // The button: large, 24 from each edge; the note centred 8 under it.
      final button = rect(_button('Check answer'));
      expect((button.left, button.right, button.height), (24, 404, 48));
      final note = rect(find.text(DailyQuizFooter.note));
      expect(note.center.dx, 214);
      expect(note.top - button.bottom, 8);
      expect(note.bottom, 926 - 24);
    });

    testWidgets('uses the spec text styles and colours', (tester) async {
      await _openQuiz(tester);
      void expectStyle(String text, TextStyle base, Color color) {
        final style = tester.widget<Text>(find.text(text)).style!;
        expect(style.fontSize, base.fontSize, reason: text);
        expect(style.fontWeight, base.fontWeight, reason: text);
        expect(style.height, base.height, reason: text);
        expect(style.fontFamily, base.fontFamily, reason: text);
        expect(style.color, color, reason: text);
      }

      final first = dailyQuizQuestions.first;
      expectStyle('Resets at midnight', AppTypography.c1, AppColors.grey500);
      // The one Bold override of the frame.
      expectStyle('+5 talons', AppTypography.c1Bold, AppColors.talon500);
      expectStyle('Question 1 of 5', AppTypography.c1, AppColors.grey500);
      expectStyle(first.category!, AppTypography.c1, AppColors.sage500);
      expectStyle(first.prompt, AppTypography.s1, AppColors.grey900);
      expectStyle(
        'Please select the correct answer',
        AppTypography.b3,
        AppColors.grey500,
      );
      expectStyle("About today's quiz", AppTypography.c1, AppColors.sage500);
      expectStyle(DailyQuizInfoCard.body, AppTypography.c3, AppColors.sage500);
      expectStyle(DailyQuizFooter.note, AppTypography.c1, AppColors.grey500);

      // The info card is Sage-100 with a 16 radius.
      final box = tester.widget<DecoratedBox>(
        find
            .descendant(
              of: find.byType(DailyQuizInfoCard),
              matching: find.byType(DecoratedBox),
            )
            .first,
      );
      final decoration = box.decoration as BoxDecoration;
      expect(decoration.color, AppColors.sage100);
      expect(decoration.borderRadius, BorderRadius.circular(16));
    });

    testWidgets('semantics: the counter once, the feedback live, the options '
        'say how it went', (tester) async {
      final handle = tester.ensureSemantics();
      await _openQuiz(tester);
      expect(find.bySemanticsLabel('Question 1 of 5'), findsOneWidget);

      await _answer(tester, 0, 1);
      final feedback = tester
          .getSemantics(find.byType(DailyQuizFeedbackCard))
          .getSemanticsData();
      expect(feedback.flagsCollection.isLiveRegion, isTrue);
      expect(feedback.label, contains('Correct answer:'));

      String labelOf(int option) => tester
          .getSemantics(_option(_label(0, option)))
          .getSemanticsData()
          .label;
      expect(labelOf(0), 'A. June 12, correct answer');
      expect(labelOf(1), 'B. July 4, your answer, incorrect');
      expect(labelOf(2), 'C. August 21');
      handle.dispose();
    });
  });

  group('DailyQuizController', () {
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
        dailyQuizControllerProvider,
        (_, _) {},
      );
      addTearDown(subscription.close);
      return container;
    }

    DailyQuizState stateOf(ProviderContainer container) =>
        container.read(dailyQuizControllerProvider).requireValue;

    /// Plays the sample quiz with [picks]; stops after the last check.
    Future<DailyQuizController> playAll(
      ProviderContainer container,
      List<int> picks,
    ) async {
      await container.read(dailyQuizControllerProvider.future);
      final controller = container.read(dailyQuizControllerProvider.notifier);
      for (var i = 0; i < picks.length; i++) {
        controller
          ..select(picks[i])
          ..check();
        if (i < picks.length - 1) controller.next();
      }
      return controller;
    }

    test('select, check and next only work in order', () async {
      final container = makeContainer();
      final start = await container.read(dailyQuizControllerProvider.future);
      expect(start.questions, hasLength(5));
      expect((start.index, start.selected, start.checked), (0, null, false));
      final controller = container.read(dailyQuizControllerProvider.notifier);

      // Out of order or out of range: ignored.
      controller
        ..check()
        ..next()
        ..select(-1)
        ..select(4);
      expect(stateOf(container).selected, isNull);
      controller
        ..select(2)
        ..next();
      expect((stateOf(container).selected, stateOf(container).index), (2, 0));

      // Checked: locked, and a second check counts nothing.
      controller
        ..check() // wrong
        ..select(0)
        ..check();
      expect(stateOf(container).selected, 2);
      expect(stateOf(container).correctCount, 0);
      controller.next();
      expect(
        (stateOf(container).index, stateOf(container).selected),
        (1, null),
      );

      controller
        ..select(0) // right
        ..check()
        ..check();
      expect(stateOf(container).correctCount, 1);
    });

    test('finish pays the reward once and reports the score', () async {
      final quests = _Quests(quests: [_openQuest]);
      final container = makeContainer(quests: quests);
      await container.read(dailyQuizControllerProvider.future);
      final controller = container.read(dailyQuizControllerProvider.notifier);
      expect(await controller.finish(), isNull); // nothing answered yet
      controller
        ..select(0) // right
        ..check();
      expect(await controller.finish(), isNull); // not the last question
      expect(quests.finishCalls, 0);

      controller.next();
      await playAll(container, [1, 1, 2, 0]); // wrong, right, right, wrong
      final result = (await controller.finish())!;
      expect((result.correct, result.total, result.talonsEarned), (3, 5, 5));
      expect(stateOf(container).result, same(result));
      expect((await container.read(walletProvider.future)).talons, 29);
      expect((await quests.fetchQuests()).single.status, QuestStatus.claimed);
      expect(await controller.finish(), isNull); // finished

      // A fresh run the same day: nothing more is paid.
      container.invalidate(dailyQuizControllerProvider);
      final again = (await (await playAll(container, _right)).finish())!;
      expect((again.correct, again.talonsEarned), (5, 0));
      expect((await container.read(walletProvider.future)).talons, 29);
      expect(quests.claimCalls, 1);
    });

    test('a quest completed earlier but never claimed is paid now', () async {
      final quests = _Quests(
        quests: [_openQuest.copyWith(status: QuestStatus.completed)],
      );
      final container = makeContainer(quests: quests);
      final result = (await (await playAll(container, _right)).finish())!;
      expect(result.talonsEarned, 5);
      expect((await container.read(walletProvider.future)).talons, 29);
    });

    test(
      'a failed finish can be retried; unpaid talons are paid next',
      () async {
        final quests = _Quests(quests: [_openQuest], failFinishes: 1);
        final wallet = _FlakyWallet();
        final container = makeContainer(quests: quests, wallet: wallet);
        final controller = await playAll(container, _right);

        // 1: recording fails. 2: the quest is claimed, adding the talons fails.
        expect(await controller.finish(), isNull);
        final failed = stateOf(container);
        expect(
          (failed.finishFailed, failed.finishing, failed.canFinish),
          (true, false, true),
        );
        expect(await controller.finish(), isNull);
        expect((await quests.fetchQuests()).single.status, QuestStatus.claimed);
        expect((await wallet.fetchWallet()).talons, 24);

        // 3: asking the quest again would say "claimed" and pay nothing, so the
        // owed talons are paid instead.
        final result = (await controller.finish())!;
        expect(result.talonsEarned, 5);
        expect((await wallet.fetchWallet()).talons, 29);
        expect(
          (quests.finishCalls, quests.claimCalls, wallet.earnCalls),
          (2, 1, 2),
        );
        expect(stateOf(container).finishFailed, isFalse);
      },
    );

    test('a finish already running ignores a second call', () async {
      final quests = _Quests(
        quests: [_openQuest],
        finishDelay: const Duration(milliseconds: 20),
      );
      final container = makeContainer(quests: quests);
      final controller = await playAll(container, _right);

      final first = controller.finish();
      expect(stateOf(container).finishing, isTrue);
      expect(await controller.finish(), isNull);
      expect((await first)!.talonsEarned, 5);
      expect((quests.finishCalls, quests.claimCalls), (1, 1));
    });

    test(
      'no quiz, or one that failed to load, leaves nothing to play',
      () async {
        final empty = makeContainer(config: emptyConfig);
        final none = await empty.read(dailyQuizControllerProvider.future);
        expect((none.hasQuestions, none.canSelect), (false, false));
        final controller = empty.read(dailyQuizControllerProvider.notifier);
        controller
          ..select(0)
          ..check()
          ..next();
        expect(await controller.finish(), isNull);

        final failed = makeContainer(quests: _Quests(failFetches: 1));
        await expectLater(
          failed.read(dailyQuizControllerProvider.future),
          throwsA(isA<RepositoryException>()),
        );
        failed.read(dailyQuizControllerProvider.notifier)
          ..select(0)
          ..check()
          ..next();
        failed.invalidate(dailyQuizControllerProvider);
        final loaded = await failed.read(dailyQuizControllerProvider.future);
        expect(loaded.questions, hasLength(5));
      },
    );
  });
}
