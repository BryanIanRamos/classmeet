import 'package:flutter/material.dart';
import 'package:practice1/core/theme/app_color.dart';
import 'package:practice1/core/theme/app_text_theme.dart';

class AppTheme {
  AppTheme._();

  static ThemeData themeData = ThemeData(
    useMaterial3: true,

    scaffoldBackgroundColor: AppColor.background,

    colorScheme: ColorScheme.fromSeed(seedColor: AppColor.primary).copyWith(
      primary: AppColor.primary,
      secondary: AppColor.secondary,
      onPrimary: AppColor.white,
      onSecondary: AppColor.white,
    ),

    textTheme: AppTextTheme.textTheme,

    appBarTheme: const AppBarTheme(centerTitle: true, elevation: 0),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColor.primary,
        foregroundColor: Colors.white,
      ),
    ),

    inputDecorationTheme: const InputDecorationTheme(
      border: OutlineInputBorder(),
    ),
  );
}
