import 'package:flutter/material.dart';

class AppColors {
  static const Color primaryRed = Colors.red;
  static const Color trigonometryColor = Colors.red;
  static const Color algebraColor = Colors.blue;
  static const Color calculusColor = Colors.green;
  static const Color matrixColor = Colors.deepOrange;
  static const Color complexColor = Colors.teal;
  static const Color geometryColor = Colors.amber;
  static const Color statisticsColor = Colors.purple;
  static const Color probabilityColor = Colors.indigo;
  static const Color financialColor = Colors.green;
}

class AppThemes {
  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primaryRed,
      brightness: Brightness.light,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.primaryRed,
      foregroundColor: Colors.white,
    ),
  );

  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primaryRed,
      brightness: Brightness.dark,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.grey[900],
      foregroundColor: Colors.white,
    ),
  );
}
