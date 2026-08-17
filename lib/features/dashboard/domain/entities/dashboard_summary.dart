import '../../../../features/vehiculo/domain/entities/vehiculo.dart';
import '../../../../features/mantenimiento/domain/entities/mantenimiento.dart';
import '../../../../features/vehiculo/domain/entities/salud_general.dart';

class DashboardSummaryEntity {
  final VehiculoEntity vehiculo;
  final MantenimientoEntity servicioPrioritario;
  final List<ComponenteSaludEntity> componentesSalud;
  final bool esModoOffline;

  const DashboardSummaryEntity({
    required this.vehiculo,
    required this.servicioPrioritario,
    required this.componentesSalud,
    this.esModoOffline = false,
  });
}
