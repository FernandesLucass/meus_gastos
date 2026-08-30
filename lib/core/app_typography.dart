import 'package:flutter/material.dart';

import 'app_colors.dart';

class AppTypography {
  static const String fontFamily = 'Geist';

  // Títulos (ex: "Entrada Rápida")
  static const TextStyle title = TextStyle(
    fontFamily: fontFamily,
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );

  // Subtítulos e Rótulos (ex: "VALOR DA TRANSAÇÃO")
  static const TextStyle label = TextStyle(
    fontFamily: fontFamily,
    fontSize: 13,
    fontWeight: FontWeight.w600, // SemiBold
    color: AppColors.textSecondary,
  );

  // Texto dos botões e menus
  static const TextStyle button = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  // Texto padrão de inputs e dropdowns
  static const TextStyle input = TextStyle(
    fontFamily: fontFamily,
    fontSize: 15,
    fontWeight: FontWeight.w500, // Medium
    color: AppColors.textPrimary,
  );

  // Texto gigante do valor ($ 120.00)
  static const TextStyle amount = TextStyle(
    fontFamily: fontFamily,
    fontSize: 48,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );
}
