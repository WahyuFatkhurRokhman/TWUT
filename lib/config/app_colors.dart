import 'package:flutter/material.dart';

class AppColors {
  // UI Constants for TWUT 2.0 (Figma-matched)
  static const Color background = Color(0xFF131313);
  static const Color accent = Color(0xFF53E076);
  static const Color textPrimary = Color(0xFFE5E2E1);
  static const Color textSecondary = Color(0xFFBCCBB9);
  
  static const Color card = Color(0xFF1C1B1B); // Base card color
  static const Color surface = Color(0xFF1E1E1E); // Added back
  static const Color cardBackground = Color(0x801C1B1B); // 50% opacity
  static const Color border = Color(0x0DFFFFFF); // 5% opacity

  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF131313), Color(0xFF000000)],
  );
}
