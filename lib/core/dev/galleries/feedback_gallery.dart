import 'package:flutter/material.dart';

import '../../assets/app_icons.dart';
import '../../assets/app_images.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../../widgets/feedback/app_alert.dart';
import '../../widgets/feedback/app_loader.dart';
import '../../widgets/feedback/app_tooltip.dart';
import '../../widgets/feedback/empty_state.dart';
import '../../widgets/feedback/error_state.dart';

const _labelWidth = 100.0;
const _alertWidth = 418.0;
const _toneLabels = {
  AppAlertTone.normal: 'Default',
  AppAlertTone.success: 'Success',
  AppAlertTone.info: 'Info',
  AppAlertTone.warning: 'Warning',
  AppAlertTone.error: 'Error',
};

class _Row extends StatelessWidget {
  const _Row({required this.label, required this.children});

  final String label;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        children: [
          SizedBox(
            width: _labelWidth,
            child: Text(label, style: AppTypography.b3),
          ),
          for (final child in children)
            Padding(
              padding: const EdgeInsets.only(right: AppSpacing.lg),
              child: child,
            ),
        ],
      ),
    );
  }
}

/// Every [AppAlert] style × tone, laid out like the DS sheet (Figma
/// 5248:2071): the outline column, then the filled column; each card has a
/// primary and a secondary action.
class AppAlertMatrix extends StatelessWidget {
  const AppAlertMatrix({super.key});

  @override
  Widget build(BuildContext context) {
    Widget card(AppAlertTone tone, AppAlertStyle style) => SizedBox(
      width: _alertWidth,
      child: AppAlert(
        tone: tone,
        style: style,
        icon: AppIcons.star,
        title: 'Title',
        message: 'Get immediate alerts and a notification badge.',
        actionLabel: 'Button',
        onAction: () {},
        secondaryActionLabel: 'Button',
        onSecondaryAction: () {},
      ),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final tone in AppAlertTone.values)
          _Row(
            label: _toneLabels[tone]!,
            children: [
              card(tone, AppAlertStyle.outline),
              card(tone, AppAlertStyle.filled),
            ],
          ),
        _Row(
          label: 'Closable',
          children: [
            SizedBox(
              width: _alertWidth,
              child: AppAlert(
                tone: AppAlertTone.info,
                icon: AppIcons.star,
                title: 'Heads up',
                message: 'You can dismiss this one.',
                onClose: () {},
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Every [AppLoader] size, static frames, like the DS sheet (5248:1522).
class AppLoaderMatrix extends StatelessWidget {
  const AppLoaderMatrix({super.key, this.animate = false});

  final bool animate;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (final size in AppLoaderSize.values)
          Padding(
            padding: const EdgeInsets.only(right: AppSpacing.xl),
            child: AppLoader(size: size, animate: animate),
          ),
      ],
    );
  }
}

/// Every [AppTooltipBubble] position, like the DS sheet (5248:1502).
class AppTooltipMatrix extends StatelessWidget {
  const AppTooltipMatrix({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final position in [
          AppTooltipPosition.bottom,
          AppTooltipPosition.top,
          AppTooltipPosition.left,
          AppTooltipPosition.right,
        ])
          _Row(
            label: position.name,
            children: [
              AppTooltipBubble(
                message: 'This is a Tooltip',
                position: position,
              ),
            ],
          ),
        const _Row(
          label: 'Long-press',
          children: [
            AppTooltip(
              message: 'Shown on long-press or hover',
              child: Text('Hold me'),
            ),
          ],
        ),
      ],
    );
  }
}

/// [EmptyState] and [ErrorState] (provisional, GAP-21).
class FeedbackStatesMatrix extends StatelessWidget {
  const FeedbackStatesMatrix({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: EmptyState(
            image: AppImages.createReadyOwl,
            title: 'Nothing here yet',
            message: 'Things you add will show up here.',
            actionLabel: 'Create a quiz',
            onAction: () {},
          ),
        ),
        Expanded(child: ErrorState(onRetry: () {})),
      ],
    );
  }
}
