/// Talon credits (frame 14): copy and tokens, the button of each quest status,
/// navigation, claiming (double taps, failures, leaving mid-claim), the
/// loading, empty and error states, and the layout. The last group loads the
/// real fonts for the designed sizes; the others run in the wide test font,
/// which wraps text earlier and so is the stricter overflow check.
library;

import 'dart:async';

import 'package:classmeet/core/assets/app_icons.dart';
import 'package:classmeet/core/router/routes.dart';
import 'package:classmeet/core/theme/app_colors.dart';
import 'package:classmeet/core/theme/app_semantic_colors.dart';
import 'package:classmeet/core/theme/app_theme.dart';
import 'package:classmeet/core/widgets/buttons/app_button.dart';
import 'package:classmeet/core/widgets/display/illustrated_card.dart';
import 'package:classmeet/core/widgets/display/section_header.dart';
import 'package:classmeet/core/widgets/feedback/app_alert.dart';
import 'package:classmeet/core/widgets/feedback/app_loader.dart';
import 'package:classmeet/core/widgets/feedback/coming_soon_screen.dart';
import 'package:classmeet/core/widgets/feedback/empty_state.dart';
import 'package:classmeet/core/widgets/feedback/error_state.dart';
import 'package:classmeet/core/widgets/navigation/app_navbar_top.dart';
import 'package:classmeet/data/fakes/fake_config.dart';
import 'package:classmeet/data/fakes/fake_quest_repository.dart';
import 'package:classmeet/data/fakes/fake_wallet_repository.dart';
import 'package:classmeet/data/fakes/samples/quest_samples.dart';
import 'package:classmeet/data/models/quest.dart';
import 'package:classmeet/data/models/wallet.dart';
import 'package:classmeet/data/providers.dart';
import 'package:classmeet/data/repositories/repository_exception.dart';
import 'package:classmeet/features/home/application/home_providers.dart';
import 'package:classmeet/features/home/application/talon_credits_controller.dart';
import 'package:classmeet/features/home/presentation/screens/talon_credits_screen.dart';
import 'package:classmeet/features/home/presentation/widgets/quest_card.dart';
import 'package:classmeet/features/home/presentation/widgets/talon_balance_card.dart';
import 'package:classmeet/features/home/presentation/widgets/talon_chip.dart';
import 'package:classmeet/features/home/presentation/widgets/talon_progress_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/app_fonts.dart';
import 'home_test_helpers.dart';

/// Tall enough to build the whole page at once.
const _tall = Size(428, 1300);
const _slow = FakeConfig(latency: Duration(seconds: 2));
const _surveyAnswers = {'when': 0, 'challenge': 0, 'hours': 0};

// The three quests of the design, with the status set per test.

Quest _daily({
  QuestStatus status = QuestStatus.claimed,
  bool resets = true,
  int done = 6,
}) => Quest(
  id: dailyQuizQuestId,
  title: 'Daily General Knowledge Quiz',
  kind: QuestKind.daily,
  rewardTalons: 5,
  done: done,
  total: 7,
  status: status,
  resetsAt: resets ? DateTime(2026, 11, 25) : null,
);

Quest _milestone({QuestStatus status = QuestStatus.locked, int reward = 5}) =>
    Quest(
      id: streakQuestId,
      title: 'Study Streak Milestone I',
      kind: QuestKind.milestone,
      rewardTalons: reward,
      done: 3,
      total: 7,
      status: status,
    );

Quest _survey({
  QuestStatus status = QuestStatus.available,
  int? minutes = 1,
  DateTime? until,
}) => Quest(
  id: surveyQuestId,
  title: 'Weekly Survey',
  kind: QuestKind.survey,
  rewardTalons: 5,
  total: 1,
  status: status,
  availableUntil: until,
  durationMinutes: minutes,
);

/// The survey closes at the end of Sunday 2026-11-29.
final _sunday = DateTime(2026, 11, 29, 23, 59, 59);

/// All three quests in [status].
List<Quest> _allIn(QuestStatus status) => [
  _daily(status: status),
  _milestone(status: status),
  _survey(status: status, until: _sunday),
];

/// A quest repository holding exactly [quests].
Override questsOf(
  List<Quest> quests, {
  FakeConfig config = FakeConfig.instant,
}) => questRepositoryProvider.overrideWithValue(
  FakeQuestRepository(config, clock: () => evening, quests: quests),
);

/// A quest repository whose claim waits for [gate], fails for the quests in
/// [failing], and counts the claims it gets.
class _ClaimProbe extends FakeQuestRepository {
  _ClaimProbe(
    super.config,
    List<Quest> quests, {
    Completer<void>? gate,
    this.failing = const {},
  }) : gate = gate ?? (Completer<void>()..complete()),
       super(clock: () => evening, quests: quests);

  final Completer<void> gate;
  final Set<String> failing;
  int claims = 0;

  @override
  Future<Quest> claimQuest(String questId) async {
    claims++;
    await gate.future;
    if (failing.contains(questId)) {
      throw const RepositoryException('claim failed');
    }
    return super.claimQuest(questId);
  }
}

/// A wallet whose credit fails.
class _FailingEarn extends FakeWalletRepository {
  _FailingEarn(super.config);

  @override
  Future<Wallet> earn({int talons = 0, int studyPoints = 0, int xp = 0}) =>
      Future.error(const RepositoryException('earn failed'));
}

