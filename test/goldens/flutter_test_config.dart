import 'dart:async';

import 'package:flutter_test/flutter_test.dart';

import '../helpers/app_fonts.dart';

/// Runs before every golden test: loads the real fonts so goldens show
/// Plus Jakarta Sans, Inter and the Lucide icons.
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  TestWidgetsFlutterBinding.ensureInitialized();
  await loadAppFonts();
  await testMain();
}
