import 'package:flutter/material.dart';
import 'package:stitch_stepway_fleet_manager/core/theme/app_colors.dart';
import 'package:stitch_stepway_fleet_manager/core/theme/app_theme.dart';
import 'package:stitch_stepway_fleet_manager/features/vehiculo/domain/entities/salud_general.dart';

/// Tarjeta de Salud General y Diagnósticos con Gráfico de Barras Avanzado e Info Explicativa
class GeneralHealthCard extends StatelessWidget {
  final List<ComponenteSaludEntity> componentes;
  final VoidCallback? onVerDetallesTap;

  const GeneralHealthCard({
    super.key,
    required this.componentes,
    this.onVerDetallesTap,
  });

  void _mostrarInfoDiagnostico(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: AppColors.surfaceContainerHigh,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
          title: Row(
            children: const [
              Icon(Icons.info_outline, color: AppColors.primary),
              SizedBox(width: 8),
              Text(
                '¿Cómo funciona la Salud?',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.onSurface),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'El porcentaje de salud estima el desgaste de los componentes críticos basados en el odómetro y la fecha de última revisión:',
                  style: TextStyle(fontSize: 13, color: AppColors.onSurfaceVariant, height: 1.4),
                ),
                const SizedBox(height: 12),
                _buildInfoItem(Icons.battery_charging_full, 'Batería', 'Mide vida útil eléctrica. Sustituir cada 2-3 años.'),
                _buildInfoItem(Icons.minor_crash, 'Frenos (Pastillas)', 'Desgaste de pastillas y líquido de frenos.'),
                _buildInfoItem(Icons.engineering, 'Motor', 'Estado general, bujías y correas del vehículo.'),
                _buildInfoItem(Icons.tire_repair, 'Llantas (Neumáticos)', 'Vida útil del labrado y rotación de llantas.'),
                _buildInfoItem(Icons.opacity, 'Aceite y Fluidos', 'Calidad del lubricante de motor y refrigerante.'),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Entendido', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  Widget _buildInfoItem(IconData icon, String label, String desc) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: AppColors.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.onSurface)),
                const SizedBox(height: 2),
                Text(desc, style: const TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
          // Cabecera Principal con Información y Botón de Ajustes
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
                    'Salud del Auto',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: AppColors.onSurface,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.help_outline, size: 18, color: AppColors.onSurfaceVariant),
                    onPressed: () => _mostrarInfoDiagnostico(context),
                    tooltip: 'Ver explicación de diagnóstico',
                  ),
                ],
              ),
              TextButton.icon(
                onPressed: onVerDetallesTap,
                icon: const Icon(Icons.tune_rounded, size: 16, color: AppColors.primary),
                label: const Text(
                  'Inspeccionar',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),

          // Texto Explicativo de Contexto
          const Padding(
            padding: EdgeInsets.only(bottom: AppSpacing.md, top: 2),
            child: Text(
              'Desgaste estimado en base al kilometraje de tu vehículo. Toca "Inspeccionar" para ajustar el porcentaje manualmente posterior a una revisión física.',
              style: TextStyle(
                fontSize: 11.5,
                color: AppColors.onSurfaceVariant,
                height: 1.35,
              ),
            ),
          ),

          // Visualizador Gráfico de Barras Multinivel e Intuitivas
          SizedBox(
            height: 135,
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
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: barColor,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Expanded(
                          child: Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: AppColors.surfaceContainerHigh.withValues(alpha: 0.35),
                              borderRadius: BorderRadius.circular(10),
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
                                        barColor.withValues(alpha: 0.75),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(10),
                                    boxShadow: [
                                      BoxShadow(
                                        color: barColor.withValues(alpha: 0.25),
                                        blurRadius: 5,
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
                        Icon(_getIconForComponent(comp.nombre), size: 18, color: AppColors.onSurfaceVariant),
                        const SizedBox(height: 3),
                        Text(
                          comp.etiquetaCorta,
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
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
