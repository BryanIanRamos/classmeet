import 'package:flutter/material.dart';

import '../assets/app_icons.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import '../widgets/buttons/app_button.dart';

/// Debug-only gallery of the design-system widgets (`/dev/widgets`). Task 2.14
/// adds the other widgets and compares each section with the DS sheets.
class WidgetGallery extends StatelessWidget {
  const WidgetGallery({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Widgets')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: const [
          Text('Button', style: AppTypography.h5),
          SizedBox(height: AppSpacing.sm),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: AppButtonMatrix(),
          ),
        ],
      ),
    );
  }
}

/// Every [AppButton] style × state × size, laid out like the DS sheet
/// (Figma 5248:660: state labels on the left, 88-high rows, one column per
/// size with the labelled button and the icon-only one) for side-by-side
/// comparison. Columns size to their widest cell, so no font can overflow
/// them.
class AppButtonMatrix extends StatelessWidget {
  const AppButtonMatrix({super.key});

  /// Preset states per row; null means disabled.
  static const states = <String, Set<WidgetState>?>{
    'Default': {},
    'Hover': {WidgetState.hovered},
    'Focus': {WidgetState.focused},
    'Press': {WidgetState.pressed},
    'Disabled': null,
  };

  static const _labelWidth = 100.0;
  static const _rowHeight = 88.0;
  static const _inset = AppSpacing.lg;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final style in AppButtonStyle.values) ...[
          Text(style.name, style: AppTypography.s2),
          Table(
            defaultColumnWidth: const IntrinsicColumnWidth(),
            columnWidths: const {0: FixedColumnWidth(_labelWidth)},
            children: [
              TableRow(
                children: [
                  const SizedBox.shrink(),
                  for (final size in AppButtonSize.values)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: _inset),
                      child: Text(size.name, style: AppTypography.b3),
                    ),
                ],
              ),
              for (final MapEntry(key: label, value: preset) in states.entries)
                TableRow(
                  children: [
                    SizedBox(
                      height: _rowHeight,
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(label, style: AppTypography.b3),
                      ),
                    ),
                    for (final size in AppButtonSize.values)
                      SizedBox(
                        height: _rowHeight,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: _inset,
                          ),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: _Cell(
                              size: size,
                              style: style,
                              preset: preset,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
        ],
      ],
    );
  }
}

void _noop() {}

class _Cell extends StatelessWidget {
  const _Cell({required this.size, required this.style, required this.preset});

  final AppButtonSize size;
  final AppButtonStyle style;
  final Set<WidgetState>? preset;

  @override
  Widget build(BuildContext context) {
    final onPressed = preset == null ? null : _noop;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _Preset(
          states: preset ?? const {},
          builder: (controller) => AppButton(
            label: 'Button',
            onPressed: onPressed,
            size: size,
            style: style,
            leadingIcon: AppIcons.arrowLeft,
            trailingIcon: AppIcons.arrowRight,
            statesController: controller,
          ),
        ),
        const SizedBox(width: AppSpacing.xl),
        _Preset(
          states: preset ?? const {},
          builder: (controller) => AppButton.icon(
            icon: AppIcons.arrowUp,
            semanticLabel: 'Up',
            onPressed: onPressed,
            size: size,
            style: style,
            statesController: controller,
          ),
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
