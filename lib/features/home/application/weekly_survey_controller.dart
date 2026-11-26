import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/quest.dart';
import '../../../data/models/survey.dart';
import '../../../data/providers.dart';
import 'home_providers.dart';

/// How a sent survey ended: what the result sheet reports (16).
final class WeeklySurveyResult {
  const WeeklySurveyResult({required this.talonsEarned});

  /// Talons this submission added to the wallet. 0 when this week's reward
  /// was already taken: the talons are for sending the survey once a week.
  final int talonsEarned;

  bool get earnedTalons => talonsEarned > 0;
}

/// Where the survey stands: the questions with the option picked for each,
/// and whether it is being sent, failed to send, or was sent ([result]).
final class WeeklySurveyState {
  const WeeklySurveyState({
    required this.survey,
    this.answers = const {},
    this.submitting = false,
    this.submitFailed = false,
    this.result,
  });

  final Survey survey;

  /// The option picked for each answered question: question id → index.
  final Map<String, int> answers;

  /// The answers are on their way: the picks are locked and Submit waits.
  final bool submitting;

  /// Sending failed; Submit tries again.
  final bool submitFailed;

  /// Set once the survey was sent.
  final WeeklySurveyResult? result;

  /// False when there is no survey this week (no questions).
  bool get hasQuestions => survey.questions.isNotEmpty;

  /// The answers can still change and be sent.
  bool get isOpen => hasQuestions && !submitting && result == null;

  /// What the repository gets: the picked answers, in question order.
  Map<String, int> get submission => {
    for (final question in survey.questions) question.id: ?answers[question.id],
  };

  /// The same survey with the given fields replaced.
  WeeklySurveyState copyWith({
    Map<String, int>? answers,
    bool? submitting,
    bool? submitFailed,
    WeeklySurveyResult? result,
  }) {
    return WeeklySurveyState(
      survey: survey,
      answers: answers ?? this.answers,
      submitting: submitting ?? this.submitting,
      submitFailed: submitFailed ?? this.submitFailed,
      result: result ?? this.result,
    );
  }
}

/// Drives the Weekly Survey (16): pick an answer per question, any of them or
/// none ("you can skip any question"), then send what was picked.
///
/// Sending is the weekly talon quest (14): [submit] records the answers and,
/// when that completed the quest, claims it and adds its talons to the wallet.
/// The talons are for sending the survey, not for any particular answer. The
/// fakes keep the quest and the wallet apart, so claiming and earning are two
/// calls; a backend would do both at once.
///
/// The provider is auto-disposed with the screen, so leaving drops the picks.
/// [submit] keeps it alive until every step has run, so leaving at the wrong
/// moment cannot claim the quest without paying the talons. Answers that
/// arrive after the whole provider scope is gone are dropped (`ref.mounted`).
class WeeklySurveyController extends AsyncNotifier<WeeklySurveyState> {
  /// Talons of a quest that was claimed but not yet added to the wallet,
  /// because adding them failed. The next [submit] pays them instead of
  /// asking the repository again, where the quest now reads as claimed and
  /// would pay nothing. It lives as long as the provider, so a student who
  /// leaves after the failure is not paid; the fakes cannot fail this way
  /// and a backend would pay on claim.
  int? _unpaid;

  @override
  Future<WeeklySurveyState> build() async {
    final survey = await ref.watch(questRepositoryProvider).fetchWeeklySurvey();
    return WeeklySurveyState(survey: survey);
  }

  /// Picks [option] for the question [questionId]. Picking the picked option
  /// again keeps it. Unknown questions and options, and picks while the survey
  /// is being sent or after it was sent, are ignored.
  void select(String questionId, int option) {
    final current = state.value;
    if (current == null || !current.isOpen) return;
    final question = current.survey.questions
        .where((q) => q.id == questionId)
        .firstOrNull;
    if (question == null || option < 0 || option >= question.options.length) {
      return;
    }
    if (current.answers[questionId] == option) return;
    state = AsyncData(
      current.copyWith(answers: {...current.answers, questionId: option}),
    );
  }

  /// Sends the picked answers (none is fine) and returns what came of it, or
  /// null when there is nothing to send, a submit is already running or the
  /// survey was sent already (a double tap sends once), or sending failed
  /// (then [WeeklySurveyState.submitFailed] is set and a new call tries again).
  Future<WeeklySurveyResult?> submit() async {
    final current = state.value;
    if (current == null || !current.isOpen) return null;

    final keepAlive = ref.keepAlive();
    // Busy before the first await, so a second tap in the same frame is
    // turned away.
    final working = current.copyWith(submitting: true, submitFailed: false);
    state = AsyncData(working);
    try {
      final quests = ref.read(questRepositoryProvider);
      final wallet = ref.read(walletRepositoryProvider);

      if (_unpaid == null) {
        await quests.submitSurvey(working.survey.id, working.submission);
        if (!ref.mounted) return null;
        final quest = (await quests.fetchQuests())
            .where((q) => q.kind == QuestKind.survey)
            .firstOrNull;
        if (!ref.mounted) return null;
        // Completed and not yet claimed: the week's reward is due. A quest
        // that was already claimed comes back as such, and pays nothing twice.
        if (quest != null && quest.status == QuestStatus.completed) {
          await quests.claimQuest(quest.id);
          if (!ref.mounted) return null;
          _unpaid = quest.rewardTalons;
        }
      }

      var earned = 0;
      final unpaid = _unpaid;
      if (unpaid != null) {
        await wallet.earn(talons: unpaid);
        if (!ref.mounted) return null;
        _unpaid = null;
        earned = unpaid;
        ref
          ..invalidate(questsProvider)
          ..invalidate(walletProvider);
      }

      final result = WeeklySurveyResult(talonsEarned: earned);
      state = AsyncData(working.copyWith(submitting: false, result: result));
      return result;
    } on Object {
      if (ref.mounted) {
        state = AsyncData(
          working.copyWith(submitting: false, submitFailed: true),
        );
      }
      return null;
    } finally {
      if (ref.mounted) keepAlive.close();
    }
  }
}

final weeklySurveyControllerProvider =
    AsyncNotifierProvider.autoDispose<
      WeeklySurveyController,
      WeeklySurveyState
    >(WeeklySurveyController.new);
