import 'package:dorm_of_decents/configs/colors.dart';
import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    useMaterial3: true,
    fontFamily: 'Geist',
    colorScheme: ColorScheme.light(
      primary: AppColors.primary,
      secondary: AppColors.secondary,
      surface: AppColors.lightBackground,
      onPrimary: AppColors.onPrimary,
      onSecondary: AppColors.onSecondary,
      error: Colors.red,
      onError: Colors.white,
      onSurface: AppColors.lightForeground,
    ),
    scaffoldBackgroundColor: AppColors.lightBackground,
    appBarTheme: const AppBarTheme(
      elevation: 0,
      backgroundColor: AppColors.lightBackground,
      foregroundColor: AppColors.lightForeground,
    ),
    textTheme: const TextTheme(
      displayLarge: TextStyle(fontFamily: 'Crimson Text', fontWeight: FontWeight.bold),
      displayMedium: TextStyle(fontFamily: 'Crimson Text', fontWeight: FontWeight.bold),
      displaySmall: TextStyle(fontFamily: 'Crimson Text', fontWeight: FontWeight.bold),
      headlineLarge: TextStyle(fontFamily: 'Crimson Text', fontWeight: FontWeight.bold),
      headlineMedium: TextStyle(fontFamily: 'Crimson Text', fontWeight: FontWeight.bold),
      headlineSmall: TextStyle(fontFamily: 'Crimson Text', fontWeight: FontWeight.bold),
      titleLarge: TextStyle(fontFamily: 'Crimson Text', fontWeight: FontWeight.bold),
      titleMedium: TextStyle(fontFamily: 'Crimson Text', fontWeight: FontWeight.w600),
      titleSmall: TextStyle(fontFamily: 'Crimson Text', fontWeight: FontWeight.w600),
    ),
  );

  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    fontFamily: 'Geist',
    useMaterial3: true,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.primary,
      secondary: AppColors.secondary,
      surface: AppColors.darkBackground,
      onPrimary: AppColors.onPrimary,
      error: Colors.red,
      onError: Colors.white,
      onSecondary: AppColors.onSecondary,
      onSurface: AppColors.darkForeground,
    ),
    scaffoldBackgroundColor: AppColors.darkBackground,
    appBarTheme: const AppBarTheme(
      elevation: 0,
      backgroundColor: AppColors.darkBackground,
      foregroundColor: AppColors.darkForeground,
    ),
    textTheme: const TextTheme(
      displayLarge: TextStyle(fontFamily: 'Crimson Text', fontWeight: FontWeight.bold),
      displayMedium: TextStyle(fontFamily: 'Crimson Text', fontWeight: FontWeight.bold),
      displaySmall: TextStyle(fontFamily: 'Crimson Text', fontWeight: FontWeight.bold),
      headlineLarge: TextStyle(fontFamily: 'Crimson Text', fontWeight: FontWeight.bold),
      headlineMedium: TextStyle(fontFamily: 'Crimson Text', fontWeight: FontWeight.bold),
      headlineSmall: TextStyle(fontFamily: 'Crimson Text', fontWeight: FontWeight.bold),
      titleLarge: TextStyle(fontFamily: 'Crimson Text', fontWeight: FontWeight.bold),
      titleMedium: TextStyle(fontFamily: 'Crimson Text', fontWeight: FontWeight.w600),
      titleSmall: TextStyle(fontFamily: 'Crimson Text', fontWeight: FontWeight.w600),
    ),
  );

  static ThemeData getTheme(BuildContext context) => Theme.of(context);
}
