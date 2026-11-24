/// One day circle in the daily login rewards (122).
final class LoginRewardDay {
  const LoginRewardDay({
    required this.day,
    this.isClaimed = false,
    this.rewardTalons = 0,
    this.isGift = false,
  });

  /// 1..7.
  final int day;
  final bool isClaimed;
  final int rewardTalons;
  final bool isGift;

  LoginRewardDay copyWith({
    int? day,
    bool? isClaimed,
    int? rewardTalons,
    bool? isGift,
  }) => LoginRewardDay(
    day: day ?? this.day,
    isClaimed: isClaimed ?? this.isClaimed,
    rewardTalons: rewardTalons ?? this.rewardTalons,
    isGift: isGift ?? this.isGift,
  );
}

/// "Day 3 of 7" login reward strip (122).
final class LoginRewardWeek {
  const LoginRewardWeek({required this.currentDay, this.days = const []});

  final int currentDay;
  final List<LoginRewardDay> days;

  LoginRewardWeek copyWith({int? currentDay, List<LoginRewardDay>? days}) =>
      LoginRewardWeek(
        currentDay: currentDay ?? this.currentDay,
        days: days ?? this.days,
      );
}
