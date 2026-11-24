import 'package:flutter/material.dart';

import '../../assets/app_icons.dart';
import '../../router/app_bottom_nav.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_semantic_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../../widgets/display/app_avatar.dart';
import '../../widgets/feedback/app_progress_bar.dart';
import '../../widgets/navigation/app_navbar_item.dart';
import '../../widgets/navigation/app_navbar_top.dart';

/// Width of one bar in the sheets (the DS sheet bars are 390 wide).
const _barWidth = 390.0;

/// Every [AppNavbarTop] content variant, laid out like the DS sheet (Figma
/// 5248:1785): the examples column of bars on the DS grey-50 fill, then the
/// screen usages (Home header, back + centered title).
class AppNavbarTopMatrix extends StatelessWidget {
  const AppNavbarTopMatrix({super.key});

  Widget _star(BuildContext context) => AppNavbarItem.icon(
    icon: AppIcons.star,
    semanticLabel: 'Star',
    iconColor: context.colors.iconGrey,
    onTap: () {},
  );

  Widget _bar(Widget bar) => Padding(
    padding: const EdgeInsets.only(bottom: AppSpacing.md),
    child: SizedBox(width: _barWidth, child: bar),
  );

  @override
  Widget build(BuildContext context) {
    final grey = context.colors.surfaceLightGrey;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('DS examples', style: AppTypography.s2),
        const SizedBox(height: AppSpacing.xs),
        _bar(
          AppNavbarTop(
            backgroundColor: grey,
            title: 'Title',
            leading: [
              AppNavbarItem.text(
                label: 'Label',
                icon: AppIcons.chevronLeft,
                onTap: () {},
              ),
            ],
            trailing: [_star(context)],
          ),
        ),
        _bar(
          AppNavbarTop(
            backgroundColor: grey,
            title: 'Title',
            leading: [
              AppNavbarItem.text(
                label: 'Label',
                icon: AppIcons.chevronLeft,
                onTap: () {},
              ),
            ],
            trailing: [_star(context), _star(context)],
          ),
        ),
        _bar(
          AppNavbarTop(
            backgroundColor: grey,
            title: 'Title',
            leading: [
              AppNavbarItem.text(
                label: 'Label',
                icon: AppIcons.chevronLeft,
                onTap: () {},
              ),
            ],
            trailing: [_star(context), _star(context), _star(context)],
          ),
        ),
        _bar(
          AppNavbarTop(
            backgroundColor: grey,
            title: 'Title',
            leading: [AppNavbarItem.text(label: 'Label', onTap: () {})],
            trailing: [_star(context)],
          ),
        ),
        _bar(
          AppNavbarTop(
            backgroundColor: grey,
            title: 'Title',
            onBack: () {},
            trailing: [AppNavbarItem.text(label: 'Label', onTap: () {})],
          ),
        ),
        _bar(
          AppNavbarTop(
            backgroundColor: grey,
            title: 'Title',
            subtitle: 'Secondary Text',
            subtitleColor: context.colors.textGrey,
            leading: [
              AppNavbarItem.text(
                label: 'Label',
                icon: AppIcons.chevronLeft,
                onTap: () {},
              ),
            ],
            trailing: [_star(context)],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        const Text('Screens', style: AppTypography.s2),
        const SizedBox(height: AppSpacing.xs),
        _bar(
          AppNavbarTop(
            showBottomBorder: true,
            avatar: const AppAvatar.letter(letter: 'B'),
            title: 'Good evening, Bryan!',
            subtitle: 'BSIT 2A · CSU',
            trailing: [
              AppNavbarItem.icon(
                icon: AppIcons.bell,
                semanticLabel: 'Notifications',
                onTap: () {},
              ),
            ],
          ),
        ),
        _bar(AppNavbarTop(title: 'Talon credits', onBack: () {})),
        _bar(AppNavbarTop(title: 'Notifications', onBack: () {})),
      ],
    );
  }
}

/// Every [AppProgressBar] state, laid out like the DS sheet (Figma
/// 5248:1858): label left and right columns, disabled, then 0-100%; plus the
/// segmented Home look and the screen tints.
class AppProgressBarMatrix extends StatelessWidget {
  const AppProgressBarMatrix({super.key});

  static const _steps = [0.0, 0.2, 0.4, 0.6, 0.8, 1.0];

  Widget _column(AppProgressBarLabelPosition position) {
    return SizedBox(
      width: 360,
      child: Column(
        children: [
          AppProgressBar(
            value: 0,
            label: '0%',
            labelPosition: position,
            enabled: false,
          ),
          for (final step in _steps) ...[
            const SizedBox(height: AppSpacing.md),
            AppProgressBar(
              value: step,
              label: '${(step * 100).round()}%',
              labelPosition: position,
            ),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _column(AppProgressBarLabelPosition.left),
            const SizedBox(width: AppSpacing.xl),
            _column(AppProgressBarLabelPosition.right),
          ],
        ),
        const SizedBox(height: AppSpacing.xl),
        const Text(
          'Segmented (Home) and screen tints',
          style: AppTypography.s2,
        ),
        const SizedBox(height: AppSpacing.xs),
        const SizedBox(
          width: 368,
          child: Column(
            children: [
              AppProgressBar(value: 0.67, segments: 5, label: '67%'),
              SizedBox(height: AppSpacing.md),
              AppProgressBar(value: 0.4, segments: 5, label: '40%'),
              SizedBox(height: AppSpacing.md),
              AppProgressBar(
                value: 171 / 300,
                label: '171/300',
                color: AppColors.talon500,
                trackColor: AppColors.talon100,
                labelColor: AppColors.talon900,
              ),
              SizedBox(height: AppSpacing.md),
              AppProgressBar(
                value: 0.4,
                color: AppColors.plume500,
                trackColor: AppColors.plume300,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// [AppBottomNav] with each tab selected, and the Create-open state, on a
/// 428 wide page like the screens (frame 8 and 119).
class AppBottomNavMatrix extends StatelessWidget {
  const AppBottomNavMatrix({super.key});

  static const _width = 428.0;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < AppBottomNavTab.values.length; i++) ...[
          Text(
            'Selected: ${AppBottomNavTab.values[i].label}',
            style: AppTypography.c1,
          ),
          const SizedBox(height: AppSpacing.xxs),
          SizedBox(
            width: _width,
            child: AppBottomNav(
              currentIndex: i,
              onTabSelected: (_) {},
              createOpen: false,
              onCreatePressed: () {},
            ),
          ),
          const SizedBox(height: AppSpacing.md),
        ],
        const Text('Create open', style: AppTypography.c1),
        const SizedBox(height: AppSpacing.xxs),
        SizedBox(
          width: _width,
          child: AppBottomNav(
            currentIndex: 0,
            onTabSelected: (_) {},
            createOpen: true,
            onCreatePressed: () {},
          ),
        ),
      ],
    );
  }
}
