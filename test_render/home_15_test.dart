import 'package:classmeet/data/fakes/fake_config.dart';
import 'package:classmeet/data/fakes/fake_quest_repository.dart';
import 'package:classmeet/data/fakes/samples/quest_samples.dart';
import 'package:classmeet/data/models/quest.dart';
import 'package:classmeet/data/providers.dart';
import 'package:classmeet/features/home/presentation/screens/daily_quiz_screen.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';

import 'render_harness.dart';

/// Today's quest with the reward still to earn (the sample one is claimed).
const _openQuest = Quest(
  id: dailyQuizQuestId,
  title: 'Daily General Knowledge Quiz',
  kind: QuestKind.daily,
  rewardTalons: 5,
  done: 5,
  total: 7,
);

final List<Override> _instant = [
  fakeConfigProvider.overrideWithValue(FakeConfig.instant),
];

Future<void> _tap(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

/// Question 1 of the sample quiz: the right answer, checked, then on to
/// question 2, the design's.
Future<void> _toQuestionTwo(WidgetTester tester) async {
  await _tap(tester, find.text('A. June 12'));
  await _tap(tester, find.text('Check answer'));
  await _tap(tester, find.text('Next question'));
}

void main() {
  testWidgets('15 daily gk quiz', (tester) async {
    // The design shows question 2 of 5 with "A." picked. The sample quiz keeps
    // that question second, so the render plays through question 1 first.
    await renderScreen(
      tester,
      'home/15_daily_gk_quiz',
      const DailyQuizScreen(),
      overrides: _instant,
      fullPage: true,
      prepare: (tester) async {
        await _toQuestionTwo(tester);
        await _tap(tester, find.text('A. RA 10173 · Data Privacy Act of 2012'));
      },
    );
  });

  // The checked and finished states are not designed (only the question is);
  // these renders are for reviewing the provisional look next to frames
  // 125 and 126, and have no reference image.
  testWidgets('15 daily gk quiz, right answer checked', (tester) async {
    await renderScreen(
      tester,
      'home/15_daily_gk_quiz_correct',
      const DailyQuizScreen(),
      overrides: _instant,
      fullPage: true,
      prepare: (tester) async {
        await _toQuestionTwo(tester);
        await _tap(tester, find.text('A. RA 10173 · Data Privacy Act of 2012'));
        await _tap(tester, find.text('Check answer'));
      },
    );
  });

  testWidgets('15 daily gk quiz, wrong answer checked', (tester) async {
    await renderScreen(
      tester,
      'home/15_daily_gk_quiz_wrong',
      const DailyQuizScreen(),
      overrides: _instant,
      fullPage: true,
      prepare: (tester) async {
        await _toQuestionTwo(tester);
        await _tap(
          tester,
          find.text('B. RA 10175 · Cybercrime Prevention Act'),
        );
        await _tap(tester, find.text('Check answer'));
      },
    );
  });

  for (final (name, earns) in [
    ('home/15_daily_gk_quiz_result_earned', true),
    ('home/15_daily_gk_quiz_result_already', false),
  ]) {
    testWidgets('15 daily gk quiz, result sheet ($earns)', (tester) async {
      await renderScreen(
        tester,
        name,
        const DailyQuizScreen(),
        overrides: [
          ..._instant,
          if (earns)
            questRepositoryProvider.overrideWithValue(
              FakeQuestRepository(FakeConfig.instant, quests: [_openQuest]),
            ),
        ],
        prepare: (tester) async {
          const picks = [0, 1, 1, 2, 3];
          for (var i = 0; i < picks.length; i++) {
            final options = dailyQuizQuestions[i].options;
            final letter = String.fromCharCode(0x41 + picks[i]);
            await _tap(tester, find.text('$letter. ${options[picks[i]]}'));
            await _tap(tester, find.text('Check answer'));
            await _tap(
              tester,
              find.text(i < picks.length - 1 ? 'Next question' : 'Finish quiz'),
            );
          }
        },
      );
    });
  }
}
