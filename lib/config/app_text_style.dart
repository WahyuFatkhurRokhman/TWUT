import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTextStyles {
  static const TextStyle title = TextStyle(
    color: AppColors.textPrimary,
    fontSize: 18,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle body = TextStyle(
    color: AppColors.textPrimary,
    fontSize: 14,
  );

  static const TextStyle subtitle = TextStyle(
    color: AppColors.textSecondary,
    fontSize: 13,
  );
}