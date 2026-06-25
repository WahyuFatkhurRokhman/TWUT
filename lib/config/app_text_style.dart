import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTextStyle {
  static const TextStyle heading1 = TextStyle(
    fontFamily: 'Inter',
    fontWeight: FontWeight.bold,
    fontSize: 32,
    color: AppColors.accent,
  );

  static const TextStyle heading2 = TextStyle(
    fontFamily: 'Inter',
    fontWeight: FontWeight.w900, // Extra Bold
    fontSize: 48,
    color: AppColors.textPrimary,
    letterSpacing: -2.4,
  );

  static const TextStyle bodyRegular = TextStyle(
    fontFamily: 'Inter',
    fontWeight: FontWeight.normal,
    fontSize: 16,
    color: AppColors.textSecondary,
  );

  static const TextStyle labelSmall = TextStyle(
    fontFamily: 'JetBrains Mono',
    fontWeight: FontWeight.w500,
    fontSize: 10,
    color: AppColors.textSecondary,
    letterSpacing: 1.0,
  );
}
