import 'package:classmeet/data/fakes/fake_config.dart';
import 'package:classmeet/data/fakes/fake_quest_repository.dart';
import 'package:classmeet/data/models/quest.dart';
import 'package:classmeet/data/models/survey.dart';
import 'package:classmeet/data/repositories/repository_exception.dart';
import 'package:flutter_test/flutter_test.dart';

const _empty = FakeConfig(scenario: FakeScenario.empty, latency: Duration.zero);
const _error = FakeConfig(scenario: FakeScenario.error, latency: Duration.zero);

void main() {
  // A Tuesday.
  final now = DateTime(2026, 11, 24, 14);
  late FakeQuestRepository repo;
  setUp(() => repo = FakeQuestRepository(FakeConfig.instant, clock: () => now));

  test('quests match frame 14 with clock-based times', () async {
    final quests = await repo.fetchQuests();
    expect(quests.map((q) => q.title), [
      'Daily General Knowledge Quiz',
      'Study Streak Milestone I',
      'Weekly Survey',
    ]);
    final quiz = quests[0];
    expect((quiz.done, quiz.total, quiz.rewardTalons), (6, 7, 5));
    expect(quiz.status, QuestStatus.claimed);
    expect(quiz.resetsAt, DateTime(2026, 11, 25));
    final streak = quests[1];
    expect((streak.done, streak.total), (3, 7));
    expect(streak.status, QuestStatus.locked);
    final survey = quests[2];
    expect(survey.rewardTalons, 5);
    expect(survey.durationMinutes, 1);
    expect(survey.availableUntil, DateTime(2026, 11, 29, 23, 59, 59));
  });

  test('finishDailyQuiz leaves the claimed sample quiz unchanged', () async {
    final q = await repo.finishDailyQuiz();
    expect((q.done, q.status), (6, QuestStatus.claimed));
  });

  test('finishDailyQuiz completes an open quiz, then claim works', () async {
    final open = FakeQuestRepository(
      FakeConfig.instant,
      clock: () => now,
      quests: const [
        Quest(
          id: 'daily-gk-quiz',
          title: 'Daily General Knowledge Quiz',
          kind: QuestKind.daily,
          rewardTalons: 5,
          done: 5,
          total: 7,
        ),
      ],
    );
    final done = await open.finishDailyQuiz();
    expect((done.done, done.status), (6, QuestStatus.completed));
    final again = await open.finishDailyQuiz();
    expect(again.done, 6, reason: 'one day counts once');
    final claimed = await open.claimQuest('daily-gk-quiz');
    expect(claimed.status, QuestStatus.claimed);
    expect((await open.fetchQuests()).single.status, QuestStatus.claimed);
  });

  test('survey questions use the frame-16 styles', () async {
    final s = await repo.fetchWeeklySurvey();
    expect(s.questions.map((q) => q.style), [
      SurveyQuestionStyle.chips,
      SurveyQuestionStyle.radios,
      SurveyQuestionStyle.radios,
    ]);
  });

  test('survey runs through submit then claim', () async {
    final s = await repo.fetchWeeklySurvey();
    expect(s.title, "How's your study week going?");
    expect(s.questions, hasLength(3));
    expect(s.questions[2].options, [
      'Under 2 hours',
      '2–5 hours',
      '6–10 hours',
      'More than 10 hours',
    ]);
    await expectLater(
      repo.claimQuest('weekly-survey'),
      throwsA(isA<RepositoryException>()),
    );
    await repo.submitSurvey(s.id, {'when': 1, 'challenge': 0, 'hours': 3});
    final quests = await repo.fetchQuests();
    expect(quests[2].status, QuestStatus.completed);
    final claimed = await repo.claimQuest('weekly-survey');
    expect(claimed.status, QuestStatus.claimed);
    expect((await repo.fetchQuests())[2].status, QuestStatus.claimed);
  });

  test('submitSurvey rejects bad input', () async {
    await expectLater(
      repo.submitSurvey('nope', {}),
      throwsA(isA<RepositoryException>()),
    );
    await expectLater(
      repo.submitSurvey('weekly-survey', {'when': 9}),
      throwsA(isA<RepositoryException>()),
    );
  });

  test('claimQuest fails for locked and unknown quests', () async {
    await expectLater(
      repo.claimQuest('streak-milestone-1'),
      throwsA(isA<RepositoryException>()),
    );
    await expectLater(
      repo.claimQuest('nope'),
      throwsA(isA<RepositoryException>()),
    );
  });

  test('claiming an already claimed quest is a no-op', () async {
    final q = await repo.claimQuest('daily-gk-quiz');
    expect(q.status, QuestStatus.claimed);
  });

  test('daily quiz has 5 questions; the 2nd is the design question', () async {
    final qs = await repo.fetchDailyQuiz();
    expect(qs, hasLength(5));
    expect(
      qs[1].prompt,
      'Which Philippine law protects the personal data of students and '
      'other citizens?',
    );
    expect(qs[1].category, 'Science & Society');
    expect(
      qs[1].options[qs[1].correctIndex],
      'RA 10173 · Data Privacy Act of 2012',
    );
    expect(qs.every((q) => q.options.length == 4), isTrue);
  });

  test('login rewards: day 3 of 7, gift on day 7', () async {
    final w = await repo.fetchLoginRewards();
    expect(w.currentDay, 3);
    expect(w.days, hasLength(7));
    expect(w.days.take(3).every((d) => d.isClaimed), isTrue);
    expect(w.days.skip(3).any((d) => d.isClaimed), isFalse);
    expect(w.days.last.isGift, isTrue);
  });

  test('Sunday keeps the survey open until the same day', () async {
    final sunday = DateTime(2026, 11, 29, 9);
    final r = FakeQuestRepository(FakeConfig.instant, clock: () => sunday);
    final survey = (await r.fetchQuests())[2];
    expect(survey.availableUntil, DateTime(2026, 11, 29, 23, 59, 59));
  });

  test('empty scenario returns empty data', () async {
    final r = FakeQuestRepository(_empty, clock: () => now);
    expect(await r.fetchQuests(), isEmpty);
    expect(await r.fetchDailyQuiz(), isEmpty);
    expect((await r.fetchWeeklySurvey()).questions, isEmpty);
    expect((await r.fetchLoginRewards()).days, isEmpty);
  });

  test('error scenario throws', () {
    final r = FakeQuestRepository(_error, clock: () => now);
    expect(r.fetchQuests(), throwsA(isA<RepositoryException>()));
    expect(r.claimQuest('daily-gk-quiz'), throwsA(isA<RepositoryException>()));
    expect(r.fetchDailyQuiz(), throwsA(isA<RepositoryException>()));
    expect(r.finishDailyQuiz(), throwsA(isA<RepositoryException>()));
    expect(r.fetchWeeklySurvey(), throwsA(isA<RepositoryException>()));
    expect(
      r.submitSurvey('weekly-survey', {}),
      throwsA(isA<RepositoryException>()),
    );
    expect(r.fetchLoginRewards(), throwsA(isA<RepositoryException>()));
  });
}
