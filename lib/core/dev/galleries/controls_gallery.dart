import 'package:flutter/material.dart';

import '../../assets/app_icons.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../../widgets/inputs/app_dropdown.dart';
import '../../widgets/inputs/app_stepper.dart';
import '../../widgets/inputs/app_text_field.dart';
import '../../widgets/navigation/app_tabs.dart';

const _labelWidth = 100.0;

Widget _title(String text) => Padding(
  padding: const EdgeInsets.only(bottom: AppSpacing.xs),
  child: Text(text, style: AppTypography.s2),
);

/// Owns a [WidgetStatesController] that starts in [states].
class _Preset extends StatefulWidget {
  const _Preset({required this.states, required this.builder});

  final Set<WidgetState> states;
  final Widget Function(WidgetStatesController controller) builder;

  @override
  State<_Preset> createState() => _PresetState();
}

class _PresetState extends State<_Preset> {
  late final _states = WidgetStatesController({...widget.states});

  @override
  void dispose() {
    _states.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.builder(_states);
}

/// Every [AppTabs] style with the DS states (Default, Hover, Focus, Selected,
/// Disabled; Figma 5248:10271), then bars of 2, 3, 4 and 5 tabs, with icons,
/// counts and the scrollable layout.
class AppTabsMatrix extends StatelessWidget {
  const AppTabsMatrix({super.key});

  static const _barWidth = 360.0;

