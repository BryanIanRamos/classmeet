import 'onboarding_prefs.dart';

/// The signed-in user (3.1, 8, 133).
final class UserProfile {
  const UserProfile({
    required this.id,
    required this.username,
    required this.email,
    required this.nickname,
    this.avatarAsset,
    required this.programLabel,
    required this.schoolShort,
    this.yearLevel,
  });

  final String id;

  /// Chosen at sign-up instead of a full name, and shown everywhere the
  /// design shows the user's name: the Home greeting, comments and the
  /// ranking "Display name" option (D-19).
  final String username;
  final String email;

  /// Leaderboard nickname, e.g. "Owl_4821" (133).
  final String nickname;
  final String? avatarAsset;

  /// e.g. "BSIT 2A" (8).
  final String programLabel;

  /// e.g. "CSU" (8).
  final String schoolShort;
  final YearLevel? yearLevel;

  UserProfile copyWith({
    String? id,
    String? username,
    String? email,
    String? nickname,
    String? avatarAsset,
    String? programLabel,
    String? schoolShort,
    YearLevel? yearLevel,
  }) {
    return UserProfile(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      nickname: nickname ?? this.nickname,
      avatarAsset: avatarAsset ?? this.avatarAsset,
      programLabel: programLabel ?? this.programLabel,
      schoolShort: schoolShort ?? this.schoolShort,
      yearLevel: yearLevel ?? this.yearLevel,
    );
  }
}

/// A person row in search results (12).
final class PersonSummary {
  const PersonSummary({
    required this.id,
    required this.name,
    required this.programLabel,
    this.schoolName,
    this.avatarAsset,
  });

  final String id;
  final String name;

  /// e.g. "BSIT - II".
  final String programLabel;
  final String? schoolName;
  final String? avatarAsset;

  PersonSummary copyWith({
    String? id,
    String? name,
    String? programLabel,
    String? schoolName,
    String? avatarAsset,
  }) {
    return PersonSummary(
      id: id ?? this.id,
      name: name ?? this.name,
      programLabel: programLabel ?? this.programLabel,
      schoolName: schoolName ?? this.schoolName,
      avatarAsset: avatarAsset ?? this.avatarAsset,
    );
  }
}
