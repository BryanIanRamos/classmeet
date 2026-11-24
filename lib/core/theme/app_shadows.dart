import 'package:flutter/painting.dart';

/// The Design System shadow scale (Figma sheet "Shadow", 5248:1829): two
/// layers of `grey900` at 8–14 % per level. Figma blur and spread map
/// directly to [BoxShadow.blurRadius] and [BoxShadow.spreadRadius].
///
/// No app screen uses a shadow so far (checked in task 1.5); these are for
/// sheets, pop-ups and menus when they need one.
abstract final class AppShadows {
  static const _grey900a8 = Color(0x14131927);
  static const _grey900a10 = Color(0x1A131927);
  static const _grey900a12 = Color(0x1F131927);
  static const _grey900a14 = Color(0x24131927);

  /// Figma `100`.
  static const s100 = [
    BoxShadow(
      color: _grey900a8,
      offset: Offset(0, 4),
      blurRadius: 4,
      spreadRadius: -2,
    ),
    BoxShadow(
      color: _grey900a12,
      offset: Offset(0, 2),
      blurRadius: 4,
      spreadRadius: -2,
    ),
  ];

  /// Figma `200`.
  static const s200 = [
    BoxShadow(
      color: _grey900a8,
      offset: Offset(0, 8),
      blurRadius: 8,
      spreadRadius: -4,
    ),
    BoxShadow(
      color: _grey900a12,
      offset: Offset(0, 4),
      blurRadius: 6,
      spreadRadius: -4,
    ),
  ];

  /// Figma `300`.
  static const s300 = [
    BoxShadow(
      color: _grey900a8,
      offset: Offset(0, 8),
      blurRadius: 16,
      spreadRadius: -6,
    ),
    BoxShadow(
      color: _grey900a12,
      offset: Offset(0, 6),
      blurRadius: 8,
      spreadRadius: -6,
    ),
  ];

  /// Figma `400`.
  static const s400 = [
    BoxShadow(
      color: _grey900a8,
      offset: Offset(0, 8),
      blurRadius: 24,
      spreadRadius: -4,
    ),
    BoxShadow(
      color: _grey900a12,
      offset: Offset(0, 6),
      blurRadius: 12,
      spreadRadius: -6,
    ),
  ];

  /// Figma `500`.
  static const s500 = [
    BoxShadow(
      color: _grey900a10,
      offset: Offset(0, 10),
      blurRadius: 32,
      spreadRadius: -4,
    ),
    BoxShadow(
      color: _grey900a12,
      offset: Offset(0, 6),
      blurRadius: 14,
      spreadRadius: -6,
    ),
  ];

  /// Figma `600`.
  static const s600 = [
    BoxShadow(
      color: _grey900a12,
      offset: Offset(0, 12),
      blurRadius: 42,
      spreadRadius: -4,
    ),
    BoxShadow(
      color: _grey900a12,
      offset: Offset(0, 8),
      blurRadius: 18,
      spreadRadius: -6,
    ),
  ];

  /// Figma `700`.
  static const s700 = [
    BoxShadow(
      color: _grey900a12,
      offset: Offset(0, 14),
      blurRadius: 64,
      spreadRadius: -4,
    ),
    BoxShadow(
      color: _grey900a12,
      offset: Offset(0, 8),
      blurRadius: 22,
      spreadRadius: -6,
    ),
  ];

  /// Figma `800`.
  static const s800 = [
    BoxShadow(
      color: _grey900a14,
      offset: Offset(0, 18),
      blurRadius: 88,
      spreadRadius: -4,
    ),
    BoxShadow(
      color: _grey900a12,
      offset: Offset(0, 8),
      blurRadius: 28,
      spreadRadius: -6,
    ),
  ];

  /// Every level by its Figma name.
  static const Map<String, List<BoxShadow>> byFigmaName = {
    '100': s100,
    '200': s200,
    '300': s300,
    '400': s400,
    '500': s500,
    '600': s600,
    '700': s700,
    '800': s800,
  };
}
