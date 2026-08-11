import 'package:flutter/material.dart';

abstract final class AppTypography {
  static const textTheme = TextTheme(
    displayLarge: TextStyle(
      fontSize: 40,
      height: 1.1,
      fontWeight: FontWeight.w800,
      letterSpacing: -1.2,
    ),
    displayMedium: TextStyle(
      fontSize: 34,
      height: 1.12,
      fontWeight: FontWeight.w800,
      letterSpacing: -0.9,
    ),
    headlineLarge: TextStyle(
      fontSize: 24,
      height: 1.18,
      fontWeight: FontWeight.w800,
      letterSpacing: -0.4,
    ),
    headlineMedium: TextStyle(
      fontSize: 20,
      height: 1.24,
      fontWeight: FontWeight.w700,
      letterSpacing: -0.2,
    ),
    titleLarge: TextStyle(
      fontSize: 18,
      height: 1.28,
      fontWeight: FontWeight.w700,
    ),
    titleMedium: TextStyle(
      fontSize: 15,
      height: 1.3,
      fontWeight: FontWeight.w600,
    ),
    titleSmall: TextStyle(
      fontSize: 14,
      height: 1.35,
      fontWeight: FontWeight.w600,
    ),
    bodyLarge: TextStyle(fontSize: 15, height: 1.42),
    bodyMedium: TextStyle(fontSize: 13, height: 1.4),
    bodySmall: TextStyle(fontSize: 12, height: 1.36),
    labelLarge: TextStyle(
      fontSize: 14,
      height: 1.2,
      fontWeight: FontWeight.w700,
    ),
    labelMedium: TextStyle(
      fontSize: 12,
      height: 1.18,
      fontWeight: FontWeight.w600,
    ),
    labelSmall: TextStyle(
      fontSize: 11,
      height: 1.18,
      fontWeight: FontWeight.w600,
    ),
  );
}
