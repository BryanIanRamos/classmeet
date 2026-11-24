import 'package:flutter/material.dart';

import '../../assets/app_icons.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_radii.dart';
import '../../theme/app_semantic_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';

/// The ClassMeet bottom sheet panel (screens 91, 119, 128, 129, 133; the DS
/// Action Sheet and Pop-up sheets show the kit's look, the screens win).
///
/// Geometry from the screens: white, 1dp grey-200 border, 24dp top corners,
/// a sage-300 grabber (74 x 3, in a 24dp row), 12dp padding around, 16dp
/// between sections. [child] sits 28dp from the sides (the screens' 12 + 16),
/// [footer] (the action buttons) 24dp. The panel scrolls its [child] when
/// the sheet is taller than the screen; the [footer] stays visible. The
/// bottom keeps the safe-area inset. [title] (B2) and [onClose] (a close
/// button) are optional, for sheets that need a header row.
///
/// Open it with [showAppSheet]; the panel can also be used inline.
class AppSheet extends StatelessWidget {
  const AppSheet({
    super.key,
    this.title,
    this.onClose,
    required this.child,
    this.footer,
    this.showGrabber = true,
  });

  /// Top corner radius (screens: 24).
  static const topRadius = AppRadii.xl;

  /// Grabber line, 74 x 3 in sage-300, centered in a [grabberRowHeight] row.
  static const grabberWidth = 74.0;
  static const grabberThickness = 3.0;
  static const grabberRowHeight = 24.0;

  /// Space above and below the panel content.
  static const padding = AppSpacing.sm;

  /// Gap between grabber, header, content and footer.
  static const gap = AppSpacing.md;

  /// Side inset of [child] (12 + 16 in the screens).
  static const contentInset = AppSpacing.xl + AppSpacing.xxs;

  /// Side inset of [footer].
  static const footerInset = AppSpacing.xl;

  /// Size of the close button's icon.
  static const closeIconSize = 24.0;

  final String? title;

  /// Shows a close button in the header row when set.
  final VoidCallback? onClose;
  final Widget child;

  /// Sticky actions under the scrolling [child].
  final Widget? footer;
  final bool showGrabber;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final hasHeader = title != null || onClose != null;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surfaceWhite,
        border: const Border(
          top: BorderSide(color: AppColors.grey200),
          left: BorderSide(color: AppColors.grey200),
          right: BorderSide(color: AppColors.grey200),
        ),
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(topRadius),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.only(top: padding, bottom: padding),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (showGrabber)
                const SizedBox(
                  height: grabberRowHeight,
                  child: Center(
                    child: SizedBox(
                      key: ValueKey('sheet-grabber'),
                      width: grabberWidth,
                      height: grabberThickness,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: AppColors.sage300,
                          borderRadius: BorderRadius.all(
                            Radius.circular(AppRadii.xl5),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              if (hasHeader) ...[const SizedBox(height: gap), _header(colors)],
              const SizedBox(height: gap),
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: contentInset),
                  child: child,
                ),
              ),
              if (footer != null) ...[
                const SizedBox(height: gap),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: footerInset),
                  child: footer,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _header(AppSemanticColors colors) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: contentInset),
      child: Row(
        children: [
          Expanded(
            child: title == null
                ? const SizedBox.shrink()
                : Semantics(
                    header: true,
                    child: Text(
                      title!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.b2.copyWith(
                        color: colors.textPrimary,
                      ),
                    ),
                  ),
          ),
          if (onClose != null)
            Semantics(
              button: true,
              label: 'Close',
              excludeSemantics: true,
              child: GestureDetector(
                key: const ValueKey('sheet-close'),
                behavior: HitTestBehavior.opaque,
                onTap: onClose,
                child: Icon(
                  AppIcons.x,
                  size: closeIconSize,
                  color: colors.textPrimary,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Opens [builder]'s widget (normally an [AppSheet]) as a modal bottom sheet
/// and returns the value passed to `Navigator.pop`.
///
/// Every Material default is replaced so only tokens show: transparent
/// route surface (the [AppSheet] paints the panel), no elevation, no drag
/// handle (the panel draws its own grabber), full width, and a black 30 %
/// scrim (screens 119, 128, 129; pass [barrierColor] for the 10 % of 91).
/// Scroll-controlled so tall sheets can use the screen height below the
/// status bar. Dismiss by dragging, tapping the scrim or the back key.
Future<T?> showAppSheet<T>(
  BuildContext context, {
  required WidgetBuilder builder,
  bool isScrollControlled = true,
  bool isDismissible = true,
  bool enableDrag = true,
  Color barrierColor = AppColors.black30,
  bool useRootNavigator = false,
  RouteSettings? routeSettings,
}) {
  return showModalBottomSheet<T>(
    context: context,
    builder: builder,
    isScrollControlled: isScrollControlled,
    isDismissible: isDismissible,
    enableDrag: enableDrag,
    showDragHandle: false,
    useSafeArea: true,
    useRootNavigator: useRootNavigator,
    routeSettings: routeSettings,
    backgroundColor: Colors.transparent,
    elevation: 0,
    barrierColor: barrierColor,
    constraints: const BoxConstraints(),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(AppSheet.topRadius),
      ),
    ),
  );
}
