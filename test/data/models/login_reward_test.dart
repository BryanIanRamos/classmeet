import 'package:classmeet/data/models/login_reward.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('LoginRewardDay', () {
    const d = LoginRewardDay(
      day: 7,
      isClaimed: true,
      rewardTalons: 5,
      isGift: true,
    );
    final c = d.copyWith();
    expect([c.day, c.isClaimed, c.rewardTalons, c.isGift], [7, true, 5, true]);
    final e = d.copyWith(isClaimed: false);
    expect(e.isClaimed, isFalse);
    expect(e.day, 7);
    expect(const LoginRewardDay(day: 1).rewardTalons, 0);
  });

  test('LoginRewardWeek', () {
    const w = LoginRewardWeek(
      currentDay: 3,
      days: [LoginRewardDay(day: 1, isClaimed: true)],
    );
    expect(w.copyWith().currentDay, 3);
    expect(w.copyWith().days, hasLength(1));
    final c = w.copyWith(currentDay: 4);
    expect(c.currentDay, 4);
    expect(c.days, hasLength(1));
  });
}
