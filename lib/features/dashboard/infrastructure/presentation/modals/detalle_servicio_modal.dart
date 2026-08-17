import 'package:flutter/material.dart';
import 'package:stitch_stepway_fleet_manager/core/theme/app_colors.dart';
import 'package:stitch_stepway_fleet_manager/core/theme/app_theme.dart';
import 'package:stitch_stepway_fleet_manager/features/mantenimiento/domain/entities/mantenimiento.dart';

class DetalleServicioModal extends StatelessWidget {
  final MantenimientoEntity servicio;

  const DetalleServicioModal({
    super.key,
    required this.servicio,
  });

  static Future<void> show(BuildContext context, {required MantenimientoEntity servicio}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DetalleServicioModal(servicio: servicio),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: const BoxDecoration(
        color: AppColors.cardWhite,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 48,
              height: 5,
              decoration: BoxDecoration(
                color: AppColors.onSurfaceVariant.withOpacity(0.3),
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),

          // Alerta Badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
                decoration: BoxDecoration(
                  color: AppColors.priorityOrange.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.warning_amber_rounded, size: 18, color: AppColors.priorityOrange),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      'ALERTA DE SERVICIO ${servicio.nivelPrioridad}',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.priorityOrange),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close, color: AppColors.onSurfaceVariant),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),

          // Título
          Text(
            servicio.titulo,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.onSurface),
          ),
          const SizedBox(height: 4),
          Text(
            servicio.descripcion,
            style: const TextStyle(fontSize: 14, color: AppColors.onSurfaceVariant),
          ),
          const SizedBox(height: AppSpacing.md),

          // Detalle de Kilometraje y Costo Estimado
          Container(
            padding: AppSpacing.paddingMd,
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    const Icon(Icons.schedule, color: AppColors.primary),
                    const SizedBox(height: 4),
                    const Text('Kilómetros Restantes', style: TextStyle(fontSize: 11, color: AppColors.onSurfaceVariant)),
                    Text('Faltan ${servicio.kilometrosRestantes} km', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.onSurface)),
                  ],
                ),
                Container(width: 1, height: 40, color: AppColors.surfaceContainerHigh),
                Column(
                  children: [
                    const Icon(Icons.payments_outlined, color: AppColors.primary),
                    const SizedBox(height: 4),
                    const Text('Costo Estimado', style: TextStyle(fontSize: 11, color: AppColors.onSurfaceVariant)),
                    const Text('\$ 120.000 - \$ 150.000', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.onSurface)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // Checklist de Procedimiento Técnico
          const Text('Procedimiento Recomendado', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.onSurface)),
          const SizedBox(height: AppSpacing.xs),
          _buildCheckItem('Limpieza ultrasónica del cuerpo de aceleración.'),
          _buildCheckItem('Reprogramación de marcha mínima / ralentí en escáner.'),
          _buildCheckItem('Inspección de empaque de estanqueidad y manguera de admisión.'),
          const SizedBox(height: AppSpacing.md),

          // Botones de Acción
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Servicio agendado en el taller autorizado'), backgroundColor: AppColors.primary),
                    );
                  },
                  icon: const Icon(Icons.calendar_month),
                  label: const Text('Agendar Cita'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('¡Servicio marcado como realizado!'), backgroundColor: AppColors.primary),
                    );
                  },
                  icon: const Icon(Icons.check_circle),
                  label: const Text('Completar'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.onPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
        ],
      ),
    );
  }

  Widget _buildCheckItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check_circle_outline, size: 18, color: AppColors.primary),
          const SizedBox(width: AppSpacing.xs),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 13, color: AppColors.onSurface))),
        ],
      ),
    );
  }
}
