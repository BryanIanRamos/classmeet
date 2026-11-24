import '../models/login_reward.dart';
import '../models/quest.dart';
import '../models/quiz.dart';
import '../models/survey.dart';
import '../repositories/quest_repository.dart';
import '../repositories/repository_exception.dart';
import 'fake_config.dart';
import 'samples/quest_samples.dart';

/// In-memory [QuestRepository]. Submitting the survey completes its quest;
/// claiming a completed quest marks it claimed. Quest times come from the
/// clock (resets at midnight, survey open until Sunday).
class FakeQuestRepository implements QuestRepository {
  FakeQuestRepository(this._config, {DateTime Function()? clock})
    : _clock = clock ?? DateTime.now {
    _quests = _config.isEmpty ? [] : questSamples(_clock());
  }

  final FakeConfig _config;
  final DateTime Function() _clock;
  late final List<Quest> _quests;

  @override
  Future<List<Quest>> fetchQuests() =>
      _config.answerList('fetchQuests', () => List.of(_quests));

  @override
  Future<Quest> claimQuest(String questId) => _config.answer('claimQuest', () {
    final index = _indexOf(questId);
    final quest = _quests[index];
    switch (quest.status) {
      case QuestStatus.claimed:
        return quest;
      case QuestStatus.completed:
        return _quests[index] = quest.copyWith(status: QuestStatus.claimed);
      case QuestStatus.available || QuestStatus.locked:
        throw RepositoryException('Quest $questId is not completed yet');
    }
  });

  @override
  Future<List<Question>> fetchDailyQuiz() =>
      _config.answerList('fetchDailyQuiz', () => List.of(dailyQuizQuestions));

  @override
  Future<Survey> fetchWeeklySurvey() => _config.answer(
    'fetchWeeklySurvey',
    () => weeklySurvey,
    empty: () => weeklySurvey.copyWith(questions: const []),
  );

  @override
  Future<void> submitSurvey(String surveyId, Map<String, int> answers) =>
      _config.answer('submitSurvey', () {
        if (surveyId != weeklySurveyId) {
          throw RepositoryException('Unknown survey: $surveyId');
        }
        for (final entry in answers.entries) {
          final question = weeklySurvey.questions
              .where((q) => q.id == entry.key)
              .firstOrNull;
          if (question == null ||
              entry.value < 0 ||
              entry.value >= question.options.length) {
            throw RepositoryException(
              'Invalid answer ${entry.key}=${entry.value}',
            );
          }
        }
        final index = _quests.indexWhere((q) => q.id == surveyQuestId);
        if (index != -1 && _quests[index].status == QuestStatus.available) {
          _quests[index] = _quests[index].copyWith(
            done: _quests[index].total,
            status: QuestStatus.completed,
          );
        }
      });

  @override
  Future<LoginRewardWeek> fetchLoginRewards() => _config.answer(
    'fetchLoginRewards',
    () => loginRewardWeek,
    empty: () => const LoginRewardWeek(currentDay: 0),
  );

  int _indexOf(String questId) {
    final index = _quests.indexWhere((q) => q.id == questId);
    if (index == -1) throw RepositoryException('Unknown quest: $questId');
    return index;
  }
}
