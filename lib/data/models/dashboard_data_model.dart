import '../../domain/entities/dashboard_data.dart';
import '../../features/vehiculo/domain/entities/salud_general.dart';
import 'vehiculo_model.dart';
import 'mantenimiento_model.dart';
import 'salud_general_model.dart';

class DashboardDataModel extends DashboardDataEntity {
  const DashboardDataModel({
    required VehiculoModel vehiculoModel,
    required MantenimientoModel servicioPrioritarioModel,
    required List<ComponenteSaludEntity> componentesSaludModel,
    super.esModoOffline,
  }) : super(
          vehiculo: vehiculoModel,
          servicioPrioritario: servicioPrioritarioModel,
          componentesSalud: componentesSaludModel,
        );

  factory DashboardDataModel.fromJson(Map<String, dynamic> json, {bool isOffline = false}) {
    final data = json['data'] as Map<String, dynamic>? ?? json;
    
    final vehicleJson = data['vehicle'] as Map<String, dynamic>? ?? {};
    final priorityJson = data['priorityService'] as Map<String, dynamic>? ?? {};
    final healthJsonList = data['healthStatus'] as List<dynamic>? ?? [];

    return DashboardDataModel(
      vehiculoModel: VehiculoModel.fromJson(vehicleJson),
      servicioPrioritarioModel: MantenimientoModel.fromJson(priorityJson),
      componentesSaludModel: healthJsonList
          .map((item) => ComponenteSaludModel.fromJson(item as Map<String, dynamic>))
          .toList(),
      esModoOffline: isOffline,
    );
  }
}
