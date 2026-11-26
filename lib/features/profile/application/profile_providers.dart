import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/profile.dart';
import '../../../data/providers.dart';

/// The signed-in user: the greeting header on the tab roots (8, 92, 93), its
/// avatar and "BSIT 2A · CSU".
final profileProvider = FutureProvider<UserProfile>(
  (ref) => ref.watch(profileRepositoryProvider).fetchProfile(),
);

/// "Good morning" before noon, "Good afternoon" until 6 PM, then
/// "Good evening" (the designs show the evening one).
String greetingFor(DateTime time) => switch (time.hour) {
  < 12 => 'Good morning',
  < 18 => 'Good afternoon',
  _ => 'Good evening',
};
