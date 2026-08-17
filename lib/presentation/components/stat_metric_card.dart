import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';

/// Tarjeta genérica y reutilizable para métricas clave (Odómetro, Gasolina, etc.)
class StatMetricCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String valor;
  final String unidad;
  final Color iconBackgroundColor;
  final Color iconColor;
  final VoidCallback? onTap;

  const StatMetricCard({
    super.key,
    required this.icon,
    required this.label,
    required this.valor,
    required this.unidad,
    this.iconBackgroundColor = const Color(0xFFE2E7FF),
    this.iconColor = AppColors.primary,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: AppSpacing.paddingMd,
        decoration: AppDecorations.cardDecoration(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Ícono circular
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: iconBackgroundColor,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: iconColor,
                size: 20,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            // Etiqueta
            Text(
              label.toUpperCase(),
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
                color: AppColors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 4),
            // Valor con Unidad
            RichText(
              text: TextSpan(
                text: '$valor ',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.onSurface,
                ),
                children: [
                  TextSpan(
                    text: unidad,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
