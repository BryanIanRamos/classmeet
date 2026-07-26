import 'package:flutter/material.dart';

abstract final class AppColors {
  AppColors._();

  // Brand Colors
  static const Color primary = Color(0xFF42807F);
  static const Color secondary = Color(0xFF0B4F5C);
  static const Color tertiary = Color(0xFF74B8BB);

  // Neutral Colors
  static const Color white = Colors.white;
  static const Color black = Colors.black;

  static const Color background = Colors.white;

  // Status Color
  static const Color success = Color(0xFF2E7D32);

  static const Color warning = Color(0xFFF9A825);

  static const Color error = Color(0xFFC62828);

  static const Color seed = primary;
}
