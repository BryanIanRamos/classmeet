import 'package:flutter/material.dart';

import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../../widgets/selection/app_checkbox.dart';
import '../../widgets/selection/app_radio.dart';
import '../../widgets/selection/app_toggle.dart';
import '../../widgets/selection/selectable_card.dart';
import '../../widgets/selection/selection_support.dart';

void _noop() {}

/// One matrix row: a state label, the preset states, and whether the control
/// is enabled (disabled means a null callback).
class _Row {
  const _Row(
    this.label,
    this.states, {
    this.enabled = true,
    this.selected = false,
    this.indeterminate = false,
  });

  final String label;
  final Set<WidgetState> states;
  final bool enabled;
  final bool selected;
  final bool indeterminate;
}

typedef _CellBuilder = Widget Function(_Row row, WidgetStatesController c);

/// A DS-sheet-like table: state labels on the left, one column per variant.
class _Matrix extends StatelessWidget {
  const _Matrix({
    required this.title,
    required this.rows,
    required this.columns,
  });

  final String title;
  final List<_Row> rows;
  final Map<String, _CellBuilder> columns;

  static const _labelWidth = 120.0;
  static const _rowHeight = 56.0;
  static const _columnGap = AppSpacing.xl;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AppTypography.h5),
        const SizedBox(height: AppSpacing.md),
        Table(
          defaultColumnWidth: const IntrinsicColumnWidth(),
          columnWidths: const {0: FixedColumnWidth(_labelWidth)},
          children: [
            TableRow(
              children: [
                const SizedBox.shrink(),
                for (final name in columns.keys)
                  Padding(
                    padding: const EdgeInsets.only(right: _columnGap),
                    child: Text(name, style: AppTypography.b3),
                  ),
              ],
            ),
            for (final row in rows)
              TableRow(
                children: [
                  SizedBox(
                    height: _rowHeight,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(row.label, style: AppTypography.b1),
                    ),
                  ),
                  for (final build in columns.values)
                    SizedBox(
                      height: _rowHeight,
                      child: Padding(
                        padding: const EdgeInsets.only(right: _columnGap),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: _Preset(
                            states: row.states,
                            builder: (controller) => build(row, controller),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
          ],
        ),
      ],
    );
  }
}

/// Owns a [WidgetStatesController] that starts in [states].
class _Preset extends StatefulWidget {
  const _Preset({required this.states, required this.builder});

  final Set<WidgetState> states;
  final Widget Function(WidgetStatesController controller) builder;

  @override
  State<_Preset> createState() => _PresetState();
}

class _PresetState extends State<_Preset> {
  late final _controller = WidgetStatesController({...widget.states});

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.builder(_controller);
}

const _hover = {WidgetState.hovered};
const _focus = {WidgetState.focused};

/// [AppRadio] states x (control, `+ Text` left, `+ Text` right), as the DS
/// Radio sheet (5248:1974).
class AppRadioMatrix extends StatelessWidget {
  const AppRadioMatrix({super.key});

  static const _rows = [
    _Row('Default', {}),
    _Row('Hover', _hover),
    _Row('Focus', _focus),
    _Row('Selected', {}, selected: true),
    _Row('Disabled', {}, enabled: false),
  ];

  Widget _radio(
    _Row r,
    WidgetStatesController c, {
    String? label,
    AppTextSide side = AppTextSide.left,
  }) => AppRadio<int>(
    value: 1,
    groupValue: r.selected ? 1 : 0,
    onChanged: r.enabled ? (_) {} : null,
    label: label,
    textSide: side,
    statesController: c,
  );

  @override
  Widget build(BuildContext context) {
    return _Matrix(
      title: 'Radio',
      rows: _rows,
      columns: {
        'Radio': _radio,
        'Text left': (r, c) => _radio(r, c, label: 'Placeholder'),
        'Text right': (r, c) =>
            _radio(r, c, label: 'Placeholder', side: AppTextSide.right),
      },
    );
  }
}

/// [AppCheckbox] states x (control, `+ Text` left, `+ Text` right), as the DS
/// Checkbox sheet (5248:1446), plus the small size.
class AppCheckboxMatrix extends StatelessWidget {
  const AppCheckboxMatrix({super.key});

