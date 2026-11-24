import 'package:flutter/material.dart';

import '../../assets/app_icons.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../../widgets/inputs/app_text_field.dart';

/// Every [AppTextField] style × state × size, laid out like the DS sheet
/// (Figma 5248:2176: state labels on the left, one column per size, 350 wide
/// cells with label, input, helper text), followed by the password and
/// search variants.
class AppTextFieldMatrix extends StatelessWidget {
  const AppTextFieldMatrix({super.key});

  static const _labelWidth = 100.0;
  static const _cellWidth = 350.0;

  static const _states = <_Row>[
    _Row('Default', {}),
    _Row('Filled', {}, text: 'Typed text'),
    _Row('Hover', {WidgetState.hovered}),
    _Row('Focus', {WidgetState.focused}, text: 'Typing'),
    _Row('Disabled', {}, enabled: false),
    _Row('Success', {}, status: AppTextFieldStatus.success),
    _Row('Info', {}, status: AppTextFieldStatus.info),
    _Row('Warning', {}, status: AppTextFieldStatus.warning),
    _Row('Error', {}, status: AppTextFieldStatus.error),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final style in AppTextFieldStyle.values) ...[
          Text(style.name, style: AppTypography.s2),
          const SizedBox(height: AppSpacing.xs),
          Table(
            defaultColumnWidth: const FixedColumnWidth(_cellWidth),
            columnWidths: const {0: FixedColumnWidth(_labelWidth)},
            children: [
              TableRow(
                children: [
                  const SizedBox.shrink(),
                  for (final size in AppTextFieldSize.values)
                    Text(size.name, style: AppTypography.b3),
                ],
              ),
              for (final row in _states)
                TableRow(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: AppSpacing.xl),
                      child: Text(row.name, style: AppTypography.b3),
                    ),
                    for (final size in AppTextFieldSize.values)
                      Padding(
                        padding: const EdgeInsets.only(
                          right: AppSpacing.xl,
                          bottom: AppSpacing.md,
                        ),
                        child: _Cell(row: row, size: size, style: style),
                      ),
                  ],
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
        ],
        const Text('variants', style: AppTypography.s2),
        const SizedBox(height: AppSpacing.xs),
        const Wrap(
          spacing: AppSpacing.xl,
          runSpacing: AppSpacing.md,
          children: [
            SizedBox(
              width: _cellWidth,
              child: AppTextField.password(
                label: 'Password',
                placeholder: 'Password',
              ),
            ),
            SizedBox(
              width: _cellWidth,
              child: AppTextField.search(placeholder: 'Search materials...'),
            ),
            SizedBox(
              width: _cellWidth,
              child: _Preset(
                states: {WidgetState.focused},
                text: 'algebra',
                builder: _searchWithText,
              ),
            ),
            SizedBox(
              width: _cellWidth,
              child: AppTextField(
                label: 'Email',
                placeholder: 'Email',
                errorText: 'Enter a valid email',
              ),
            ),
          ],
        ),
      ],
    );
  }

  static Widget _searchWithText(
    WidgetStatesController controller,
    TextEditingController text,
  ) => AppTextField.search(controller: text, statesController: controller);
}

class _Row {
  const _Row(
    this.name,
    this.states, {
    this.text,
    this.enabled = true,
    this.status = AppTextFieldStatus.none,
  });

  final String name;
  final Set<WidgetState> states;
  final String? text;
  final bool enabled;
  final AppTextFieldStatus status;
}

class _Cell extends StatelessWidget {
  const _Cell({required this.row, required this.size, required this.style});

  final _Row row;
  final AppTextFieldSize size;
  final AppTextFieldStyle style;

  @override
  Widget build(BuildContext context) {
    final helper = switch (row.status) {
      AppTextFieldStatus.success => 'Success Text',
      AppTextFieldStatus.info => 'Info Text',
      AppTextFieldStatus.warning => 'Warning Text',
      AppTextFieldStatus.error => 'Error Text',
      AppTextFieldStatus.none => 'Helper Text',
    };
    return _Preset(
      states: row.states,
      text: row.text,
      builder: (controller, text) => AppTextField(
        controller: text,
        label: 'Label',
        placeholder: 'Placeholder',
        helperText: helper,
        status: row.status,
        size: size,
        style: style,
        enabled: row.enabled,
        prefixIcon: AppIcons.star,
        suffixIcon: AppIcons.chevronDown,
        statesController: controller,
      ),
    );
  }
}

/// Owns a [WidgetStatesController] that starts in [states], and a text
/// controller holding [text].
class _Preset extends StatefulWidget {
  const _Preset({required this.states, required this.builder, this.text});

  final Set<WidgetState> states;
  final String? text;
  final Widget Function(
    WidgetStatesController controller,
    TextEditingController text,
  )
  builder;

  @override
  State<_Preset> createState() => _PresetState();
}

class _PresetState extends State<_Preset> {
  late final _states = WidgetStatesController({...widget.states});
  late final _text = TextEditingController(text: widget.text);

  @override
  void dispose() {
    _states.dispose();
    _text.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.builder(_states, _text);
}
