import 'package:flutter/material.dart';

class HexColor extends Color {
  HexColor(final String hexColor) : super(_getColorFromHex(hexColor));

  static int _getColorFromHex(String hexColor) {
    // 1. Clean up the string (remove '#' if present, make uppercase)
    hexColor = hexColor.toUpperCase().replaceAll("#", "");

    // 2. If it's a 6-digit hex, automatically prepend 'FF' for full opacity
    if (hexColor.length == 6) {
      hexColor = "FF" + hexColor;
    }

    // 3. Parse it into the integer format Flutter expects
    return int.parse(hexColor, radix: 16);
  }
}
