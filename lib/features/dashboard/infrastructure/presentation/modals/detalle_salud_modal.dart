import 'package:flutter/material.dart';
import 'package:stitch_stepway_fleet_manager/core/config/app_config.dart';
import 'package:stitch_stepway_fleet_manager/core/http/native_http_client.dart';
import 'package:stitch_stepway_fleet_manager/core/theme/app_colors.dart';
import 'package:stitch_stepway_fleet_manager/core/theme/app_theme.dart';
import 'package:stitch_stepway_fleet_manager/features/vehiculo/domain/entities/salud_general.dart';

/// Modal BottomSheet para consultar y actualizar la salud de los subsistemas del vehículo en PostgreSQL
class DetalleSaludModal extends StatefulWidget {
  final String vehicleId;
  final List<ComponenteSaludEntity> componentes;
  final VoidCallback onSaludActualizada;

  const DetalleSaludModal({
    super.key,
    required this.vehicleId,
    required this.componentes,
    required this.onSaludActualizada,
  });

  static void show(
    BuildContext context, {
    required String vehicleId,
    required List<ComponenteSaludEntity> componentes,
    required VoidCallback onSaludActualizada,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DetalleSaludModal(
        vehicleId: vehicleId,
        componentes: componentes,
        onSaludActualizada: onSaludActualizada,
      ),
    );
  }

  @override
  State<DetalleSaludModal> createState() => _DetalleSaludModalState();
}

class _DetalleSaludModalState extends State<DetalleSaludModal> {
  final NativeHttpClient _httpClient = NativeHttpClient();
  late Map<String, int> _saludMap;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _saludMap = {
      for (var c in widget.componentes) c.nombre: c.porcentaje,
    };
  }

  Future<void> _actualizarSalud(String compName, int nuevoPorcentaje) async {
    setState(() {
      _saludMap[compName] = nuevoPorcentaje;
      _isSaving = true;
    });

    try {
      final url = '${AppConfig.apiBaseUrl}/api/mantenimiento/vehiculos/${widget.vehicleId}/salud';
      await _httpClient.put(
        url,
        body: {
          'component_name': compName,
          'health_percentage': nuevoPorcentaje,
        },
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Salud de $compName actualizada al $nuevoPorcentaje% en PostgreSQL'),
            backgroundColor: AppColors.primary,
            duration: const Duration(seconds: 2),
          ),
        );
      }
      widget.onSaludActualizada();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al actualizar en servidor: ${e.toString()}'),
            backgroundColor: AppColors.onErrorContainer,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.cardWhite,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.onSurfaceVariant.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Diagnóstico y Salud del Vehículo',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.onSurface,
                ),
              ),
              if (_isSaving)
                const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
                ),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            'Desliza los controles para ajustar el porcentaje de salud por subsistema.',
            style: TextStyle(fontSize: 13, color: AppColors.onSurfaceVariant),
          ),
          const SizedBox(height: AppSpacing.md),
          ..._saludMap.entries.map((entry) {
            final compName = entry.key;
            final pct = entry.value;

            Color barColor = AppColors.primary;
            if (pct <= 40) {
              barColor = Colors.red;
            } else if (pct <= 70) {
              barColor = Colors.amber;
            }

            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: Container(
                padding: AppSpacing.paddingSm,
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerHigh.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(_getIconForComponent(compName), size: 18, color: barColor),
                            const SizedBox(width: 8),
                            Text(
                              _mapComponentName(compName),
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppColors.onSurface,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          '$pct%',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: barColor,
                          ),
                        ),
                      ],
                    ),
                    SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        trackHeight: 6,
                        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
                      ),
                      child: Slider(
                        value: pct.toDouble(),
                        min: 0,
                        max: 100,
                        divisions: 100,
                        activeColor: barColor,
                        inactiveColor: barColor.withValues(alpha: 0.2),
                        onChanged: (val) {
                          setState(() {
                            _saludMap[compName] = val.toInt();
                          });
                        },
                        onChangeEnd: (val) {
                          _actualizarSalud(compName, val.toInt());
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
          const SizedBox(height: AppSpacing.md),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.onPrimary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: const Text('Cerrar Diagnóstico'),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
        ],
      ),
    );
  }

  IconData _getIconForComponent(String comp) {
    switch (comp) {
      case 'BATTERY':
        return Icons.battery_charging_full;
      case 'BRAKES':
        return Icons.minor_crash;
      case 'ENGINE':
        return Icons.engineering;
      case 'TIRES':
        return Icons.tire_repair;
      case 'FLUIDS':
        return Icons.opacity;
      default:
        return Icons.build;
    }
  }

  String _mapComponentName(String comp) {
    switch (comp) {
      case 'BATTERY':
        return 'Batería y Sistema Eléctrico';
      case 'BRAKES':
        return 'Sistema de Frenos';
      case 'ENGINE':
        return 'Motor y Transmisión';
      case 'TIRES':
        return 'Llantas y Suspensión';
      case 'FLUIDS':
        return 'Aceites y Fluidos';
      default:
        return comp;
    }
  }
}
