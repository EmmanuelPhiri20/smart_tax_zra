import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary brand
  static const Color primary = Color(0xFF0A5FFF);
  static const Color accent = Color(0xFFFFC107);

  // Background / surfaces
  static const Color background = Color(0xFFF6F8FB);
  static const Color surface = Colors.white;

  // Text
  static const Color textDark = Color(0xFF1F2937);
  static const Color textLight = Colors.white;
  static const Color textMuted = Color(0xFF6B7280);

  // Semantic
  static const Color success = Color(0xFF16A34A);
  static const Color danger = Color(0xFFDC2626);
  static const Color warning = Color(0xFFF59E0B);

  static Color? primaryColor;
}
