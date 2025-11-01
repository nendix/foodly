import 'package:flutter/material.dart';

final class AppTheme {
  static const Color _accentOrange = Color(0xFFFF9800);
  static const Color _accentOrangeLight = Color(0xFFFFB74D);
  static const Color _darkBg = Color(0xFF121212);
  static const Color _surfaceDark = Color(0xFF1E1E1E);
  static const Color _surfaceContainer = Color(0xFF2D2D2D);

  static ThemeData getTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: _darkBg,
      colorScheme: ColorScheme.dark(
        primary: _accentOrange,
        onPrimary: Colors.white,
        secondary: _accentOrangeLight,
        surface: _surfaceDark,
        onSurface: Colors.white,
        surfaceContainerHighest: _surfaceContainer,
        error: Colors.red,
        onError: Colors.white,
      ),
       appBarTheme: const AppBarTheme(
         elevation: 0,
         scrolledUnderElevation: 0,
         backgroundColor: _surfaceDark,
         foregroundColor: Colors.white,
         centerTitle: true,
       ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        color: _surfaceContainer,
        margin: EdgeInsets.zero,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: _accentOrange,
        foregroundColor: Colors.white,
        elevation: 8,
      ),
      searchBarTheme: SearchBarThemeData(
        backgroundColor: WidgetStateProperty.all(_surfaceContainer),
        elevation: WidgetStateProperty.all(0),
        hintStyle: WidgetStateProperty.all(
          const TextStyle(color: Color(0xFF9E9E9E)),
        ),
        textStyle: WidgetStateProperty.all(
          const TextStyle(color: Colors.white),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: _surfaceContainer,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _surfaceContainer),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _surfaceContainer),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _accentOrange, width: 2),
        ),
        labelStyle: const TextStyle(color: Color(0xFF9E9E9E)),
        hintStyle: const TextStyle(color: Color(0xFF9E9E9E)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _accentOrange,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: _accentOrange,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: _surfaceDark,
        indicatorColor: _accentOrange.withValues(alpha: 0.15),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: _accentOrange);
          }
          return const IconThemeData(color: Color(0xFF9E9E9E));
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const TextStyle(
              color: _accentOrange,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            );
          }
          return const TextStyle(
            color: Color(0xFF9E9E9E),
            fontSize: 12,
          );
        }),
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        displayMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        titleLarge: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        titleMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          color: Colors.white,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          color: Color(0xFFBDBDBD),
        ),
        bodySmall: TextStyle(
          fontSize: 12,
          color: Color(0xFF9E9E9E),
        ),
        labelMedium: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: Color(0xFF9E9E9E),
        ),
      ),
    );
  }
}
