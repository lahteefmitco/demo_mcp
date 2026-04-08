import 'package:flutter/material.dart';

/// Shared visuals for Finance Mobile (splash, onboarding, [MaterialApp]).
abstract final class ExpenseAppTheme {
  static const Color seedColor = Color(0xFF0E7490);
  static const Color scaffoldBackground = Color(0xFFF4F7FB);

  /// Soft gradient behind splash / onboarding hero areas.
  static const LinearGradient splashBackgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFFE8F4F7),
      scaffoldBackground,
    ],
  );

  static ThemeData light() {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: seedColor,
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: scaffoldBackground,
      useMaterial3: true,
      inputDecorationTheme: const InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }
}
