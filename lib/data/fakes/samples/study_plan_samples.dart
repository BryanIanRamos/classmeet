import '../../models/study_plan.dart';

/// Frame 8: "3 activities remaining". The total of 5 is // sample.
const sampleDailyProgress = DailyProgress(
  activitiesDone: 2,
  activitiesTotal: 5,
);

/// Frame 8 "Coming up next": "IT109 Midterm", "3 activities left · In 5 days",
/// 67% (6 of 9 done). The second goal is // sample.
List<PlanGoal> planGoalSamples(DateTime now) {
  final today = DateTime(now.year, now.month, now.day);
  return [
    PlanGoal(
      id: 'goal-it109-midterm',
      title: 'IT109 Midterm',
      dueAt: today.add(const Duration(days: 5)),
      activitiesDone: 6,
      activitiesTotal: 9,
    ),
    PlanGoal(
      id: 'goal-ite13-quiz-3',
      title: 'ITE13 Quiz 3',
      classId: 'ite13',
      dueAt: today.add(const Duration(days: 9)),
      activitiesDone: 1,
      activitiesTotal: 4,
    ),
  ];
}