  static const _states = <(String, Set<WidgetState>, bool, bool)>[
    ('Default', {}, false, true),
    ('Hover', {WidgetState.hovered}, false, true),
    ('Focus', {WidgetState.focused}, false, true),
    ('Selected', {}, true, true),
    ('Disabled', {}, false, false),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final style in AppTabsStyle.values) ...[
          _title(style.name),
          for (final (name, states, selected, enabled) in _states)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: Row(
                children: [
                  SizedBox(
                    width: _labelWidth,
                    child: Text(name, style: AppTypography.b3),
                  ),
                  SizedBox(
                    width: 260,
                    child: _Preset(
                      states: states,
                      builder: (controller) => AppTabs(
                        style: style,
                        selectedIndex: selected ? 0 : 1,
                        onChanged: (_) {},
                        tabs: [
                          AppTabItem(
                            label: 'Label',
                            icon: AppIcons.star,
                            enabled: enabled,
                            statesController: controller,
                          ),
                          const AppTabItem(label: 'Other'),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: AppSpacing.md),
        ],
        _title('bars'),
        const _Bars(),
      ],
    );
  }
}

class _Bars extends StatefulWidget {
  const _Bars();

  @override
  State<_Bars> createState() => _BarsState();
}

class _BarsState extends State<_Bars> {
  static const _reader = ['Read', 'Visual', 'Listen', 'Summary'];
  static const _study = ['My Materials', 'My Classes'];
  static const _five = ['Tab 1', 'Tab 2', 'Tab 3', 'Tab 4', 'Tab 5'];

  final _selected = <String, int>{};

  Widget _bar(
    String id,
    AppTabsStyle style,
    List<String> labels, {
    bool icons = false,
    bool counts = false,
    bool scrollable = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: SizedBox(
        width: AppTabsMatrix._barWidth,
        child: AppTabs(
          style: style,
          scrollable: scrollable,
          selectedIndex: _selected[id] ?? 0,
          onChanged: (i) => setState(() => _selected[id] = i),
          tabs: [
            for (var i = 0; i < labels.length; i++)
              AppTabItem(
                label: labels[i],
                icon: icons ? AppIcons.star : null,
                count: counts ? i + 2 : null,
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _bar('study', AppTabsStyle.underline, _study),
        _bar('reader', AppTabsStyle.pill, _reader),
        _bar('five-segment', AppTabsStyle.segment, _five),
        _bar('five-underline', AppTabsStyle.underline, _five, counts: true),
        _bar('five-pill', AppTabsStyle.pill, _five),
        _bar('icons', AppTabsStyle.segment, _reader.sublist(0, 3), icons: true),
        _bar('scroll', AppTabsStyle.pill, const [
          'Everything',
          'Classes',
          'Materials',
          'People',
          'Quizzes',
        ], scrollable: true),
      ],
    );
  }
}

/// [AppDropdown] states like the DS sheet (Figma 5248:10319: Default, Hover,
/// Expanded, Disabled, Selected), the error and accent variants, and the
/// "Expanded Menu (5 Rows)" panel.
class AppDropdownMatrix extends StatelessWidget {
  const AppDropdownMatrix({super.key});

  static const _cellWidth = 350.0;

  static const _items = [
    AppDropdownItem(value: 1, label: 'Option 1', icon: AppIcons.star),
    AppDropdownItem(value: 2, label: 'Option 2', icon: AppIcons.star),
    AppDropdownItem(value: 3, label: 'Option 3', icon: AppIcons.star),
    AppDropdownItem(value: 4, label: 'Option 4', icon: AppIcons.star),
    AppDropdownItem(value: 5, label: 'Option 5', icon: AppIcons.star),
  ];

  Widget _row(String name, Widget cell, {double extra = 0}) => Padding(
    padding: EdgeInsets.only(bottom: AppSpacing.md + extra),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: _labelWidth,
          child: Padding(
            padding: const EdgeInsets.only(top: AppSpacing.xl),
            child: Text(name, style: AppTypography.b3),
          ),
        ),
        SizedBox(width: _cellWidth, child: cell),
      ],
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _title('Large'),
        _row(
          'Default',
          AppDropdown<int>(
            label: 'Label',
            placeholder: 'Select',
            leadingIcon: AppIcons.star,
            helperText: 'Helper Text',
            items: _items,
            value: null,
            onChanged: (_) {},
          ),
        ),
        _row(
          'Hover',
          _Preset(
            states: const {WidgetState.hovered},
            builder: (controller) => AppDropdown<int>(
              label: 'Label',
              placeholder: 'Select',
              leadingIcon: AppIcons.star,
              items: _items,
              value: null,
              onChanged: (_) {},
              statesController: controller,
            ),
          ),
        ),
        _row(
          'Focus',
          _Preset(
            states: const {WidgetState.focused},
            builder: (controller) => AppDropdown<int>(
              label: 'Label',
              placeholder: 'Select',
              leadingIcon: AppIcons.star,
              items: _items,
              value: null,
              onChanged: (_) {},
              statesController: controller,
            ),
          ),
        ),
        _row(
          'Selected',
          AppDropdown<int>(
            label: 'Label',
            placeholder: 'Select',
            items: _items,
            value: 2,
            onChanged: (_) {},
          ),
        ),
        _row(
          'Disabled',
          const AppDropdown<int>(
            label: 'Label',
            placeholder: 'Select',
            leadingIcon: AppIcons.star,
            helperText: 'Helper Text',
            items: _items,
            value: null,
            onChanged: null,
          ),
        ),
        _row(
          'Error',
          AppDropdown<int>(
            label: 'Label',
            placeholder: 'Select',
            errorText: 'Pick an option',
            items: _items,
            value: null,
            onChanged: (_) {},
          ),
        ),
        _row(
          'Accent',
          AppDropdown<int>(
            placeholder: 'Select',
            accentColor: AppColors.plume300,
            items: _items,
            value: null,
            onChanged: (_) {},
          ),
        ),
        _row(
          'Medium',
          AppDropdown<int>(
            placeholder: 'Select',
            size: AppTextFieldSize.medium,
            items: _items,
            value: 3,
            onChanged: (_) {},
          ),
        ),
        _title('Expanded'),
        _row(
          'Expanded',
          AppDropdown<int>(
            placeholder: 'Select',
            leadingIcon: AppIcons.star,
            items: _items,
            value: 2,
            onChanged: (_) {},
            initiallyOpen: true,
          ),
          extra: 300,
        ),
        _title('Expanded Menu (5 Rows)'),
        Row(
          children: [
            const SizedBox(width: _labelWidth),
            SizedBox(
              width: _cellWidth,
              child: AppDropdownMenu<int>(
                items: _items,
                value: 2,
                hoveredIndex: 3,
                onSelected: (_) {},
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// [AppStepper] in both styles (Figma 5248:10391), bare like the DS and with
/// the value, at the middle and at both limits, and disabled.
class AppStepperMatrix extends StatelessWidget {
  const AppStepperMatrix({super.key});

  @override
  Widget build(BuildContext context) {
    Widget cell(String name, Widget child) => Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        children: [
          SizedBox(
            width: _labelWidth + 40,
            child: Text(name, style: AppTypography.b3),
          ),
          child,
        ],
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final style in AppStepperStyle.values) ...[
          _title(style.name),
          cell(
            'DS (no value)',
            AppStepper(
              value: 5,
              onChanged: (_) {},
              style: style,
              showValue: false,
            ),
          ),
          cell('Value', AppStepper(value: 5, onChanged: (_) {}, style: style)),
          cell('At min', AppStepper(value: 0, onChanged: (_) {}, style: style)),
          cell(
            'At max',
            AppStepper(value: 10, max: 10, onChanged: (_) {}, style: style),
          ),
          cell('Disabled', AppStepper(value: 5, onChanged: null, style: style)),
          const SizedBox(height: AppSpacing.md),
        ],
      ],
    );
  }
}
