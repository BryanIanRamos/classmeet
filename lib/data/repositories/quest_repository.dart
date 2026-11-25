import '../models/login_reward.dart';
import '../models/quest.dart';
import '../models/quiz.dart';
import '../models/survey.dart';

/// Talon-earning activities: daily quests (8, 14), the daily General
/// Knowledge quiz (15), the weekly survey (16) and login rewards (122).
abstract interface class QuestRepository {
  Future<List<Quest>> fetchQuests();

  /// Claims a completed quest's reward and returns the updated quest.
  Future<Quest> claimQuest(String questId);

  /// Today's general-knowledge questions (15).
  Future<List<Question>> fetchDailyQuiz();

  /// Records today's daily quiz as finished (15) and returns its quest: an
  /// available quest counts one more day and becomes completed, so its
  /// reward can be claimed. A quest already completed or claimed today comes
  /// back unchanged.
  Future<Quest> finishDailyQuiz();

  Future<Survey> fetchWeeklySurvey();

  /// [answers] maps a question id to the chosen option index.
  Future<void> submitSurvey(String surveyId, Map<String, int> answers);

  Future<LoginRewardWeek> fetchLoginRewards();
}
