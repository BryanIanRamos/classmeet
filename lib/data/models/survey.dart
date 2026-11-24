/// How a survey question's options are shown (16).
enum SurveyQuestionStyle { chips, radios }

/// One survey question (16).
final class SurveyQuestion {
  const SurveyQuestion({
    required this.id,
    required this.prompt,
    required this.style,
    this.options = const [],
  });

  final String id;
  final String prompt;
  final SurveyQuestionStyle style;
  final List<String> options;

  SurveyQuestion copyWith({
    String? id,
    String? prompt,
    SurveyQuestionStyle? style,
    List<String>? options,
  }) {
    return SurveyQuestion(
      id: id ?? this.id,
      prompt: prompt ?? this.prompt,
      style: style ?? this.style,
      options: options ?? this.options,
    );
  }
}

/// The weekly survey (16).
final class Survey {
  const Survey({
    required this.id,
    required this.title,
    required this.rewardTalons,
    this.questions = const [],
  });

  final String id;
  final String title;
  final int rewardTalons;
  final List<SurveyQuestion> questions;

  Survey copyWith({
    String? id,
    String? title,
    int? rewardTalons,
    List<SurveyQuestion>? questions,
  }) {
    return Survey(
      id: id ?? this.id,
      title: title ?? this.title,
      rewardTalons: rewardTalons ?? this.rewardTalons,
      questions: questions ?? this.questions,
    );
  }
}
