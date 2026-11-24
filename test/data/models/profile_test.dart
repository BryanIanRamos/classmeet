import 'package:classmeet/data/models/onboarding_prefs.dart';
import 'package:classmeet/data/models/profile.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('UserProfile', () {
    const p = UserProfile(
      id: 'u1',
      fullName: 'Bryan Ramos',
      email: 'b@x.com',
      nickname: 'Owl_4821',
      avatarAsset: 'a.png',
      programLabel: 'BSIT 2A',
      schoolShort: 'CSU',
      yearLevel: YearLevel.second,
    );

    test('copyWith() keeps every field', () {
      final c = p.copyWith();
      expect(c.id, 'u1');
      expect(c.fullName, 'Bryan Ramos');
      expect(c.email, 'b@x.com');
      expect(c.nickname, 'Owl_4821');
      expect(c.avatarAsset, 'a.png');
      expect(c.programLabel, 'BSIT 2A');
      expect(c.schoolShort, 'CSU');
      expect(c.yearLevel, YearLevel.second);
    });

    test('copyWith changes only the given field', () {
      final c = p.copyWith(nickname: 'Hoot');
      expect(c.nickname, 'Hoot');
      expect(c.fullName, 'Bryan Ramos');
      expect(c.yearLevel, YearLevel.second);
    });
  });

  group('PersonSummary', () {
    const s = PersonSummary(
      id: 'p1',
      name: 'Arabela Matias',
      programLabel: 'BSIT - II',
      schoolName: 'Caraga State University',
      avatarAsset: 'a.png',
    );

    test('copyWith() keeps every field', () {
      final c = s.copyWith();
      expect(c.id, 'p1');
      expect(c.name, 'Arabela Matias');
      expect(c.programLabel, 'BSIT - II');
      expect(c.schoolName, 'Caraga State University');
      expect(c.avatarAsset, 'a.png');
    });

    test('copyWith changes only the given field', () {
      final c = s.copyWith(name: 'Joshua Bete');
      expect(c.name, 'Joshua Bete');
      expect(c.programLabel, 'BSIT - II');
      expect(c.schoolName, 'Caraga State University');
    });
  });
}
