import 'package:flutter/material.dart';

final class AppTheme {
  static const Color seedColor = Color(0xFFFF8C00);

  static ThemeData getTheme() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: seedColor,
        brightness: Brightness.dark,
      ),
      typography: Typography.material2021(),
      appBarTheme: AppBarTheme(
        elevation: 0,
        backgroundColor: ColorScheme.fromSeed(
          seedColor: seedColor,
          brightness: Brightness.dark,
        ).surface,
        foregroundColor: ColorScheme.fromSeed(
          seedColor: seedColor,
          brightness: Brightness.dark,
        ).onSurface,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        color: ColorScheme.fromSeed(
          seedColor: seedColor,
          brightness: Brightness.dark,
        ).surfaceContainerHighest,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: seedColor,
        foregroundColor: Colors.white,
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }
}
