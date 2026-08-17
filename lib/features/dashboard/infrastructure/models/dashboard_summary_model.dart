import '../../domain/entities/dashboard_summary.dart';
import '../../../vehiculo/infrastructure/models/vehiculo_model.dart';
import '../../../mantenimiento/infrastructure/models/mantenimiento_model.dart';
import '../../../vehiculo/infrastructure/models/salud_general_model.dart';

class DashboardSummaryModel extends DashboardSummaryEntity {
  const DashboardSummaryModel({
    required VehiculoModel vehiculoModel,
    required MantenimientoModel servicioPrioritarioModel,
    required List<ComponenteSaludModel> componentesSaludModel,
    super.esModoOffline,
  }) : super(
          vehiculo: vehiculoModel,
          servicioPrioritario: servicioPrioritarioModel,
          componentesSalud: componentesSaludModel,
        );

  factory DashboardSummaryModel.fromJson(Map<String, dynamic> json, {bool isOffline = false}) {
    final data = json['data'] as Map<String, dynamic>? ?? json;
    
    final vehicleJson = data['vehicle'] as Map<String, dynamic>? ?? {};
    final priorityJson = data['priorityService'] as Map<String, dynamic>? ?? {};
    final healthJsonList = data['healthStatus'] as List<dynamic>? ?? [];

    return DashboardSummaryModel(
      vehiculoModel: VehiculoModel.fromJson(vehicleJson),
      servicioPrioritarioModel: MantenimientoModel.fromJson(priorityJson),
      componentesSaludModel: healthJsonList
          .map((item) => ComponenteSaludModel.fromJson(item as Map<String, dynamic>))
          .toList(),
      esModoOffline: isOffline,
    );
  }
}
