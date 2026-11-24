import 'package:classmeet/data/models/study_plan.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DailyProgress', () {
    test('remaining and fraction', () {
      const p = DailyProgress(activitiesDone: 2, activitiesTotal: 5);
      expect(p.remaining, 3);
      expect(p.fraction, closeTo(0.4, 1e-9));
    });

    test('nothing planned is 0 remaining and 0 fraction', () {
      const p = DailyProgress();
      expect(p.remaining, 0);
      expect(p.fraction, 0);
    });

    test('overshoot clamps', () {
      const p = DailyProgress(activitiesDone: 7, activitiesTotal: 5);
      expect(p.remaining, 0);
      expect(p.fraction, 1);
    });

    test('copyWith keeps unspecified fields', () {
      const p = DailyProgress(activitiesDone: 1, activitiesTotal: 5);
      final q = p.copyWith(activitiesDone: 4);
      expect((q.activitiesDone, q.activitiesTotal), (4, 5));
    });
  });

  group('PlanGoal', () {
    final due = DateTime(2026, 11, 29);

    test('remaining and fraction (frame 8: 6 of 9 is 67%)', () {
      final g = PlanGoal(
        id: 'g',
        title: 'IT109 Midterm',
        dueAt: due,
        activitiesDone: 6,
        activitiesTotal: 9,
      );
      expect(g.remaining, 3);
      expect((g.fraction * 100).round(), 67);
    });

    test('no activities is 0 fraction', () {
      final g = PlanGoal(id: 'g', title: 't', dueAt: due);
      expect(g.fraction, 0);
      expect(g.remaining, 0);
    });

    test('copyWith keeps unspecified fields', () {
      final g = PlanGoal(id: 'g', title: 't', classId: 'c', dueAt: due);
      final h = g.copyWith(title: 'u');
      expect((h.id, h.title, h.classId, h.dueAt), ('g', 'u', 'c', due));
    });
  });
}
