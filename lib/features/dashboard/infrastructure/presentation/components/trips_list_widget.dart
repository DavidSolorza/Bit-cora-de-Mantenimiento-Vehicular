import 'package:flutter/material.dart';
import 'package:stitch_stepway_fleet_manager/core/database/sqlite_database_helper.dart';
import 'package:stitch_stepway_fleet_manager/core/theme/app_colors.dart';
import 'package:stitch_stepway_fleet_manager/core/theme/app_theme.dart';
import 'package:stitch_stepway_fleet_manager/core/config/currency_manager.dart';

class TripsListWidget extends StatefulWidget {
  final String vehicleId;
  final int currentVehicleOdometer;
  final VoidCallback onTripAdded;

  const TripsListWidget({
    super.key,
    required this.vehicleId,
    required this.currentVehicleOdometer,
    required this.onTripAdded,
  });

  @override
  State<TripsListWidget> createState() => _TripsListWidgetState();
}

class _TripsListWidgetState extends State<TripsListWidget> {
  List<Map<String, dynamic>> _trips = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadTrips();
  }

  Future<void> _loadTrips() async {
    setState(() => _loading = true);
    try {
      final db = await SqliteDatabaseHelper.instance.database;
      final results = await db.query(
        'trips',
        where: 'vehicle_id = ?',
        whereArgs: [widget.vehicleId],
        orderBy: 'trip_date DESC',
        limit: 5,
      );
      setState(() {
        _trips = results;
        _loading = false;
      });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  Future<void> _addTrip(String origin, String dest, int startKm, int endKm, double fuel) async {
    final db = await SqliteDatabaseHelper.instance.database;
    final id = 'trip-${DateTime.now().millisecondsSinceEpoch}';
    final date = DateTime.now().toIso8601String();

    await db.insert('trips', {
      'id': id,
      'vehicle_id': widget.vehicleId,
      'origin': origin,
      'destination': dest,
      'start_km': startKm,
      'end_km': endKm,
      'fuel_used_liters': fuel,
      'trip_date': date,
    });

    // Actualizar también el odómetro del vehículo en la tabla de vehículos
    await db.update(
      'vehicles',
      {
        'current_odometer_km': endKm,
        'updated_at': date,
      },
      where: 'id = ?',
      whereArgs: [widget.vehicleId],
    );

    _loadTrips();
    widget.onTripAdded();
  }

  void _showAddTripDialog() {
    final originController = TextEditingController();
    final destinationController = TextEditingController();
    final startKmController = TextEditingController(text: '${widget.currentVehicleOdometer}');
    final endKmController = TextEditingController();
    final fuelController = TextEditingController(text: '4.5');

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.surfaceContainerHigh,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: Row(
            children: const [
              Icon(Icons.commute, color: AppColors.primary),
              SizedBox(width: 8),
              Text('Registrar Nuevo Viaje', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: originController,
                  decoration: InputDecoration(
                    labelText: 'Origen',
                    prefixIcon: const Icon(Icons.location_on_outlined, color: AppColors.primary),
                    filled: true,
                    fillColor: AppColors.background,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: destinationController,
                  decoration: InputDecoration(
                    labelText: 'Destino',
                    prefixIcon: const Icon(Icons.flag_outlined, color: AppColors.primary),
                    filled: true,
                    fillColor: AppColors.background,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: startKmController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'KM Inicial',
                          filled: true,
                          fillColor: AppColors.background,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: endKmController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'KM Final',
                          filled: true,
                          fillColor: AppColors.background,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: fuelController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    labelText: 'Gasolina Consumida (Galones)',
                    prefixIcon: const Icon(Icons.local_gas_station, color: AppColors.primary),
                    filled: true,
                    fillColor: AppColors.background,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar', style: TextStyle(color: AppColors.onSurfaceVariant)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.onPrimary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () {
                final orig = originController.text.trim();
                final dest = destinationController.text.trim();
                final start = int.tryParse(startKmController.text) ?? widget.currentVehicleOdometer;
                final end = int.tryParse(endKmController.text) ?? (start + 10);
                final fuel = double.tryParse(fuelController.text) ?? 1.0;

                if (orig.isNotEmpty && dest.isNotEmpty && end > start) {
                  _addTrip(orig, dest, start, end, fuel);
                  Navigator.pop(context);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Por favor completa todos los campos correctamente.'),
                      backgroundColor: Colors.redAccent,
                    ),
                  );
                }
              },
              child: const Text('Guardar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const SizedBox(
        height: 100,
        child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
      );
    }

    return Container(
      padding: AppSpacing.paddingMd,
      decoration: AppDecorations.cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: const [
                  Icon(Icons.map, color: AppColors.primary, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'BITÁCORA DE VIAJES',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.onSurfaceVariant, letterSpacing: 0.5),
                  ),
                ],
              ),
              GestureDetector(
                onTap: _showAddTripDialog,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: const [
                      Icon(Icons.add_road, color: AppColors.primary, size: 14),
                      SizedBox(width: 4),
                      Text(
                        'Registrar',
                        style: TextStyle(color: AppColors.primary, fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          if (_trips.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20.0),
              child: Center(
                child: Text(
                  'No se han registrado viajes recientes.',
                  style: TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant),
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _trips.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final trip = _trips[index];
                final distance = trip['end_km'] - trip['start_km'];
                final date = DateTime.tryParse(trip['trip_date'] ?? '') ?? DateTime.now();
                final dateStr = '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}';

                return Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.background.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.primary.withValues(alpha: 0.1)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Cabecera del viaje
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.calendar_today_outlined, size: 12, color: AppColors.onSurfaceVariant),
                              const SizedBox(width: 4),
                              Text(dateStr, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.onSurfaceVariant)),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.green.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              '+$distance km',
                              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green, fontSize: 11),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // Mapa y Línea de Ruta (Visual timeline)
                      Row(
                        children: [
                          // Línea vertical punteada decorativa
                          Column(
                            children: [
                              const Icon(Icons.radio_button_checked, color: AppColors.primary, size: 14),
                              Container(
                                width: 2,
                                height: 16,
                                color: AppColors.primary.withValues(alpha: 0.3),
                              ),
                              const Icon(Icons.location_on, color: Colors.redAccent, size: 14),
                            ],
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  trip['origin'],
                                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: AppColors.onSurface),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  trip['destination'],
                                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: AppColors.onSurface),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          
                          // Simulación de mini Mapa / Ruta gráfica (Clickable)
                          GestureDetector(
                            onTap: () => _mostrarDetalleRuta(context, trip),
                            child: Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: AppColors.primary.withValues(alpha: 0.15)),
                              ),
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  CustomPaint(
                                    size: const Size(50, 50),
                                    painter: RoutePainter(),
                                  ),
                                  const Positioned(
                                    top: 8,
                                    left: 8,
                                    child: Icon(Icons.circle, size: 6, color: AppColors.primary),
                                  ),
                                  const Positioned(
                                    bottom: 8,
                                    right: 8,
                                    child: Icon(Icons.location_on, size: 10, color: Colors.redAccent),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Divider(height: 1),
                      const SizedBox(height: 8),

                      // Detalles del Vehículo
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Llegada: ${trip['end_km']} km',
                            style: const TextStyle(fontSize: 11, color: AppColors.onSurfaceVariant),
                          ),
                          Row(
                            children: [
                              const Icon(Icons.local_gas_station, size: 12, color: AppColors.primary),
                              const SizedBox(width: 4),
                              Text(
                                '${trip['fuel_used_liters']} L gastados',
                                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.onSurface),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  void _mostrarDetalleRuta(BuildContext context, Map<String, dynamic> trip) {
    final distance = trip['end_km'] - trip['start_km'];
    final fuel = trip['fuel_used_liters'];
    final origin = trip['origin'];
    final destination = trip['destination'];
    final date = DateTime.tryParse(trip['trip_date'] ?? '') ?? DateTime.now();
    final dateStr = '${date.day}/${date.month}/${date.year}';
    final estDuration = (distance * 1.8).round(); // Simular duración estimada

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: AppColors.surfaceContainerHigh,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          titlePadding: const EdgeInsets.all(16),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
          actionsPadding: const EdgeInsets.all(12),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: const [
                  Icon(Icons.map_rounded, color: AppColors.primary),
                  SizedBox(width: 8),
                  Text(
                    'Detalle del Recorrido',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.close, size: 20),
                onPressed: () => Navigator.pop(dialogContext),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Canvas de Mapa Detallado Grande
              Container(
                width: double.infinity,
                height: 180,
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.primary.withValues(alpha: 0.15)),
                ),
                child: Stack(
                  children: [
                    // Fondo tipo cuadrícula de GPS / Coordenadas
                    Positioned.fill(
                      child: Opacity(
                        opacity: 0.04,
                        child: GridPaper(
                          color: AppColors.primary,
                          interval: 30,
                          divisions: 1,
                          subdivisions: 1,
                        ),
                      ),
                    ),
                    // Trazado de ruta
                    Center(
                      child: CustomPaint(
                        size: const Size(200, 140),
                        painter: DetailedRoutePainter(),
                      ),
                    ),
                    // Pines
                    Positioned(
                      top: 40,
                      left: 60,
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text('Inicio', style: TextStyle(fontSize: 8, color: Colors.white, fontWeight: FontWeight.bold)),
                          ),
                          const Icon(Icons.radio_button_checked, size: 12, color: AppColors.primary),
                        ],
                      ),
                    ),
                    Positioned(
                      bottom: 30,
                      right: 60,
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.redAccent,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text('Fin', style: TextStyle(fontSize: 8, color: Colors.white, fontWeight: FontWeight.bold)),
                          ),
                          const Icon(Icons.location_on, size: 16, color: Colors.redAccent),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Itinerario
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    children: [
                      const Icon(Icons.radio_button_checked, color: AppColors.primary, size: 16),
                      Container(width: 2, height: 28, color: AppColors.primary.withValues(alpha: 0.3)),
                      const Icon(Icons.location_on, color: Colors.redAccent, size: 16),
                    ],
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          origin,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          destination,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 8),

              // Tabla de Métricas del Viaje
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildMetricCell('Distancia', '+$distance km', Icons.directions_car),
                  _buildMetricCell('Consumo', '$fuel Gal', Icons.local_gas_station),
                  _buildMetricCell('Duración', '$estDuration min', Icons.access_time),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMetricCell(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 18, color: AppColors.primary.withValues(alpha: 0.8)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
        Text(label, style: const TextStyle(fontSize: 10, color: AppColors.onSurfaceVariant)),
      ],
    );
  }
}

class DetailedRoutePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primary.withValues(alpha: 0.7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round;

    final path = Path();
    path.moveTo(65, 45);
    path.cubicTo(
      size.width * 0.4, size.height * 0.1,
      size.width * 0.2, size.height * 0.9,
      size.width - 65, size.height - 45,
    );

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class RoutePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primary.withValues(alpha: 0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;

    final path = Path();
    path.moveTo(10, 10);
    path.cubicTo(
      size.width * 0.3, size.height * 0.1,
      size.width * 0.6, size.height * 0.9,
      size.width - 12, size.height - 12,
    );

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
