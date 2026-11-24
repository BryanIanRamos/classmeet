import 'package:classmeet/data/models/wallet.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Wallet', () {
    const w = Wallet(talons: 129, studyPoints: 300, xp: 40);

    test('defaults to zero', () {
      const z = Wallet();
      expect([z.talons, z.studyPoints, z.xp], [0, 0, 0]);
    });

    test('copyWith() keeps every field', () {
      final c = w.copyWith();
      expect([c.talons, c.studyPoints, c.xp], [129, 300, 40]);
    });

    test('copyWith changes only the given field', () {
      final c = w.copyWith(xp: 50);
      expect([c.talons, c.studyPoints, c.xp], [129, 300, 50]);
    });
  });

  group('RewardProgress', () {
    const r = RewardProgress(nextRewardTalons: 10, done: 171, total: 300);

    test('fraction is partial', () {
      expect(r.fraction, closeTo(0.57, 1e-9));
    });

    test('fraction is 0 when total is 0', () {
      expect(r.copyWith(total: 0).fraction, 0);
    });

    test('fraction is clamped when over total', () {
      expect(r.copyWith(done: 400).fraction, 1);
    });

    test('copyWith() keeps every field', () {
      final c = r.copyWith();
      expect([c.nextRewardTalons, c.done, c.total], [10, 171, 300]);
    });

    test('copyWith changes only the given field', () {
      final c = r.copyWith(done: 5);
      expect([c.nextRewardTalons, c.done, c.total], [10, 5, 300]);
    });
  });
}
