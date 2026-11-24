/// The study streak card (8).
final class Streak {
  const Streak({required this.days, this.freezesLeft = 0});

  final int days;

  /// "1 streak freeze left".
  final int freezesLeft;

  Streak copyWith({int? days, int? freezesLeft}) {
    return Streak(
      days: days ?? this.days,
      freezesLeft: freezesLeft ?? this.freezesLeft,
    );
  }
}
