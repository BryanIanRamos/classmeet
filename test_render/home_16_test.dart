import 'package:classmeet/data/fakes/fake_config.dart';
import 'package:classmeet/data/fakes/fake_quest_repository.dart';
import 'package:classmeet/data/fakes/samples/quest_samples.dart';
import 'package:classmeet/data/models/quest.dart';
import 'package:classmeet/data/providers.dart';
import 'package:classmeet/features/home/presentation/screens/weekly_survey_screen.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';

import 'render_harness.dart';

final List<Override> _instant = [
  fakeConfigProvider.overrideWithValue(FakeConfig.instant),
];

/// The survey quest as Home shows it once the week's reward was taken.
const _claimedQuest = Quest(
  id: surveyQuestId,
  title: 'Weekly Survey',
  kind: QuestKind.survey,
  rewardTalons: 5,
  total: 1,
  status: QuestStatus.claimed,
);

Future<void> _tap(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

/// The answers the design shows picked: "After class", "Too many topics to
/// cover" and "6–10 hours".
Future<void> _pickDesignAnswers(WidgetTester tester) async {
  await _tap(tester, find.text('After class'));
  await _tap(tester, find.text('Too many topics to cover'));
  await _tap(tester, find.text('6–10 hours'));
}

void main() {
  testWidgets('16 weekly survey', (tester) async {
    // The design's copy says "Resets at midnight" and "Earn 2 Talons"; the
    // render says "Available until Sunday" and "Earn 5 Talons" (the survey
    // closes on Sunday, and INC-5 makes every quest +5). Selected radio cards
    // are 50 tall, not the design's 48 (INC-15).
    await renderScreen(
      tester,
      'home/16_weekly_survey',
      const WeeklySurveyScreen(),
      overrides: _instant,
      fullPage: true,
      prepare: _pickDesignAnswers,
    );
  });

  // The result sheet is not designed; these renders are for reviewing the
  // provisional look next to the quiz's, and have no reference image.
  for (final (name, earns) in [
    ('home/16_weekly_survey_result_earned', true),
    ('home/16_weekly_survey_result_already', false),
  ]) {
    testWidgets('16 weekly survey, result sheet ($earns)', (tester) async {
      await renderScreen(
        tester,
        name,
        const WeeklySurveyScreen(),
        overrides: [
          ..._instant,
          if (!earns)
            questRepositoryProvider.overrideWithValue(
              FakeQuestRepository(FakeConfig.instant, quests: [_claimedQuest]),
            ),
        ],
        prepare: (tester) async {
          await _pickDesignAnswers(tester);
          await _tap(tester, find.textContaining('Submit survey'));
        },
      );
    });
  }
}
