/// A class the user joined (93, 85, 13.1).
final class StudyClass {
  const StudyClass({
    required this.id,
    required this.code,
    required this.title,
    required this.teacher,
    this.newUpdates = 0,
    this.reviewerCount = 0,
    this.quizCount = 0,
    this.setCount = 0,
    this.plannerCount = 0,
  });

  final String id;

  /// e.g. "ITE13".
  final String code;
  final String title;

  /// e.g. "Prof. Rhea Santos".
  final String teacher;

  /// "1 new update" (93); 0 shows "You're all caught up".
  final int newUpdates;
  final int reviewerCount;
  final int quizCount;
  final int setCount;
  final int plannerCount;

  bool get hasNewUpdates => newUpdates > 0;

  StudyClass copyWith({
    String? id,
    String? code,
    String? title,
    String? teacher,
    int? newUpdates,
    int? reviewerCount,
    int? quizCount,
    int? setCount,
    int? plannerCount,
  }) {
    return StudyClass(
      id: id ?? this.id,
      code: code ?? this.code,
      title: title ?? this.title,
      teacher: teacher ?? this.teacher,
      newUpdates: newUpdates ?? this.newUpdates,
      reviewerCount: reviewerCount ?? this.reviewerCount,
      quizCount: quizCount ?? this.quizCount,
      setCount: setCount ?? this.setCount,
      plannerCount: plannerCount ?? this.plannerCount,
    );
  }
}
