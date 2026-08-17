import 'vehiculo.dart';
import 'mantenimiento.dart';
import '../../features/vehiculo/domain/entities/salud_general.dart';

class DashboardDataEntity {
  final VehiculoEntity vehiculo;
  final MantenimientoEntity servicioPrioritario;
  final List<ComponenteSaludEntity> componentesSalud;
  final bool esModoOffline;

  const DashboardDataEntity({
    required this.vehiculo,
    required this.servicioPrioritario,
    required this.componentesSalud,
    this.esModoOffline = false,
  });
}
