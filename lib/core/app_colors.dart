import 'package:flutter/material.dart';

class AppColors {
  // Fundo e Superfícies
  static const Color background = Color(0xFF0B0B12);
  static const Color surface = Color(0xFF111827); // gray-900 do Tailwind
  static const Color border = Color(0xFF2B2B3D);

  // Marca / Destaque
  static const Color primary = Color(0xFF059669); // emerald-600
  static const Color primaryLight = Color(
    0x33059669,
  ); // emerald com 20% de opacidade (usado na navegação)
  static const Color error = Color(
    0xFFEF4444,
  ); // red-500 (bolinha de notificação)
  static const Color success = Color(
    0xFF10B981,
  ); // Verde esmeralda para entradas

  // Textos
  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Color(0xFF9CA3AF); // gray-400 do Tailwind
}
