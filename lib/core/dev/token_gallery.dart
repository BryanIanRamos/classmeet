import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_gradients.dart';
import '../theme/app_radii.dart';
import '../theme/app_semantic_colors.dart';
import '../theme/app_shadows.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

/// Debug-only gallery of every design token (`/dev/tokens`), for comparing
/// the theme with the Figma Design System sheets.
class TokenGallery extends StatelessWidget {
  const TokenGallery({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Design tokens')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const _Section('Palette'),
            for (final MapEntry(key: family, value: shades)
                in AppColors.families.entries)
              _SwatchGroup(
                title: family,
                swatches: {
                  for (final MapEntry(key: shade, value: color)
                      in shades.entries)
                    '$shade': color,
                },
              ),
            const _SwatchGroup(title: 'Overlays', swatches: AppColors.overlays),
            const _Section('Semantic roles'),
            for (final MapEntry(key: name, value: color)
                in context.colors.byFigmaName.entries)
              _RoleRow(name: name, color: color),
            const _Section('Typography'),
            for (final MapEntry(key: name, value: style)
                in AppTypography.byFigmaName.entries)
              _TypeSample(name: name, style: style),
            const _Section('Spacing'),
            for (final MapEntry(key: name, value: value)
                in AppSpacing.byFigmaName.entries)
              _SpacingRow(name: name, value: value),
            const _Section('Corner radius'),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                for (final MapEntry(key: name, value: radius)
                    in AppRadii.byFigmaName.entries)
                  _RadiusTile(name: name, radius: radius),
              ],
            ),
            const _Section('Shadows'),
            Wrap(
              spacing: AppSpacing.lg,
              runSpacing: AppSpacing.lg,
              children: [
                for (final MapEntry(key: name, value: shadows)
                    in AppShadows.byFigmaName.entries)
                  _ShadowTile(name: name, shadows: shadows),
              ],
            ),
            const _Section('Surface Fade'),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                for (final (name, color) in const [
                  ('sage100', AppColors.sage100),
                  ('sprout100', AppColors.sprout100),
                  ('talon100', AppColors.talon100),
                  ('plume50', AppColors.plume50),
                ])
                  _FadeTile(name: name, color: color),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// `#RRGGBB`, or `#RRGGBBAA` when translucent (the Figma notation).
String figmaHex(Color color) {
  final argb = color.toARGB32();
  final alpha = argb >>> 24;
  final rgb = (argb & 0xFFFFFF).toRadixString(16).padLeft(6, '0');
  final suffix = alpha == 0xFF ? '' : alpha.toRadixString(16).padLeft(2, '0');
  return '#$rgb$suffix'.toUpperCase();
}

class _Section extends StatelessWidget {
  const _Section(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.xl, bottom: AppSpacing.sm),
      child: Text(title, style: AppTypography.h5),
    );
  }
}

class _SwatchGroup extends StatelessWidget {
  const _SwatchGroup({required this.title, required this.swatches});

  final String title;
  final Map<String, Color> swatches;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTypography.s2),
          const SizedBox(height: AppSpacing.xs),
          Wrap(
            spacing: AppSpacing.xs,
            runSpacing: AppSpacing.sm,
            children: [
              for (final MapEntry(key: label, value: color) in swatches.entries)
                _Swatch(label: label, color: color),
            ],
          ),
        ],
      ),
    );
  }
}

class _Swatch extends StatelessWidget {
  const _Swatch({required this.label, required this.color});

  static const _width = 72.0;

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: _width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ColorBox(color: color, width: _width, height: 40),
          const SizedBox(height: AppSpacing.xxs),
          Text(label, style: AppTypography.c2),
          Text(
            figmaHex(color),
            style: AppTypography.c3.copyWith(
              color: context.colors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _ColorBox extends StatelessWidget {
  const _ColorBox({
    required this.color,
    required this.width,
    required this.height,
  });

  final Color color;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color,
        border: Border.all(color: AppColors.grey200),
        borderRadius: const BorderRadius.all(Radius.circular(AppRadii.xs)),
      ),
    );
  }
}

class _RoleRow extends StatelessWidget {
  const _RoleRow({required this.name, required this.color});

  final String name;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: Row(
        children: [
          _ColorBox(color: color, width: 32, height: 32),
          const SizedBox(width: AppSpacing.sm),
          Expanded(child: Text(name, style: AppTypography.b4)),
          Text(
            figmaHex(color),
            style: AppTypography.c1.copyWith(
              color: context.colors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _TypeSample extends StatelessWidget {
  const _TypeSample({required this.name, required this.style});

  final String name;
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    final size = style.fontSize!;
    final lineHeight = (size * style.height!).round();
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$name · ${style.fontFamily} ${size.round()}/$lineHeight · '
            '${style.fontWeight!.value}',
            style: AppTypography.c1.copyWith(
              color: context.colors.textSecondary,
            ),
          ),
          Text('Pick up where you left off', style: style),
        ],
      ),
    );
  }
}

class _SpacingRow extends StatelessWidget {
  const _SpacingRow({required this.name, required this.value});

  final String name;
  final double value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: Row(
        children: [
          SizedBox(width: 48, child: Text(name, style: AppTypography.b4)),
          Container(width: value, height: 16, color: AppColors.sage300),
          const SizedBox(width: AppSpacing.xs),
          Text('${value.round()}', style: AppTypography.c1),
        ],
      ),
    );
  }
}

class _ShadowTile extends StatelessWidget {
  const _ShadowTile({required this.name, required this.shadows});

  static const _size = 72.0;

  final String name;
  final List<BoxShadow> shadows;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: _size,
          height: _size,
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: const BorderRadius.all(Radius.circular(AppRadii.xs)),
            boxShadow: shadows,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(name, style: AppTypography.c2),
      ],
    );
  }
}

class _FadeTile extends StatelessWidget {
  const _FadeTile({required this.name, required this.color});

  final String name;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            gradient: AppGradients.fade(color),
            border: Border.all(color: AppColors.grey200),
            borderRadius: const BorderRadius.all(Radius.circular(AppRadii.xs)),
          ),
        ),
        const SizedBox(height: AppSpacing.xxs),
        Text(name, style: AppTypography.c2),
      ],
    );
  }
}

class _RadiusTile extends StatelessWidget {
  const _RadiusTile({required this.name, required this.radius});

  static const _size = 64.0;

  final String name;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: _size,
          height: _size,
          decoration: BoxDecoration(
            color: AppColors.sage100,
            border: Border.all(color: AppColors.sage500),
            borderRadius: BorderRadius.all(Radius.circular(radius)),
          ),
        ),
        const SizedBox(height: AppSpacing.xxs),
        Text('$name · ${radius.round()}', style: AppTypography.c2),
      ],
    );
  }
}
