import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Constantes y Utilitarios de Diseño con espaciado estricto en múltiplos de 8
abstract class AppSpacing {
  static const double xs = 8.0;
  static const double sm = 16.0;
  static const double md = 24.0;
  static const double lg = 32.0;

  static const EdgeInsets paddingXs = EdgeInsets.all(xs);
  static const EdgeInsets paddingSm = EdgeInsets.all(sm);
  static const EdgeInsets paddingMd = EdgeInsets.all(md);
  static const EdgeInsets paddingLg = EdgeInsets.all(lg);
  
  static const EdgeInsets paddingHorizontalMd = EdgeInsets.symmetric(horizontal: md);
  static const EdgeInsets paddingVerticalSm = EdgeInsets.symmetric(vertical: sm);
}

abstract class AppDecorations {
  /// Decoración base para tarjetas blancas sin bordes y sombra sutil
  static BoxDecoration cardDecoration({double borderRadius = 20.0}) {
    return BoxDecoration(
      color: AppColors.cardWhite,
      borderRadius: BorderRadius.circular(borderRadius),
      boxShadow: const [AppColors.cardShadow],
    );
  }
}
