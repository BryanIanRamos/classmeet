import 'dart:async';

import 'package:flutter_test/flutter_test.dart';

import '../test/helpers/app_fonts.dart';

/// Runs before every test in `test_render/`: loads the real fonts so renders
/// show Plus Jakarta Sans, Inter and the Lucide icons.
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  TestWidgetsFlutterBinding.ensureInitialized();
  await loadAppFonts();
  await testMain();
}
