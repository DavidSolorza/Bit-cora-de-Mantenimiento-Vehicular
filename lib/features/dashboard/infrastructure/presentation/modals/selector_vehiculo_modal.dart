import 'package:flutter/material.dart';
import 'package:stitch_stepway_fleet_manager/core/config/app_config.dart';
import 'package:stitch_stepway_fleet_manager/core/http/native_http_client.dart';
import 'package:stitch_stepway_fleet_manager/core/theme/app_colors.dart';
import 'package:stitch_stepway_fleet_manager/core/theme/app_theme.dart';
import 'package:stitch_stepway_fleet_manager/features/vehiculo/domain/entities/vehiculo.dart';
import 'package:stitch_stepway_fleet_manager/features/vehiculo/infrastructure/models/vehiculo_model.dart';

/// Modal BottomSheet para cambiar entre los vehículos de la flota registrados en PostgreSQL
class SelectorVehiculoModal extends StatefulWidget {
  final Function(VehiculoEntity) onVehiculoSeleccionado;

  const SelectorVehiculoModal({
    super.key,
    required this.onVehiculoSeleccionado,
  });

  static void show(
    BuildContext context, {
    required Function(VehiculoEntity) onVehiculoSeleccionado,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SelectorVehiculoModal(
        onVehiculoSeleccionado: onVehiculoSeleccionado,
      ),
    );
  }

  @override
  State<SelectorVehiculoModal> createState() => _SelectorVehiculoModalState();
}

class _SelectorVehiculoModalState extends State<SelectorVehiculoModal> {
  final NativeHttpClient _httpClient = NativeHttpClient();
  List<VehiculoModel> _vehiculos = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _cargarVehiculos();
  }

  Future<void> _cargarVehiculos() async {
    try {
      final url = '${AppConfig.apiBaseUrl}${AppConfig.endpointVehiculos}';
      final response = await _httpClient.get(url);
      final dataList = (response['data'] as List<dynamic>?) ?? [];

      setState(() {
        _vehiculos = dataList
            .map((v) => VehiculoModel.fromJson(v as Map<String, dynamic>))
            .toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Falla al obtener vehículos de la nube PostgreSQL';
        _isLoading = false;
      });
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
            children: const [
              Icon(Icons.garage, color: AppColors.primary),
              SizedBox(width: 8),
              Text(
                'Seleccionar Vehículo de Flota',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            'Vehículos sincronizados con PostgreSQL Cloud',
            style: TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant),
          ),
          const SizedBox(height: AppSpacing.md),
          if (_isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(24.0),
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
            )
          else if (_errorMessage != null)
            Center(
              child: Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
            )
          else
            ..._vehiculos.map((v) => Container(
                  margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerHigh.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.primary.withValues(alpha: 0.1)),
                  ),
                  child: ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: AppColors.primary,
                      child: Icon(Icons.directions_car, color: AppColors.onPrimary, size: 20),
                    ),
                    title: Text(
                      '${v.marca} ${v.modelo}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text('${v.version} • ${v.kilometrajeActual} km'),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        v.placa,
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    onTap: () {
                      widget.onVehiculoSeleccionado(v);
                      Navigator.pop(context);
                    },
                  ),
                )),
          const SizedBox(height: AppSpacing.md),
        ],
      ),
    );
  }
}
