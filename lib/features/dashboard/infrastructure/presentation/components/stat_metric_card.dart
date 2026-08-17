import 'package:flutter/material.dart';
import 'package:stitch_stepway_fleet_manager/core/theme/app_colors.dart';
import 'package:stitch_stepway_fleet_manager/core/theme/app_theme.dart';

class StatMetricCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String valor;
  final String unidad;
  final Color iconBackgroundColor;
  final Color iconColor;
  final VoidCallback? onTap;
  
  // Agregados para soporte de gráficos y progreso intuitivos
  final double? progressRatio;
  final Color? progressColor;

  const StatMetricCard({
    super.key,
    required this.icon,
    required this.label,
    required this.valor,
    required this.unidad,
    this.iconBackgroundColor = const Color(0xFFE2E7FF),
    this.iconColor = AppColors.primary,
    this.onTap,
    this.progressRatio,
    this.progressColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: AppSpacing.paddingMd,
        decoration: AppDecorations.cardDecoration(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: iconBackgroundColor,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    color: iconColor,
                    size: 18,
                  ),
                ),
                if (progressRatio != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: (progressColor ?? AppColors.primary).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '${(progressRatio! * 100).toInt()}%',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: progressColor ?? AppColors.primary,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              label.toUpperCase(),
              style: const TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
                color: AppColors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 4),
            RichText(
              text: TextSpan(
                text: '$valor ',
                style: const TextStyle(
                  fontSize: 19,
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
            if (progressRatio != null) ...[
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: SizedBox(
                  height: 6,
                  child: LinearProgressIndicator(
                    value: progressRatio,
                    backgroundColor: AppColors.surfaceContainerHigh.withValues(alpha: 0.5),
                    valueColor: AlwaysStoppedAnimation<Color>(progressColor ?? AppColors.primary),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
