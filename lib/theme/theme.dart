import 'package:flutter/material.dart';

final class AppColors {
  static const Color accentOrange = Color(0xFFFF9800);
  static const Color accentOrangeLight = Color(0xFFFFB74D);
  static const Color darkBg = Color(0xFF121212);
  static const Color surfaceDark = Color(0xFF1E1E1E);
  static const Color surfaceContainer = Color(0xFF2D2D2D);
  static const Color textGrey = Color(0xFF9E9E9E);
  static const Color textGreyLight = Color(0xFFBDBDBD);
  static const Color accentGreen = Color(0xFF4CAF50);
}

final class AppTheme {
  static ThemeData getTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.darkBg,
      colorScheme: ColorScheme.dark(
        primary: AppColors.accentOrange,
        onPrimary: Colors.white,
        secondary: AppColors.accentOrangeLight,
        surface: AppColors.surfaceDark,
        onSurface: Colors.white,
        surfaceContainerHighest: AppColors.surfaceContainer,
        error: Colors.red,
        onError: Colors.white,
      ),
      appBarTheme: const AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: AppColors.surfaceDark,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        color: AppColors.surfaceContainer,
        margin: EdgeInsets.zero,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.accentOrange,
        foregroundColor: Colors.white,
        elevation: 8,
      ),
      searchBarTheme: SearchBarThemeData(
        backgroundColor: WidgetStateProperty.all(AppColors.surfaceContainer),
        elevation: WidgetStateProperty.all(0),
        hintStyle: WidgetStateProperty.all(
          const TextStyle(color: AppColors.textGrey),
        ),
        textStyle: WidgetStateProperty.all(
          const TextStyle(color: Colors.white),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceContainer,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.surfaceContainer),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.surfaceContainer),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.accentOrange, width: 2),
        ),
        labelStyle: const TextStyle(color: AppColors.textGrey),
        hintStyle: const TextStyle(color: AppColors.textGrey),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accentOrange,
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
          foregroundColor: AppColors.accentOrange,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.surfaceDark,
        indicatorColor: AppColors.accentOrange.withValues(alpha: 0.15),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: AppColors.accentOrange);
          }
          return const IconThemeData(color: AppColors.textGrey);
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const TextStyle(
              color: AppColors.accentOrange,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            );
          }
          return const TextStyle(
            color: AppColors.textGrey,
            fontSize: 12,
          );
        }),
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          fontFamily: 'Poppins',
        ),
        displayMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          fontFamily: 'Poppins',
        ),
        titleLarge: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          fontFamily: 'Poppins',
        ),
        titleMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.white,
          fontFamily: 'Poppins',
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          color: Colors.white,
          fontFamily: 'Poppins',
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          color: AppColors.textGreyLight,
          fontFamily: 'Poppins',
        ),
        bodySmall: TextStyle(
          fontSize: 12,
          color: AppColors.textGrey,
          fontFamily: 'Poppins',
        ),
        labelMedium: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: AppColors.textGrey,
          fontFamily: 'Poppins',
        ),
      ),
    );
  }
}