/// The screen alone in a [MaterialApp] (no router), for the states and the
/// layout. [quests] replaces the sample quests. Pass `settle: false` for a
/// state with a running loader.
Future<void> pumpTalon(
  WidgetTester tester, {
  FakeConfig config = FakeConfig.instant,
  Size size = _tall,
  List<Quest>? quests,
  List<Override> overrides = const [],
  double textScale = 1,
  bool settle = true,
}) async {
  await tester.binding.setSurfaceSize(size);
  addTearDown(() => tester.binding.setSurfaceSize(null));
  await tester.pumpWidget(const SizedBox.shrink()); // a fresh scope each time
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        fakeConfigProvider.overrideWithValue(config),
        if (quests != null) questsOf(quests, config: config),
        ...overrides,
      ],
      retry: (_, _) => null,
      child: MaterialApp(
        theme: AppTheme.light,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: TextScaler.linear(textScale)),
          child: child!,
        ),
        home: const TalonCreditsScreen(),
      ),
    ),
  );
  if (settle) {
    await tester.pumpAndSettle();
  } else {
    await tester.pump();
  }
}

Finder card(String questId) =>
    find.byWidgetPredicate((w) => w is QuestCard && w.quest.id == questId);

Finder inCard(String questId, Finder matching) =>
    find.descendant(of: card(questId), matching: matching);

AppButton buttonIn(WidgetTester tester, String questId) =>
    tester.widget<AppButton>(inCard(questId, find.byType(AppButton)));

AppButton buttonLabelled(WidgetTester tester, String label) =>
    tester.widget<AppButton>(find.widgetWithText(AppButton, label));

IllustratedCard shellOf(WidgetTester tester, Finder owner) =>
    tester.widget<IllustratedCard>(
      find.descendant(of: owner, matching: find.byType(IllustratedCard)),
    );

TextStyle styleOf(WidgetTester tester, String text) =>
    tester.widget<Text>(find.text(text)).style!;

Future<int> walletTalons(WidgetTester tester) async => (await container(
  tester,
).read(walletRepositoryProvider).fetchWallet()).talons;

/// Finishes the survey in the repository and reloads the quest list, as the
/// survey screen does.
Future<void> completeSurvey(WidgetTester tester) async {
  final c = container(tester);
  await c
      .read(questRepositoryProvider)
      .submitSurvey(weeklySurveyId, _surveyAnswers);
  c.invalidate(questsProvider);
  await tester.pumpAndSettle();
}