  static const _rows = [
    _Row('Default', {}),
    _Row('Hover', _hover),
    _Row('Focus', _focus),
    _Row('Selected', {}, selected: true),
    _Row('Indeterminate', {}, indeterminate: true),
    _Row('Disabled', {}, enabled: false),
  ];

  Widget _box(
    _Row r,
    WidgetStatesController c, {
    String? label,
    AppTextSide side = AppTextSide.left,
    AppCheckboxSize size = AppCheckboxSize.medium,
  }) => AppCheckbox(
    value: r.indeterminate ? null : r.selected,
    onChanged: r.enabled ? (_) {} : null,
    label: label,
    textSide: side,
    size: size,
    statesController: c,
  );

  @override
  Widget build(BuildContext context) {
    return _Matrix(
      title: 'Checkbox',
      rows: _rows,
      columns: {
        'Checkbox': _box,
        'Text left': (r, c) => _box(r, c, label: 'Placeholder'),
        'Text right': (r, c) =>
            _box(r, c, label: 'Placeholder', side: AppTextSide.right),
        'Small': (r, c) => _box(r, c, size: AppCheckboxSize.small),
      },
    );
  }
}

/// [AppToggle] states x (off, on, `+ Text` left, `+ Text` right), as the DS
/// Toggle sheet (5248:2021).
class AppToggleMatrix extends StatelessWidget {
  const AppToggleMatrix({super.key});

  static const _rows = [
    _Row('Default', {}),
    _Row('Hover', _hover),
    _Row('Focus', _focus),
    _Row('Disabled', {}, enabled: false),
  ];

  Widget _toggle(
    _Row r,
    WidgetStatesController c, {
    bool on = false,
    String? label,
    AppTextSide side = AppTextSide.left,
  }) => AppToggle(
    value: on,
    onChanged: r.enabled ? (_) {} : null,
    label: label,
    textSide: side,
    statesController: c,
  );

  @override
  Widget build(BuildContext context) {
    return _Matrix(
      title: 'Toggle',
      rows: _rows,
      columns: {
        'Off': _toggle,
        'On': (r, c) => _toggle(r, c, on: true),
        'Text left': (r, c) => _toggle(r, c, label: 'Placeholder'),
        'Text right': (r, c) =>
            _toggle(r, c, label: 'Placeholder', side: AppTextSide.right),
      },
    );
  }
}

/// [SelectableCard] selected, unselected, disabled and radio-style, with the
/// goal-grid copy of the "Learning preferences" screen.
class SelectableCardMatrix extends StatelessWidget {
  const SelectableCardMatrix({super.key});

  static const _cardWidth = 180.0;

  @override
  Widget build(BuildContext context) {
    Widget cell(Widget card) => SizedBox(width: _cardWidth, child: card);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Selectable card', style: AppTypography.h5),
        const SizedBox(height: AppSpacing.md),
        Wrap(
          spacing: AppSpacing.md,
          runSpacing: AppSpacing.md,
          children: [
            cell(
              const SelectableCard(
                title: '15 min',
                description: 'A little each day',
                selected: true,
                onTap: _noop,
              ),
            ),
            cell(
              const SelectableCard(
                title: '30 min',
                description: 'Stay on track',
                selected: false,
                onTap: _noop,
              ),
            ),
            cell(
              const SelectableCard(
                title: '40 min',
                description: 'More progress',
                selected: true,
                onTap: _noop,
                indicator: SelectableCardIndicator.radio,
              ),
            ),
            cell(
              const SelectableCard(
                title: '60 min',
                description: 'Go deeper',
                selected: false,
                onTap: _noop,
                indicator: SelectableCardIndicator.radio,
              ),
            ),
            cell(
              const SelectableCard(
                title: 'Disabled',
                description: 'Not available',
                selected: false,
                onTap: null,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// All selection matrices, stacked; used by the golden and `/dev/widgets`.
class SelectionGallery extends StatelessWidget {
  const SelectionGallery({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppRadioMatrix(),
        SizedBox(height: AppSpacing.xl),
        AppCheckboxMatrix(),
        SizedBox(height: AppSpacing.xl),
        AppToggleMatrix(),
        SizedBox(height: AppSpacing.xl),
        SelectableCardMatrix(),
      ],
    );
  }
}
