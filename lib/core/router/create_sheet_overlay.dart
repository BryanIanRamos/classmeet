import 'package:flutter/material.dart';

import '../../features/create/presentation/widgets/create_sheet.dart';
import '../theme/app_colors.dart';

/// The Create overlay inside the tab shell (screens 119 and 120): a scrim
/// over the tab content and the Create sheet pinned to its bottom edge, just
/// above the bottom nav. Place it in a [Stack] that covers the tab content
/// only, so the bar stays visible and tappable.
///
/// A tap on the scrim calls [onClose]. Opening and closing cross-fade; the
/// overlay leaves the tree when closed.
class CreateSheetOverlay extends StatelessWidget {
  const CreateSheetOverlay({
    super.key,
    required this.open,
    required this.onClose,
  });

  final bool open;
  final VoidCallback onClose;

  /// Scrim over the tab content (screens: black at 30%).
  static final scrimColor = AppColors.black.withValues(alpha: 0.3);

  static const fadeDuration = Duration(milliseconds: 200);

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: fadeDuration,
      child: open
          ? Stack(
              key: const ValueKey('create-overlay'),
              children: [
                Positioned.fill(
                  child: Semantics(
                    button: true,
                    label: 'Close create menu',
                    child: GestureDetector(
                      key: const ValueKey('create-scrim'),
                      behavior: HitTestBehavior.opaque,
                      onTap: onClose,
                      child: ColoredBox(color: scrimColor),
                    ),
                  ),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: CreateSheet(onClose: onClose),
                ),
              ],
            )
          : const SizedBox.shrink(key: ValueKey('create-overlay-closed')),
    );
  }
}
