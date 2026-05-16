import 'package:flutter/material.dart';

class ColorDefaults{

  static Color primaryBlue = const Color(0xFF0984E3);

  static Color secundaryBlue = const Color(0xFF00CEC9);

  static Color whitePrimary = const Color(0xFFF5F6FA);

  static Color darkPrimary = const Color(0xFF1E272E);

  // ── Tema oscuro dashboard ─────────────────────────────────────
  static const Color darkBgApp      = Color(0xFF12121E); // Scaffold background
  static const Color darkBgCard     = Color(0xFF1E1E2E); // Fondo de cards y gráficos
  static const Color darkBgCardAlt  = Color(0xFF232336); // Filas alternas en tablas
  static const Color darkBgHeader   = Color(0xFF2A2A3E); // Header de tablas y tooltips
  static const Color darkBgBorder   = Color(0xFF2E2E4E); // Bordes de cards

  static const Color darkCyan       = Color(0xFF00E5FF); // Acento principal, títulos
  static const Color darkTextPrimary = Colors.white;     // Texto principal
  static const Color darkTextMuted  = Color(0xFFB0B0C8); // Texto secundario, ejes

  static const Color darkGridLine   = Color(0x1FFFFFFF); // Grid lines (blanco 12%)
  static const Color darkAxisLine   = Color(0x33FFFFFF); // Líneas de ejes (blanco 20%)

  static const Color darkBarGood    = Color(0xFF4CAF50); // Verde — bajo umbral
  static const Color darkBarBad     = Color(0xFFE53935); // Rojo — sobre umbral
  static const Color darkUmbral     = Colors.orangeAccent; // Línea de umbral
}
