import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_semantic_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/buttons/app_button.dart';
import '../../../../core/widgets/inputs/app_text_field.dart';
import '../../../../core/widgets/layout/screen_background.dart';
import '../../../../core/widgets/navigation/app_navbar_top.dart';
import '../../application/join_class_controller.dart';
import '../widgets/join_banner.dart';
import '../widgets/join_confirm_sheet.dart';
import '../widgets/join_info.dart';
import '../widgets/join_scan_card.dart';

/// Join a class (frame 13.1): the "Learn together" banner, the class-code
/// field with its Join button, the "or scan a qr code" card and the notes.
///
/// Typing a code and tapping Join (or the keyboard's done key) looks the class
/// up without joining it and opens a confirmation sheet with its code, name and
/// teacher (provisional, GAP-20). Confirming joins it and opens My Classes;
/// a class the student is in already says so and offers "Open My Classes".
/// The Join button waits while the lookup runs. An unknown code, or any
/// failure, shows a message under the field until the next edit; an empty
/// field asks for the code. The button stays enabled while the field is empty,
/// as the design shows it.
///
/// The scan card opens the QR scanner (a coming-soon page until task 10.4),
/// the "My Classes" link and Back go where they say. Frame 13.2 is the same
/// screen on a Talon-100 background (INC-13) and is not built.
///
/// The page scrolls, banner included, so the keyboard never hides the field
/// or the notes; dragging the page closes the keyboard.
class JoinClassScreen extends ConsumerStatefulWidget {
  const JoinClassScreen({super.key});

  /// Between the scan card's frame and "Before you join": a gap of 24, a 24
  /// spacer and a gap of 24 (spec "Frame 1148"), so the heading sits 88 under
  /// the card with the card frame's own 16.
  static const _beforeInfoGap = AppSpacing.xl * 3;

  @override
  ConsumerState<JoinClassScreen> createState() => _JoinClassScreenState();
}

class _JoinClassScreenState extends ConsumerState<JoinClassScreen> {
  final _field = TextEditingController();

  @override
  void dispose() {
    _field.dispose();
    super.dispose();
  }

  Future<void> _join() async {
    final preview = await ref
        .read(joinClassControllerProvider.notifier)
        .lookUp(_field.text);
    if (preview == null || !mounted) return;
    // The sheet opens at the bottom of the screen: the keyboard goes first.
    FocusScope.of(context).unfocus();
    final openClasses = await showJoinConfirmSheet(context, preview);
    if (openClasses == true && mounted) context.go(Routes.studyClasses);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Scaffold(
      backgroundColor: colors.surfaceWhite,
      body: Column(
        children: [
          SafeArea(
            bottom: false,
            child: AppNavbarTop(
              title: 'Join a class',
              onBack: () => Navigator.maybePop(context),
            ),
          ),
          Expanded(
            child: ScreenBackground(
              child: SingleChildScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                child: SafeArea(
                  top: false,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const JoinBanner(),
                      Padding(
                        // Spec "Frame 1148": padding 16.
                        padding: const EdgeInsets.all(AppSpacing.md),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _codeEntry(),
                            Center(
                              child: Text(
                                'or scan a qr code',
                                style: AppTypography.b3.copyWith(
                                  color: colors.textPrimary,
                                ),
                              ),
                            ),
                            Padding(
                              // Spec "Frame 1171": padding 16.
                              padding: const EdgeInsets.all(AppSpacing.md),
                              child: JoinScanCard(
                                onTap: () => context.push(Routes.joinClassScan),
                              ),
                            ),
                            const SizedBox(
                              height: JoinClassScreen._beforeInfoGap,
                            ),
                            JoinInfo(
                              onMyClasses: () =>
                                  context.go(Routes.studyClasses),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// The code field and the Join button (spec "Frame 1147": padding 16,
  /// gap 16).
  Widget _codeEntry() {
    final state = ref.watch(joinClassControllerProvider);
    final controller = ref.read(joinClassControllerProvider.notifier);
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppTextField(
            controller: _field,
            placeholder: 'Enter code',
            // Spec: a Talon-700 outline and placeholder.
            accentColor: AppColors.talon700,
            errorText: state.error?.message,
            textCapitalization: TextCapitalization.characters,
            // A code, not words: no autocorrect or suggestions.
            autocorrect: false,
            enableSuggestions: false,
            textInputAction: TextInputAction.done,
            onChanged: (_) => controller.edited(),
            onSubmitted: (_) => _join(),
          ),
          const SizedBox(height: AppSpacing.md),
          AppButton(
            label: 'Join',
            tone: AppButtonTone.talon,
            expand: true,
            // Disabled while the lookup runs.
            onPressed: state.busy ? null : _join,
          ),
        ],
      ),
    );
  }
}
