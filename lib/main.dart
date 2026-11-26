import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'core/app_retry.dart';

void main() {
  // A failed load shows its error state within a second (see appRetry).
  runApp(const ProviderScope(retry: appRetry, child: ClassMeetApp()));
}