void main() {
  group('default data', () {
    testWidgets('copy: the balance card and the three quests', (tester) async {
      await pumpHome(tester, location: Routes.talonCredits, size: _tall);
      expect(find.byType(TalonCreditsScreen), findsOneWidget);
      for (final text in [
        'Talon credits',
        // The balance card: 24 talons (INC-5), the next reward, 171/300.
        'YOUR TALON BALANCE',
        '24',
        'talons',
        'Your next reward',
        '+16 talons',
        '171/300',
        "Keep going—you're making progress!",
        'View rewards history',
        // The section and its cards, in the data's order.
        'Your daily quests',
        'Complete activities to earn more Talons.',
        'Daily General Knowledge Quiz',
        '6 of 7 days completed',
        'Completed today',
        'Resets tomorrow',
        'Reward claimed',
        'Study Streak Milestone I',
        '3 of 7 days completed',
        'Study a little each day to reach your milestone.',
        'Complete 7 days to unlock',
        'Weekly Survey',
        'Share how your study week went.',
        'Answer survey',
      ]) {
        expect(find.text(text), findsOneWidget, reason: text);
      }
      expect(richLine('1 minute · Available until Sunday'), findsOneWidget);
      expect(find.byType(QuestCard), findsNWidgets(3));
      expect(find.byType(AppLoader), findsNothing);
      expect(find.byType(ErrorState), findsNothing);
      expect(find.byType(AppAlert), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('tokens: fills, borders, icons, ink, chips and bars', (
      tester,
    ) async {
      await pumpTalon(tester, quests: _allIn(QuestStatus.claimed));

      // The balance card is Talon-100 with a Talon-700 border; its art is a
      // manual export (1.8).
      final balance = shellOf(tester, find.byType(TalonBalanceCard));
      expect(balance.color, AppColors.talon100);
      expect(balance.borderColor, AppColors.talon700);
      expect(balance.art, isNull);
      for (final (text, color) in [
        ('YOUR TALON BALANCE', AppColors.talon700),
        ('24', AppColors.talon900),
        ('talons', AppColors.talon700),
        ('Your next reward', AppColors.talon900),
        ("Keep going—you're making progress!", AppColors.talon700),
        ('View rewards history', AppColors.talon900),
        ('6 of 7 days completed', AppColors.grey500),
        ('Completed today', AppColors.sage500),
        ('Resets tomorrow', AppColors.sage500),
        (
          'Study a little each day to reach your milestone.',
          AppColors.plume500,
        ),
        ('Share how your study week went.', AppColors.sky700),
      ]) {
        expect(styleOf(tester, text).color, color, reason: text);
      }
      expect(styleOf(tester, '24').fontSize, 32); // Headings/H3
      final check = tester.widget<Icon>(find.byIcon(AppIcons.circleCheck));
      expect((check.color, check.size), (AppColors.sage500, 16));

      // Each quest card: its own fill, border and icon, with title and icon in
      // the card's ink.
      for (final (id, title, fill, border, icon, ink) in [
        (
          dailyQuizQuestId,
          'Daily General Knowledge Quiz',
          AppColors.sage50,
          AppColors.sage300,
          AppIcons.brain,
          AppColors.sage700,
        ),
        (
          streakQuestId,
          'Study Streak Milestone I',
          AppColors.sage50,
          AppColors.plume300,
          AppIcons.flame,
          AppColors.plume500,
        ),
        (
          surveyQuestId,
          'Weekly Survey',
          AppColors.sky50,
          AppColors.sky300,
          AppIcons.filePen, // spec 14 is li:file-pen (Home 8: file-pen-line)
          AppColors.sky900,
        ),
      ]) {
        final shell = shellOf(tester, card(id));
        expect((shell.color, shell.borderColor), (fill, border), reason: id);
        expect((shell.radius, shell.art), (16, null), reason: id);
        final glyph = tester.widget<Icon>(inCard(id, find.byIcon(icon)));
        expect((glyph.color, glyph.size), (ink, 24), reason: id);
        expect(styleOf(tester, title).color, ink, reason: id);
        expect(styleOf(tester, title).fontSize, 18, reason: id); // S1
      }

      // Chips: "+16 talons" Talon-500 on Grey-900, each "+5" Talon-300 on
      // Talon-900, 24 tall; a bare "+5" says its unit to screen readers.
      expect(find.byType(TalonChip), findsNWidgets(4));
      for (final (label, fill, ink) in [
        ('+16 talons', AppColors.talon500, AppColors.grey900),
        ('+5', AppColors.talon300, AppColors.talon900),
      ]) {
        final chip = find.widgetWithText(TalonChip, label).first;
        final box = find.descendant(of: chip, matching: find.byType(Container));
        final text = find.descendant(of: chip, matching: find.byType(Text));
        final decoration = tester.widget<Container>(box).decoration;
        expect((decoration! as BoxDecoration).color, fill, reason: label);
        expect(tester.widget<Text>(text).style!.color, ink, reason: label);
        expect(tester.getSize(chip).height, 24, reason: label);
      }
      final labels = tester
          .widgetList<TalonChip>(find.byType(TalonChip))
          .map((chip) => chip.semanticLabel);
      expect(labels, [null, '+5 talons', '+5 talons', '+5 talons']);

      // Bars follow the data, each in its own colours; the survey has none.
      final bars = tester
          .widgetList<TalonProgressBar>(find.byType(TalonProgressBar))
          .toList();
      expect(bars, hasLength(3));
      for (final (bar, value, color, track) in [
        (bars[0], 171 / 300, AppColors.talon700, AppColors.talon500),
        (bars[1], 6 / 7, AppColors.sage700, AppColors.sage300),
        (bars[2], 3 / 7, AppColors.plume500, AppColors.plume300),
      ]) {
        expect(bar.value, closeTo(value, 1e-9));
        expect((bar.color, bar.trackColor), (color, track));
      }
      expect(bars[0].label, '171/300');
      expect(bars[0].labelColor, AppColors.talon900);
      expect(
        inCard(surveyQuestId, find.byType(TalonProgressBar)),
        findsNothing,
      );
    });

    testWidgets('cards come in the order of the data', (tester) async {
      await pumpTalon(tester, quests: [_survey(), _daily(), _milestone()]);
      double top(String id) => tester.getTopLeft(card(id)).dy;
      expect(top(surveyQuestId), lessThan(top(dailyQuizQuestId)));
      expect(top(dailyQuizQuestId), lessThan(top(streakQuestId)));
    });

    testWidgets('singular nouns: 1 talon, +1 talon, 1 day', (tester) async {
      await pumpTalon(
        tester,
        overrides: [
          walletProvider.overrideWith((ref) async => const Wallet(talons: 1)),
          rewardProgressProvider.overrideWith(
            (ref) async =>
                const RewardProgress(nextRewardTalons: 1, done: 0, total: 300),
          ),
          questsProvider.overrideWith(
            (ref) async => [
              const Quest(
                id: 'one-day',
                title: 'One day wonder',
                kind: QuestKind.milestone,
                rewardTalons: 1,
                total: 1,
                status: QuestStatus.locked,
              ),
            ],
          ),
        ],
      );
      for (final text in [
        'talon',
        '+1 talon',
        '0/300',
        '0 of 1 day completed',
        'Complete 1 day to unlock',
        '+1',
      ]) {
        expect(find.text(text), findsOneWidget, reason: text);
      }
    });
  });

  group('buttons and status rows', () {
    // Per status: the label and whether the button works, for the daily
    // quiz, the milestone and the survey, in that order.
    final expected = <QuestStatus, List<(String, bool)>>{
      QuestStatus.available: [
        ("Take today's quiz", true),
        ('Complete 7 days to unlock', false), // a milestone has no action
        ('Answer survey', true),
      ],
      QuestStatus.completed: [
        ('Claim reward', true),
        ('Claim reward', true),
        ('Claim reward', true),
      ],
      QuestStatus.claimed: [
        ('Reward claimed', false),
        ('Reward claimed', false),
        ('Reward claimed', false),
      ],
      QuestStatus.locked: [
        ('Complete 7 days to unlock', false),
        ('Complete 7 days to unlock', false),
        ('Complete 1 day to unlock', false),
      ],
    };
    const ids = [dailyQuizQuestId, streakQuestId, surveyQuestId];
    const tones = [AppButtonTone.sage, AppButtonTone.plume, AppButtonTone.sky];
    const toned = [AppColors.sage500, AppColors.plume500, AppColors.sky900];

    for (final MapEntry(key: status, value: buttons) in expected.entries) {
      testWidgets('a $status quest', (tester) async {
        await pumpTalon(tester, quests: _allIn(status));
        for (var i = 0; i < ids.length; i++) {
          final (label, works) = buttons[i];
          final button = buttonIn(tester, ids[i]);
          expect(button.label, label, reason: ids[i]);
          expect(button.onPressed != null, works, reason: label);
          expect((button.tone, button.size), (tones[i], AppButtonSize.medium));
          expect(button.expand, isTrue);
          expect(tester.getSize(find.byWidget(button)).height, 40);
          if (works) continue;
          // Disabled keeps the card's colours once claimed (toned) and is
          // plain Grey-50 otherwise (light).
          final claimed = status == QuestStatus.claimed;
          expect(
            button.disabledLook,
            claimed ? AppButtonDisabledLook.toned : AppButtonDisabledLook.light,
            reason: label,
          );
          final style = button.buttonStyle(AppSemanticColors.light);
          final fill = style.backgroundColor!.resolve({WidgetState.disabled});
          final ink = style.foregroundColor!.resolve({WidgetState.disabled});
          expect(fill, claimed ? toned[i] : AppColors.grey50, reason: label);
          expect(ink, claimed ? AppColors.white : AppColors.grey400);
        }
      });
    }

    testWidgets('the daily quiz status row follows the status', (tester) async {
      for (final (quest, check, reset) in [
        (_daily(), true, 'Resets tomorrow'),
        (_daily(status: QuestStatus.completed), true, 'Resets tomorrow'),
        (_daily(status: QuestStatus.available), false, 'Resets at midnight'),
        (_daily(status: QuestStatus.available, resets: false), false, null),
      ]) {
        await pumpTalon(tester, quests: [quest]);
        final reason = '${quest.status} resets: ${reset ?? 'never'}';
        final done = check ? findsOneWidget : findsNothing;
        expect(find.text('Completed today'), done, reason: reason);
        expect(find.byIcon(AppIcons.circleCheck), done, reason: reason);
        expect(
          find.textContaining('Resets'),
          reset == null ? findsNothing : findsOneWidget,
        );
        if (reset != null) expect(find.text(reset), findsOneWidget);
      }
    });

    testWidgets('the survey subtitle has the duration, the day, or both', (
      tester,
    ) async {
      for (final (quest, line) in [
        (_survey(until: _sunday), '1 minute · Available until Sunday'),
        (
          _survey(until: DateTime(2026, 11, 27, 12)),
          '1 minute · Available until Friday',
        ),
        (_survey(minutes: null, until: _sunday), 'Available until Sunday'),
        (_survey(minutes: 5), '5 minutes'),
      ]) {
        await pumpTalon(tester, quests: [quest]);
        expect(richLine(line), findsOneWidget, reason: line);
      }
      await pumpTalon(tester, quests: [_survey(minutes: null)]);
      expect(find.text('Weekly Survey'), findsOneWidget);
      expect(find.textContaining('minute'), findsNothing);
      expect(find.textContaining('Available'), findsNothing);
      expect(tester.takeException(), isNull);
    });
  });

  group('navigation', () {
    testWidgets('back pops to Home', (tester) async {
      await pumpHome(tester, location: Routes.talonCredits);
      await tester.tap(find.bySemanticsLabel('Back'));
      await tester.pumpAndSettle();
      expect(location(tester), Routes.home);
      expect(find.byType(TalonCreditsScreen), findsNothing);
    });

    testWidgets('View rewards history opens the history gap', (tester) async {
      await pumpHome(tester, location: Routes.talonCredits);
      await tester.tap(find.text('View rewards history'));
      await tester.pumpAndSettle();
      expect(location(tester), '/home/talons/history');
      expect(location(tester), Routes.rewardsHistory);
      expect(find.byType(ComingSoonScreen), findsOneWidget);

      // The chevron is part of the link.
      router(tester).pop();
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(AppIcons.chevronRight));
      await tester.pumpAndSettle();
      expect(location(tester), Routes.rewardsHistory);
    });

    testWidgets('the open quests open the quiz and the survey', (tester) async {
      await pumpHome(
        tester,
        location: Routes.talonCredits,
        size: _tall,
        overrides: [
          questsOf([
            _daily(status: QuestStatus.available),
            _milestone(),
            _survey(),
          ]),
        ],
      );
      await tester.tap(find.text("Take today's quiz"));
      await tester.pumpAndSettle();
      expect(location(tester), Routes.dailyQuiz);
      router(tester).pop();
      await tester.pumpAndSettle();

      await tester.tap(find.text('Answer survey'));
      await tester.pumpAndSettle();
      expect(location(tester), Routes.weeklySurvey);

      // The survey is finished over there; the quests reload on return.
      await container(tester)
          .read(questRepositoryProvider)
          .submitSurvey(weeklySurveyId, _surveyAnswers);
      router(tester).pop();
      await tester.pumpAndSettle();
      expect(location(tester), Routes.talonCredits);
      expect(find.text('Claim reward'), findsOneWidget);
      expect(find.text('Answer survey'), findsNothing);
    });

    testWidgets('claimed and locked buttons ignore taps', (tester) async {
      await pumpHome(tester, location: Routes.talonCredits, size: _tall);
      for (final label in ['Reward claimed', 'Complete 7 days to unlock']) {
        await tester.tap(find.text(label), warnIfMissed: false);
        await tester.pumpAndSettle();
      }
      expect(location(tester), Routes.talonCredits);
      expect(await walletTalons(tester), 24);
    });
  });

  group('claiming', () {
    testWidgets('a claim credits the talons once, and Home follows', (
      tester,
    ) async {
      await pumpHome(tester, location: Routes.talonCredits, size: _tall);
      await completeSurvey(tester);
      expect(find.text('Claim reward'), findsOneWidget);
      expect(find.text('Answer survey'), findsNothing);
      expect(find.text('24'), findsOneWidget);

      // A double tap in one frame, with a callback from before it.
      final claim = find.text('Claim reward');
      final stale = buttonLabelled(tester, 'Claim reward').onPressed!;
      await tester.tap(claim);
      await tester.tap(claim, warnIfMissed: false);
      await tester.pumpAndSettle();

      // Both cards read "Reward claimed", and the balance is 24 + 5, once.
      expect(find.text('Claim reward'), findsNothing);
      expect(find.text('Reward claimed'), findsNWidgets(2));
      expect(find.text('29'), findsOneWidget);
      final claimed = buttonIn(tester, surveyQuestId);
      expect(claimed.onPressed, isNull);
      expect(claimed.disabledLook, AppButtonDisabledLook.toned);
      expect(await walletTalons(tester), 29);
      expect(find.byType(AppAlert), findsNothing);

      // A late tap on the old card changes nothing.
      stale();
      await tester.pumpAndSettle();
      expect(await walletTalons(tester), 29);

      // Back on Home the talon card shows the new balance.
      await tester.tap(find.bySemanticsLabel('Back'));
      await tester.pumpAndSettle();
      expect(location(tester), Routes.home);
      expect(find.text('29'), findsOneWidget);
      expect(find.text('View credits'), findsOneWidget);
    });

    testWidgets('the card stays busy, in its look, while claiming', (
      tester,
    ) async {
      await pumpTalon(
        tester,
        config: _slow,
        settle: false,
        quests: [_survey(status: QuestStatus.completed)],
      );
      await tester.pump(const Duration(seconds: 3));
      await tester.pump();
      expect(buttonLabelled(tester, 'Claim reward').onPressed, isNotNull);

      await tester.tap(find.text('Claim reward'));
      await tester.pump();
      // The claim, the credit and the reload take 2 s each. Meanwhile the
      // button keeps its label and tone, ignores taps, and the page keeps its
      // old numbers instead of flashing the loader.
      for (var second = 0; second < 6; second++) {
        final busy = buttonLabelled(tester, 'Claim reward');
        expect(busy.onPressed, isNull, reason: 'second $second');
        expect(busy.disabledLook, AppButtonDisabledLook.toned);
        expect(busy.tone, AppButtonTone.sky);
        expect(find.byType(AppLoader), findsNothing);
        expect(find.text('24'), findsOneWidget);
        await tester.pump(const Duration(seconds: 1));
      }
      await tester.pump();
      expect(find.text('Reward claimed'), findsOneWidget);
      expect(find.text('29'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('a failed claim shows an alert you can dismiss', (
      tester,
    ) async {
      final failing = _ClaimProbe(
        FakeConfig.instant,
        [_survey(status: QuestStatus.completed)],
        failing: {surveyQuestId},
      );
      await pumpTalon(
        tester,
        overrides: [questRepositoryProvider.overrideWithValue(failing)],
      );
      for (var attempt = 0; attempt < 2; attempt++) {
        await tester.tap(find.text('Claim reward'));
        await tester.pumpAndSettle();
        expect(find.text('Could not claim your reward'), findsOneWidget);
        expect(
          find.text('Something went wrong. Please try again.'),
          findsOneWidget,
        );
        // Nothing was credited, and the button is ready for another try.
        expect(find.text('24'), findsOneWidget);
        expect(buttonLabelled(tester, 'Claim reward').onPressed, isNotNull);
      }
      expect(failing.claims, 2);

      final close = find.descendant(
        of: find.byType(AppAlert),
        matching: find.byIcon(AppIcons.x),
      );
      await tester.tap(close);
      await tester.pumpAndSettle();
      expect(find.byType(AppAlert), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('leaving mid-claim neither throws nor drops the credit', (
      tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            fakeConfigProvider.overrideWithValue(_slow),
            questsOf([_survey(status: QuestStatus.completed)], config: _slow),
          ],
          retry: (_, _) => null,
          child: MaterialApp(
            theme: AppTheme.light,
            home: Builder(
              builder: (context) => Scaffold(
                body: TextButton(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const TalonCreditsScreen(),
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
      await tester.pump(); // build the route; the data starts loading
      await tester.pump(const Duration(seconds: 3)); // route in, data loaded
      await tester.pump();
      await tester.tap(find.text('Claim reward')); // the 2 s claim starts
      await tester.pump();
      await tester.tap(find.bySemanticsLabel('Back'));
      await tester.pump(); // the pop starts
      await tester.pump(const Duration(seconds: 1)); // route out
      await tester.pump(); // removed
      expect(find.byType(TalonCreditsScreen), findsNothing);

      // The claim, the credit and the reload finish without the screen.
      for (var i = 0; i < 3; i++) {
        await tester.pump(const Duration(seconds: 3));
      }
      expect(tester.takeException(), isNull);

      final c = ProviderScope.containerOf(tester.element(find.text('open')));
      final wallet = c.read(walletRepositoryProvider).fetchWallet();
      final quests = c.read(questRepositoryProvider).fetchQuests();
      await tester.pump(const Duration(seconds: 3));
      expect((await wallet).talons, 29);
      expect((await quests).single.status, QuestStatus.claimed);
    });
  });

  group('states', () {
    testWidgets('loading shows the loader and no content', (tester) async {
      await pumpTalon(tester, config: _slow, settle: false);
      expect(find.byType(AppLoader), findsOneWidget);
      expect(find.text('Talon credits'), findsOneWidget); // the bar stays
      expect(find.text('YOUR TALON BALANCE'), findsNothing);
      expect(find.byType(QuestCard), findsNothing);

      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();
      expect(find.byType(AppLoader), findsNothing);
      expect(find.text('YOUR TALON BALANCE'), findsOneWidget);
      expect(find.byType(QuestCard), findsNWidgets(3));
    });

    testWidgets('empty: the balance stays, the quests say none', (
      tester,
    ) async {
      await pumpHome(
        tester,
        config: emptyConfig,
        location: Routes.talonCredits,
      );
      for (final text in [
        'YOUR TALON BALANCE',
        '24',
        '171/300',
        'Your daily quests',
        'No quests right now',
        'Check back tomorrow for new ways to earn talons.',
      ]) {
        expect(find.text(text), findsOneWidget, reason: text);
      }
      expect(find.byType(QuestCard), findsNothing);
      expect(find.byType(EmptyState), findsOneWidget);
      expect(find.byType(ErrorState), findsNothing);

      await tester.tap(find.text('View rewards history'));
      await tester.pumpAndSettle();
      expect(location(tester), Routes.rewardsHistory);
      expect(tester.takeException(), isNull);
    });

    testWidgets('error: one retryable error state, and back still works', (
      tester,
    ) async {
      await pumpHome(
        tester,
        config: errorConfig,
        location: Routes.talonCredits,
      );
      expect(find.byType(ErrorState), findsOneWidget);
      expect(find.text('Talon credits'), findsOneWidget); // the bar stays
      expect(find.text('YOUR TALON BALANCE'), findsNothing);
      expect(find.byType(QuestCard), findsNothing);
      expect(find.byType(AppLoader), findsNothing);

      await tester.tap(find.text('Try again'));
      await tester.pumpAndSettle();
      expect(find.byType(ErrorState), findsOneWidget);

      await tester.tap(find.bySemanticsLabel('Back'));
      await tester.pumpAndSettle();
      expect(location(tester), Routes.home);
      expect(tester.takeException(), isNull);
    });

    testWidgets('any one provider failing shows the error; retry reloads all', (
      tester,
    ) async {
      for (final failing in ['wallet', 'progress', 'quests']) {
        final loads = {'wallet': 0, 'progress': 0, 'quests': 0};
        T load<T>(String name, T value) {
          final count = loads[name] = loads[name]! + 1;
          if (count == 1 && name == failing) throw RepositoryException(name);
          return value;
        }

        await pumpTalon(
          tester,
          overrides: [
            walletProvider.overrideWith(
              (ref) async => load('wallet', const Wallet(talons: 7)),
            ),
            rewardProgressProvider.overrideWith(
              (ref) async => load(
                'progress',
                const RewardProgress(
                  nextRewardTalons: 16,
                  done: 171,
                  total: 300,
                ),
              ),
            ),
            questsProvider.overrideWith(
              (ref) async => load('quests', [_survey()]),
            ),
          ],
        );
        expect(find.byType(ErrorState), findsOneWidget, reason: failing);
        expect(find.text('YOUR TALON BALANCE'), findsNothing);

        await tester.tap(find.text('Try again'));
        await tester.pumpAndSettle();
        expect(find.byType(ErrorState), findsNothing, reason: failing);
        expect(find.text('7'), findsOneWidget);
        expect(find.text('Weekly Survey'), findsOneWidget);
        expect(loads.values, everyElement(2), reason: failing);
      }
    });
  });

  group('layout', () {
    testWidgets('no overflow at narrow widths, large text and every status', (
      tester,
    ) async {
      // Tall viewports build the whole page; it is the width that is tested.
      for (final (size, scale, status) in [
        (const Size(360, 2000), 1.0, QuestStatus.claimed),
        (const Size(360, 2000), 1.0, QuestStatus.completed),
        (const Size(360, 3000), 1.5, QuestStatus.available),
        (const Size(320, 2400), 1.0, QuestStatus.locked),
      ]) {
        await pumpTalon(
          tester,
          size: size,
          textScale: scale,
          quests: _allIn(status),
        );
        expect(find.byType(QuestCard), findsNWidgets(3));
        expect(tester.takeException(), isNull, reason: '$size x$scale $status');
      }
    });

    testWidgets('no overflow with the empty state or a failure alert', (
      tester,
    ) async {
      await pumpTalon(tester, size: const Size(360, 640), config: emptyConfig);
      expect(find.byType(EmptyState), findsOneWidget);
      expect(tester.takeException(), isNull);

      final failing = _ClaimProbe(
        FakeConfig.instant,
        [_survey(status: QuestStatus.completed)],
        failing: {surveyQuestId},
      );
      await pumpTalon(
        tester,
        size: const Size(360, 800),
        overrides: [questRepositoryProvider.overrideWithValue(failing)],
      );
      await tester.tap(find.text('Claim reward'));
      await tester.pumpAndSettle();
      expect(find.byType(AppAlert), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('the page scrolls and keeps clear of the bottom inset', (
      tester,
    ) async {
      const inset = 24.0;
      final dpr = tester.view.devicePixelRatio;
      tester.view.viewPadding = FakeViewPadding(bottom: inset * dpr);
      tester.view.padding = FakeViewPadding(bottom: inset * dpr);
      addTearDown(tester.view.resetPadding);
      addTearDown(tester.view.resetViewPadding);
      const size = Size(428, 700);
      await pumpTalon(tester, size: size);
      await reveal(tester, find.text('Answer survey'));
      await tester.drag(find.byType(ListView), const Offset(0, -2000));
      await tester.pumpAndSettle();
      // The last card ends 24 + 16 (the design's gap and padding) above the
      // inset, which stands for the home indicator.
      final bottom = tester.getBottomLeft(card(surveyQuestId)).dy;
      expect(size.height - bottom, 24 + 16 + inset);
    });
  });

  group('TalonCreditsController', () {
    late ProviderContainer container;

    /// A scope with [overrides]; the screen is its listener unless [open] is
    /// false.
    void makeContainer(List<Override> overrides, {bool open = true}) {
      container = ProviderContainer(
        overrides: [
          fakeConfigProvider.overrideWithValue(FakeConfig.instant),
          ...overrides,
        ],
        retry: (_, _) => null,
      );
      if (open) container.listen(talonCreditsControllerProvider, (_, _) {});
      addTearDown(container.dispose);
    }

    Future<int> talons() async =>
        (await container.read(walletRepositoryProvider).fetchWallet()).talons;

    TalonCreditsController controller() =>
        container.read(talonCreditsControllerProvider.notifier);

    TalonClaimState state() => container.read(talonCreditsControllerProvider);

    Quest completed([Quest? quest]) =>
        (quest ?? _survey()).copyWith(status: QuestStatus.completed);

    test(
      'credits what the quest pays, reloads, ignores other statuses',
      () async {
        final milestone = _milestone(reward: 10);
        makeContainer([
          questsOf([completed(milestone), _daily()]),
        ]);
        expect((await container.read(walletProvider.future)).talons, 24);

        for (final status in [QuestStatus.available, QuestStatus.locked]) {
          await controller().claim(milestone.copyWith(status: status));
        }
        await controller().claim(_daily()); // claimed already
        expect(await talons(), 24);

        await controller().claim(completed(milestone));
        expect(await talons(), 34);
        final quests = await container.read(questsProvider.future);
        expect(quests.first.status, QuestStatus.claimed);
        expect((await container.read(walletProvider.future)).talons, 34);
        expect(state().claiming, isEmpty);
        expect(state().failed, isFalse);
      },
    );

    test('a quest is claimed once, however it is asked', () async {
      final gate = Completer<void>();
      final repo = _ClaimProbe(FakeConfig.instant, [
        completed(),
        completed(_daily()),
      ], gate: gate);
      makeContainer([questRepositoryProvider.overrideWithValue(repo)]);

      // Two at once: busy from the first call, so the second is turned away.
      // Another quest claims alongside.
      final first = controller().claim(completed());
      expect(state().isClaiming(surveyQuestId), isTrue);
      final second = controller().claim(completed());
      final other = controller().claim(completed(_daily()));
      expect(state().claiming, {surveyQuestId, dailyQuizQuestId});
      gate.complete();
      await Future.wait([first, second, other]);
      expect((repo.claims, await talons()), (2, 34));

      // Later, on an out-of-date card: still turned away.
      await controller().claim(completed());
      expect((repo.claims, await talons()), (2, 34));
      expect(state().claiming, isEmpty);
    });

    test('a failure is reported until it is dismissed or retried', () async {
      final failing = _ClaimProbe(
        FakeConfig.instant,
        [completed()],
        failing: {surveyQuestId},
      );
      makeContainer([questRepositoryProvider.overrideWithValue(failing)]);

      await controller().claim(completed());
      expect(state().failed, isTrue);
      expect(state().claiming, isEmpty);
      expect(await talons(), 24);
      controller().dismissError();
      expect(state().failed, isFalse);

      // A failed claim can be tried again; trying clears the old failure.
      await controller().claim(completed());
      expect(state().failed, isTrue);
      final retry = controller().claim(completed());
      expect(state().failed, isFalse);
      await retry;
      expect(state().failed, isTrue);
    });

    test('a failure stays reported while another claim goes through', () async {
      final gate = Completer<void>();
      final repo = _ClaimProbe(
        FakeConfig.instant,
        [completed(), completed(_daily())],
        gate: gate,
        failing: {surveyQuestId},
      );
      makeContainer([questRepositoryProvider.overrideWithValue(repo)]);

      final failing = controller().claim(completed());
      final other = controller().claim(completed(_daily()));
      gate.complete();
      await Future.wait([failing, other]);
      expect(state().failed, isTrue);
      expect(state().claiming, isEmpty);
      expect(await talons(), 29); // only the daily quiz was credited
    });

    test('a quest claimed but not credited is not claimed again', () async {
      final repo = _ClaimProbe(FakeConfig.instant, [completed()]);
      makeContainer([
        questRepositoryProvider.overrideWithValue(repo),
        walletRepositoryProvider.overrideWithValue(
          _FailingEarn(FakeConfig.instant),
        ),
      ]);
      await controller().claim(completed());
      await controller().claim(completed());
      expect((repo.claims, state().failed, await talons()), (1, true, 24));
      final quests = await container.read(questsProvider.future);
      expect(quests.single.status, QuestStatus.claimed);
    });

    test('a claim goes on after the screen is gone', () async {
      final gate = Completer<void>();
      final repo = _ClaimProbe(FakeConfig.instant, [completed()], gate: gate);
      makeContainer([
        questRepositoryProvider.overrideWithValue(repo),
      ], open: false);
      final screen = container.listen(
        talonCreditsControllerProvider,
        (_, _) {},
      );
      final claim = controller().claim(completed());

      screen.close(); // the screen is left: an auto-disposed provider goes
      await container.pump();
      gate.complete();
      await claim;
      await container.pump();

      expect(await talons(), 29);
      final quests = await container.read(questsProvider.future);
      expect(quests.single.status, QuestStatus.claimed);
    });

    test('nothing throws when the whole scope goes mid-claim', () async {
      final gate = Completer<void>();
      final repo = _ClaimProbe(FakeConfig.instant, [completed()], gate: gate);
      makeContainer([questRepositoryProvider.overrideWithValue(repo)]);
      final claim = controller().claim(completed());

      container.dispose();
      gate.complete();
      await claim; // answers after the scope is gone are dropped
    });
  });

  // The test font is wide and square, so text wraps earlier than in the real
  // font; the designed sizes only hold with the real fonts loaded. Keep this
  // group last: loading fonts changes every test after it.
  group('with the real fonts', () {
    setUpAll(() async {
      TestWidgetsFlutterBinding.ensureInitialized();
      await loadAppFonts();
    });

    testWidgets('sizes, gaps and offsets are the designed ones', (
      tester,
    ) async {
      await pumpTalon(tester);
      final balance = find.byType(TalonBalanceCard);
      final header = find.byType(SectionHeader);
      Offset topOf(Finder f) => tester.getTopLeft(f);
      Offset bottomOf(Finder f) => tester.getBottomLeft(f);
      final daily = card(dailyQuizQuestId);
      final milestone = card(streakQuestId);
      final survey = card(surveyQuestId);

      // 396 wide: the 428 frame less the 16 beside it (Figma's 394 sits in
      // its own 1 dp frame stroke). Heights 198, 198, 162; the balance card
      // is a 281 box with a 1 dp stroke outside it (spec 14).
      expect(tester.getSize(balance), const Size(396, 283));
      expect(tester.getSize(daily), const Size(396, 198));
      expect(tester.getSize(milestone), const Size(396, 198));
      expect(tester.getSize(survey), const Size(396, 162));
      for (final id in [dailyQuizQuestId, streakQuestId, surveyQuestId]) {
        expect(tester.getSize(inCard(id, find.byType(AppButton))).height, 40);
        expect(tester.getSize(inCard(id, find.byType(TalonChip))).height, 24);
      }

      // Vertical rhythm: 16 under the bar, 23 (24 less the stroke) to the
      // section, 16 between the header and the cards and between cards.
      expect(topOf(balance).dy, AppNavbarTop.height + 16);
      expect(tester.getSize(header).height, 48);
      expect(topOf(header).dy - bottomOf(balance).dy, 23);
      expect(topOf(daily).dy - bottomOf(header).dy, 16);
      expect(topOf(milestone).dy - bottomOf(daily).dy, 16);
      expect(topOf(survey).dy - bottomOf(milestone).dy, 16);

      // Inside the balance card: 1 + 16 to the frame, 16 to the label; the
      // divider ends the 115 tall balance row; the next reward follows it.
      final label = topOf(find.text('YOUR TALON BALANCE'));
      expect(label - topOf(balance), const Offset(17 + 16, 17 + 16));
      final divider = topOf(find.byKey(TalonBalanceCard.dividerKey));
      expect(divider.dy - topOf(balance).dy, 17 + 114);
      final next = topOf(find.text('Your next reward')).dy;
      expect(next - divider.dy, 1 + 16 + 2); // divider, padding, 24 tall row

      // Inside a quest card: a 48 icon slot 17 in, the title 10 after it, the
      // 8 tall bar 12 below the header; the daily quiz is 13 in, not 17.
      final icon = inCard(streakQuestId, find.byIcon(AppIcons.flame));
      expect(topOf(icon) - topOf(milestone), const Offset(17, 17));
      expect(tester.getSize(icon), const Size.square(48));
      final title = topOf(find.text('Study Streak Milestone I'));
      expect(title.dx - topOf(milestone).dx, 17 + 48 + 10);
      Finder barIn(String id) => find.descendant(
        of: inCard(id, find.byType(TalonProgressBar)),
        matching: find.byType(ClipRRect),
      );
      final bar = barIn(streakQuestId);
      expect(topOf(bar) - topOf(milestone), const Offset(17, 17 + 48 + 12 + 8));
      expect(tester.getSize(bar), const Size(396 - 34, 8));
      final dailyBar = barIn(dailyQuizQuestId);
      expect(topOf(dailyBar).dx - topOf(daily).dx, 13);
      expect(tester.getSize(dailyBar).width, 396 - 26);
      expect(tester.takeException(), isNull);
    });

    testWidgets('long titles fit one line at 428 and wrap at 360', (
      tester,
    ) async {
      await pumpTalon(tester);
      // Subtitle/S1 is 28 tall per line.
      for (final title in [
        'Daily General Knowledge Quiz',
        'Study Streak Milestone I',
      ]) {
        expect(tester.getSize(find.text(title)).height, 28, reason: title);
      }

      await pumpTalon(tester, size: const Size(360, 1400));
      final wrapped = find.text('Daily General Knowledge Quiz');
      expect(tester.getSize(wrapped).height, 56);
      expect(tester.takeException(), isNull);
    });
  });
}
