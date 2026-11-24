import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../theme/app_spacing.dart';
import '../widgets/feedback/error_state.dart';
import '../widgets/navigation/app_navbar_top.dart';
import 'routes.dart';

/// The router's `errorBuilder`: shown for an unknown path instead of
/// go_router's unstyled default page. Provisional copy (not designed).
class NotFoundScreen extends StatelessWidget {
  const NotFoundScreen({super.key, required this.location});

  final Uri location;

  static const title = "We couldn't find that page";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const AppNavbarTop(),
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  child: ErrorState(
                    title: title,
                    message: kDebugMode
                        ? 'No screen for $location'
                        : 'It may have moved or no longer exists.',
                    retryLabel: 'Go home',
                    onRetry: () => context.go(Routes.home),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
