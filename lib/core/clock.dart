import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The current time, for anything a screen derives from it (the Home
/// greeting, "In 5 days"). Tests and render runs override it with a fixed
/// time so the output does not depend on when they run.
final clockProvider = Provider<DateTime Function()>((ref) => DateTime.now);
