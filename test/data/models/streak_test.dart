import 'package:classmeet/data/models/streak.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Streak', () {
    const s = Streak(days: 6, freezesLeft: 1);
    final k = s.copyWith();
    expect([k.days, k.freezesLeft], [6, 1]);
    final c = s.copyWith(days: 7);
    expect([c.days, c.freezesLeft], [7, 1]);
    expect(const Streak(days: 1).freezesLeft, 0);
  });
}
