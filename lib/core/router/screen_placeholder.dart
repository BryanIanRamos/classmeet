import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../theme/app_semantic_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import '../widgets/buttons/app_button.dart';
import '../widgets/navigation/app_navbar_top.dart';

/// A link on a [ScreenPlaceholder]: a button that walks the designed flow.
class PlaceholderLink {
  const PlaceholderLink(
    this.label,
    this.location, {
    this.replace = false,
    this.action,
  });

  final String label;
  final String location;

  /// True to `go` (replace the stack, e.g. "Done" back to a tab), false to
  /// `push` (so back returns here).
  final bool replace;

  /// Runs before navigating, e.g. to mark the session as signed up.
  final void Function(WidgetRef ref)? action;
}

/// Temporary body of a screen file that is not built yet (task 3.1). Each
/// screen task replaces it with the real screen. It names the Figma frame
/// and the task that builds it, and offers [links] along the designed flow,
/// so the app can be clicked through before the screens exist.
class ScreenPlaceholder extends ConsumerWidget {
  const ScreenPlaceholder({
    super.key,
    required this.title,
    required this.frame,
    required this.task,
    this.details = const [],
    this.links = const [],
  });

  final String title;

  /// Figma frame number(s), e.g. `8` or `124–126`.
  final String frame;

  /// Task that builds the screen, e.g. `5.1`.
  final String task;

  /// Extra lines, such as route parameters.
  final List<String> details;

  final List<PlaceholderLink> links;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final canPop = context.canPop();
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            AppNavbarTop(
              title: title,
              onBack: canPop ? () => context.pop() : null,
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(AppSpacing.xl),
                children: [
                  Text(
                    'Frame $frame · task $task',
                    style: AppTypography.c1.copyWith(
                      color: context.colors.textGrey,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(title, style: AppTypography.h5),
                  for (final line in details) ...[
                    const SizedBox(height: AppSpacing.xs),
                    Text(line, style: AppTypography.b3),
                  ],
                  const SizedBox(height: AppSpacing.xl),
                  for (final link in links) ...[
                    AppButton(
                      label: link.label,
                      style: AppButtonStyle.outline,
                      expand: true,
                      onPressed: () {
                        link.action?.call(ref);
                        if (link.replace) {
                          context.go(link.location);
                        } else {
                          context.push(link.location);
                        }
                      },
                    ),
                    const SizedBox(height: AppSpacing.sm),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
