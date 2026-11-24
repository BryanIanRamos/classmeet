import 'package:flutter/material.dart';

import '../../assets/app_icons.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../../widgets/buttons/app_button.dart';
import '../../widgets/display/app_avatar.dart';
import '../../widgets/display/app_badge.dart';
import '../../widgets/display/app_card.dart';
import '../../widgets/display/app_list_row.dart';
import '../../widgets/display/section_header.dart';
import '../../widgets/feedback/app_progress_bar.dart';
import '../../widgets/selection/app_checkbox.dart';
import '../../widgets/selection/app_radio.dart';
import '../../widgets/selection/app_toggle.dart';

/// Width of the DS list sheets (350).
const _sheetWidth = 350.0;

Widget _title(String text) => Padding(
  padding: const EdgeInsets.only(top: AppSpacing.md, bottom: AppSpacing.xs),
  child: Text(text, style: AppTypography.s2),
);

/// Plain (DS) rows sit on the Grey-50 surface of the sheet.
Widget _dsRow(Widget row) => ColoredBox(color: AppColors.grey50, child: row);

/// [AppListRow] left and right slot variants, laid out like the DS sheet
/// (Figma 5248:10403) with the Home list cards below.
class AppListRowMatrix extends StatefulWidget {
  const AppListRowMatrix({super.key});

  @override
  State<AppListRowMatrix> createState() => _AppListRowMatrixState();
}

class _AppListRowMatrixState extends State<AppListRowMatrix> {
  bool _checked = true;
  bool _toggled = true;
  int _radio = 1;

  AppListRow _plain(
    String title, {
    Widget? trailing,
    bool chevron = false,
    bool divider = false,
  }) => AppListRow(
    style: AppListRowStyle.plain,
    title: title,
    trailing: trailing,
    showChevron: chevron,
    leadingIcon: AppIcons.star,
    showDivider: divider,
  );

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: _sheetWidth,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _title('Left item'),
          _dsRow(_plain('Icon + Text')),
          _dsRow(
            const AppListRow(
              style: AppListRowStyle.plain,
              title: 'Avatar + Text',
              leading: AppAvatar.letter(letter: 'A'),
            ),
          ),
          _title('Right item'),
          _dsRow(
            const AppListRow(
              style: AppListRowStyle.plain,
              title: 'Text + Icon',
              trailingText: 'Details',
              showChevron: true,
            ),
          ),
          _dsRow(
            _plain(
              'Badge + Icon',
              chevron: true,
              trailing: const AppBadge(
                label: '5',
                tone: AppBadgeTone.error,
                style: AppBadgeStyle.filled,
              ),
            ),
          ),
          _dsRow(
            _plain(
              'Toggle',
              trailing: AppToggle(
                value: _toggled,
                onChanged: (v) => setState(() => _toggled = v),
              ),
            ),
          ),
          _dsRow(
            _plain(
              'Radio',
              trailing: AppRadio<int>(
                value: 1,
                groupValue: _radio,
                onChanged: (v) => setState(() => _radio = v),
              ),
            ),
          ),
          _dsRow(
            _plain(
              'Checkbox',
              trailing: AppCheckbox(
                value: _checked,
                onChanged: (v) => setState(() => _checked = v),
              ),
            ),
          ),
          _title('Stacked with dividers'),
          _dsRow(
            Column(
              children: [
                _plain('First', chevron: true, divider: true),
                _plain('Second', chevron: true, divider: true),
                _plain('Third', chevron: true),
              ],
            ),
          ),
          _title('Home cards'),
          AppListRow(
            leadingIcon: AppIcons.calendarDays,
            title: 'IT109 Midterm',
            subtitle: '3 activities left · In 5 days',
            showChevron: true,
            bottom: const AppProgressBar(value: 0.67, label: '67%'),
            onTap: () {},
          ),
          const SizedBox(height: AppSpacing.sm),
          AppListRow(
            leadingIcon: AppIcons.brain,
            title: 'General Knowledge Quiz',
            subtitleWidget: const _TalonMeta(),
            showChevron: true,
            onTap: () {},
          ),
        ],
      ),
    );
  }
}

class _TalonMeta extends StatelessWidget {
  const _TalonMeta();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          '+2 talons',
          style: AppTypography.c1.copyWith(
            color: AppColors.talon500,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(width: AppSpacing.xs),
        Flexible(
          child: Text(
            'Resets at midnight',
            overflow: TextOverflow.ellipsis,
            style: AppTypography.c1.copyWith(color: AppColors.grey500),
          ),
        ),
      ],
    );
  }
}

/// [AppCard] default look, vertical and horizontal-small, laid out like the
/// DS sheet (Figma 5248:10244).
class AppCardMatrix extends StatelessWidget {
  const AppCardMatrix({super.key});

  static const _description =
      'Keep your messages short, but make sure they cover everything you '
      'need to say.';

  Widget _image() => const ColoredBox(color: AppColors.sage50);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: _sheetWidth,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _title('Card: Vertical'),
          AppCard.vertical(
            image: _image(),
            title: 'Title',
            description: _description,
            children: [
              AppButton(label: 'Button', onPressed: () {}, expand: true),
              AppButton(
                label: 'Button',
                onPressed: () {},
                expand: true,
                style: AppButtonStyle.outline,
              ),
            ],
          ),
          _title('Card: Horizontal - Small'),
          AppCard.horizontalSmall(
            image: _image(),
            title: 'Title',
            description: _description,
          ),
          _title('Screen card'),
          const AppCard(child: Text('Any content', style: AppTypography.b1)),
        ],
      ),
    );
  }
}

/// [SectionHeader] with and without link and subtitle (Home, Create).
class SectionHeaderMatrix extends StatelessWidget {
  const SectionHeaderMatrix({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: _sheetWidth,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SectionHeader(
            title: 'Coming up next',
            actionLabel: 'View study plan',
            onActionTap: () {},
          ),
          const SizedBox(height: AppSpacing.md),
          const SectionHeader(title: 'Pick up where you left off'),
          const SizedBox(height: AppSpacing.md),
          SectionHeader(
            title: 'Your daily quests',
            subtitle: 'Complete quests to earn talons',
            actionLabel: 'View all',
            onActionTap: () {},
          ),
        ],
      ),
    );
  }
}
