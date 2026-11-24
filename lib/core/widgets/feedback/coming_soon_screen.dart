import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';

import '../../assets/app_images.dart';
import '../../theme/app_semantic_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../navigation/app_navbar_top.dart';
import 'empty_state.dart';

/// Placeholder screen for features that are not designed yet (the design-gap
/// register: Friends, Profile, streak details, …). It never invents a
/// feature: a title, a short note and a way back.
class ComingSoonScreen extends StatelessWidget {
  const ComingSoonScreen({
    super.key,
    required this.title,
    this.message = defaultMessage,
    this.gapId,
    this.showBack = true,
  });

  static const defaultMessage =
      "We're still designing this part of ClassMeet. Check back soon!";

  /// Shown in the navbar, e.g. "Friends".
  final String title;

  final String message;

  /// Design-gap id (e.g. `GAP-06`), shown in debug builds only.
  final String? gapId;

  /// False for tab roots (no back button).
  final bool showBack;

  @override
  Widget build(BuildContext context) {
    final canPop = showBack && Navigator.of(context).canPop();
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            AppNavbarTop(
              title: title,
              onBack: canPop ? () => Navigator.of(context).maybePop() : null,
            ),
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  child: Column(
                    children: [
                      EmptyState(
                        image: AppImages.createReadyOwl,
                        title: 'Coming soon',
                        message: message,
                      ),
                      if (kDebugMode && gapId != null) ...[
                        const SizedBox(height: AppSpacing.md),
                        Text(
                          gapId!,
                          style: AppTypography.c1.copyWith(
                            color: context.colors.textGrey,
                          ),
                        ),
                      ],
                    ],
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
