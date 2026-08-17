import 'package:flutter/material.dart';

/// Sistema de colores optimizado para alto rendimiento en Bitácora Stepway Fleet Manager
abstract class AppColors {
  // Fondos y Superficies especificados
  static const Color background = Color(0xFFF8FAFC);
  static const Color cardWhite = Color(0xFFFFFFFF);

  // Colores primarios y secundarios
  static const Color primary = Color(0xFF0058BE);
  static const Color primaryContainer = Color(0xFF2170E4);
  static const Color secondaryContainer = Color(0xFFD0E1FB);
  static const Color surfaceContainerHigh = Color(0xFFE2E7FF);
  static const Color surfaceContainer = Color(0xFFEAEDFF);
  
  // Textos y Contraste
  static const Color onSurface = Color(0xFF131B2E);
  static const Color onSurfaceVariant = Color(0xFF424754);
  static const Color onPrimary = Color(0xFFFFFFFF);
  
  // Alertas y Prioridades
  static const Color priorityOrange = Color(0xFFF97316);
  static const Color errorContainer = Color(0xFFFFDAD6);
  static const Color onErrorContainer = Color(0xFF93000A);
  
  // Sombra de alto rendimiento sin asignaciones dinámicas de GPU (ARGB constante hex)
  static const BoxShadow cardShadow = BoxShadow(
    color: Color(0x0D0F172A),
    blurRadius: 10,
    spreadRadius: 0,
    offset: Offset(0, 4),
  );
}
