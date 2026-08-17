import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../features/vehiculo/domain/entities/salud_general.dart';

/// Tarjeta de Salud General con visualizador gráfico de alta precisión
class GeneralHealthCard extends StatelessWidget {
  final List<ComponenteSaludEntity> componentes;
  final VoidCallback? onVerDetallesTap;

  const GeneralHealthCard({
    super.key,
    required this.componentes,
    this.onVerDetallesTap,
  });

  @override
  Widget build(BuildContext context) {
    // Calcular promedio general de salud
    final double promedioSalud = componentes.isEmpty
        ? 100.0
        : componentes.map((c) => c.porcentaje).reduce((a, b) => a + b) / componentes.length;

    Color stateColor = AppColors.primary;
    String stateLabel = 'ÓPTIMO';
    if (promedioSalud <= 40) {
      stateColor = Colors.red;
      stateLabel = 'CRÍTICO';
    } else if (promedioSalud <= 70) {
      stateColor = Colors.amber;
      stateLabel = 'ATENCIÓN';
    }

    return Container(
      padding: AppSpacing.paddingMd,
      decoration: AppDecorations.cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cabecera con Promedio General y Botón de Detalles
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: stateColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: stateColor.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.health_and_safety, size: 14, color: stateColor),
                        const SizedBox(width: 4),
                        Text(
                          '$stateLabel • ${promedioSalud.toInt()}%',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: stateColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Salud General',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: AppColors.onSurface,
                    ),
                  ),
                ],
              ),
              TextButton.icon(
                onPressed: onVerDetallesTap,
                icon: const Icon(Icons.tune, size: 16, color: AppColors.primary),
                label: const Text(
                  'Ajustar',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),

          // Visualizador Gráfico de Barras Multinivel
          SizedBox(
            height: 120,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: componentes.map((comp) {
                final double factorHeight = (comp.porcentaje / 100).clamp(0.08, 1.0);
                
                Color barColor = AppColors.primary;
                if (comp.porcentaje <= 40) {
                  barColor = Colors.red;
                } else if (comp.porcentaje <= 70) {
                  barColor = Colors.amber;
                }

                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          '${comp.porcentaje}%',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: barColor,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Expanded(
                          child: Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: AppColors.surfaceContainerHigh.withValues(alpha: 0.4),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Align(
                              alignment: Alignment.bottomCenter,
                              child: FractionallySizedBox(
                                heightFactor: factorHeight,
                                child: Container(
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        barColor,
                                        barColor.withValues(alpha: 0.7),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                    boxShadow: [
                                      BoxShadow(
                                        color: barColor.withValues(alpha: 0.25),
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Icon(_getIconForComponent(comp.nombre), size: 16, color: AppColors.onSurfaceVariant),
                        const SizedBox(height: 2),
                        Text(
                          comp.etiquetaCorta,
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: AppColors.onSurfaceVariant,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getIconForComponent(String comp) {
    switch (comp.toUpperCase()) {
      case 'BATTERY':
      case 'BAT':
        return Icons.battery_charging_full;
      case 'BRAKES':
      case 'FRE':
        return Icons.minor_crash;
      case 'ENGINE':
      case 'MOT':
        return Icons.engineering;
      case 'TIRES':
      case 'LLA':
        return Icons.tire_repair;
      case 'FLUIDS':
      case 'ACE':
        return Icons.opacity;
      default:
        return Icons.build;
    }
  }
}
