import 'dart:io';
import 'package:flutter/material.dart';
import 'package:stitch_stepway_fleet_manager/core/theme/app_colors.dart';
import 'package:stitch_stepway_fleet_manager/core/theme/app_theme.dart';
import 'package:stitch_stepway_fleet_manager/features/vehiculo/domain/entities/vehiculo.dart';

/// Tarjeta del vehículo con estilo visual Premium en Rectángulo Horizontal Profesional
class HeaderVehicleCard extends StatelessWidget {
  final VehiculoEntity vehiculo;
  final VoidCallback? onVehiculoTap;

  const HeaderVehicleCard({
    super.key,
    required this.vehiculo,
    this.onVehiculoTap,
  });

  @override
  Widget build(BuildContext context) {
    final fuelPct = vehiculo.nivelGasolinaPorcentaje;
    Color fuelColor = AppColors.primary;
    if (fuelPct <= 25) {
      fuelColor = AppColors.priorityOrange;
    } else if (fuelPct <= 50) {
      fuelColor = Colors.amber;
    }

    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardWhite,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.12),
          width: 1.5,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: onVehiculoTap,
          borderRadius: BorderRadius.circular(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Banner Superior: Imagen Rectangular Horizontal
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
                    child: SizedBox(
                      width: double.infinity,
                      height: 210,
                      child: _buildVehicleImage(vehiculo.imagenUrl),
                    ),
                  ),
                  // Gradiente superpuesto inferior para legibilidad
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withValues(alpha: 0.2),
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.75),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Badge PostgreSQL Live Superior Izquierda
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.65),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(Icons.cloud_done, size: 13, color: Colors.lightBlueAccent),
                          SizedBox(width: 5),
                          Text(
                            'PostgreSQL Cloud Live',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Selector Flota Superior Derecha
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(999),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Text(
                            'Cambiar',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: AppColors.onPrimary,
                            ),
                          ),
                          SizedBox(width: 2),
                          Icon(Icons.keyboard_arrow_down, size: 16, color: AppColors.onPrimary),
                        ],
                      ),
                    ),
                  ),
                  // Nombre del Vehículo e Información sobre la Imagen
                  Positioned(
                    bottom: 12,
                    left: 14,
                    right: 14,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                vehiculo.nombreCompleto,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 19,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  shadows: [
                                    Shadow(color: Colors.black54, blurRadius: 4),
                                  ],
                                ),
                              ),
                              Text(
                                '${vehiculo.version} • Odómetro: ${vehiculo.kilometrajeActual} km',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.white70,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              // 2. Faja de Metadatos Inferior: Placa y Nivel de Combustible
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Badge Placa Estilo Matrícula
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerHigh,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.onSurfaceVariant.withValues(alpha: 0.2)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.pin, size: 14, color: AppColors.primary),
                          const SizedBox(width: 4),
                          Text(
                            vehiculo.placa,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'monospace',
                              color: AppColors.onSurface,
                              letterSpacing: 1,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Badge Combustible & Autonomía Predictiva
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: fuelColor.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(color: fuelColor.withValues(alpha: 0.3)),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.local_gas_station, size: 14, color: fuelColor),
                              const SizedBox(width: 4),
                              Text(
                                '${vehiculo.nivelGasolinaTexto} (${vehiculo.nivelGasolinaPorcentaje.toInt()}%)',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: fuelColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.explore, size: 14, color: AppColors.primary),
                              const SizedBox(width: 4),
                              Text(
                                '~${((50.0 * (vehiculo.nivelGasolinaPorcentaje / 100.0)) * 12.5).toInt()} km',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVehicleImage(String? pathOrUrl) {
    if (pathOrUrl == null || pathOrUrl.isEmpty) {
      return Container(
        color: AppColors.primary,
        child: const Center(
          child: Icon(Icons.directions_car, size: 80, color: AppColors.onPrimary),
        ),
      );
    }

    ImageProvider provider;
    if (pathOrUrl.startsWith('http://') || pathOrUrl.startsWith('https://')) {
      provider = NetworkImage(pathOrUrl);
    } else {
      final file = File(pathOrUrl);
      if (file.existsSync()) {
        provider = FileImage(file);
      } else {
        provider = const NetworkImage('https://images.unsplash.com/photo-1549399542-7e3f8b79c341?q=80&w=800&auto=format&fit=crop');
      }
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        // 1. Fondo ambiental difuminado para llenar los bordes sin distorsión
        Image(
          image: provider,
          fit: BoxFit.cover,
          alignment: Alignment.center,
          errorBuilder: (_, __, ___) => const SizedBox(),
        ),
        Container(
          color: Colors.black.withValues(alpha: 0.55),
        ),
        // 2. Imagen principal del vehículo completa en primer plano sin recortes ni zoom excesivo
        Image(
          image: provider,
          fit: BoxFit.contain,
          alignment: Alignment.center,
          errorBuilder: (_, __, ___) => const Center(
            child: Icon(Icons.directions_car, size: 80, color: AppColors.onPrimary),
          ),
        ),
      ],
    );
  }
}
