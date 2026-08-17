import '../models/dashboard_summary_model.dart';
import '../../../vehiculo/data/datasources/vehiculo_local_datasource.dart';
import '../../../mantenimiento/data/datasources/mantenimiento_local_datasource.dart';
import '../../../vehiculo/infrastructure/models/vehiculo_model.dart';
import '../../../mantenimiento/infrastructure/models/mantenimiento_model.dart';
import '../../../vehiculo/infrastructure/models/salud_general_model.dart';

abstract class IDashboardLocalDataSource {
  Future<DashboardSummaryModel?> getCachedDashboardSummary(String vehicleId);
  Future<void> cacheDashboardSummary(DashboardSummaryModel summary);
}

class DashboardLocalDataSourceImpl implements IDashboardLocalDataSource {
  final IVehiculoLocalDataSource _vehiculoDataSource;
  final IMantenimientoLocalDataSource _mantenimientoDataSource;

  DashboardLocalDataSourceImpl({
    IVehiculoLocalDataSource? vehiculoDataSource,
    IMantenimientoLocalDataSource? mantenimientoDataSource,
  })  : _vehiculoDataSource = vehiculoDataSource ?? VehiculoLocalDataSourceImpl(),
        _mantenimientoDataSource = mantenimientoDataSource ?? MantenimientoLocalDataSourceImpl();

  DashboardSummaryModel? _memoryCache;

  @override
  Future<DashboardSummaryModel?> getCachedDashboardSummary(String vehicleId) async {
    try {
      final vehiculo = await _vehiculoDataSource.getVehiculo(vehicleId);
      final componentesSalud = await _vehiculoDataSource.getSaludComponentes(vehicleId);
      final servicioPrioritario = await _mantenimientoDataSource.getServicioPrioritario(vehicleId);

      if (vehiculo != null) {
        _memoryCache = DashboardSummaryModel(
          vehiculoModel: vehiculo,
          servicioPrioritarioModel: servicioPrioritario ??
              const MantenimientoModel(
                id: 'default-prio',
                titulo: 'Mantenimiento General Recomendado',
                descripcion: 'Revisión periódica de niveles y frenos',
                kilometrosRestantes: 500,
                nivelPrioridad: 'MEDIUM',
                kilometrajeObjetivo: 46000,
              ),
          componentesSaludModel: componentesSalud.isNotEmpty
              ? componentesSalud
              : const [
                  ComponenteSaludModel(id: '1', nombre: 'BATTERY', etiquetaCorta: 'Bat', porcentaje: 92),
                  ComponenteSaludModel(id: '2', nombre: 'BRAKES', etiquetaCorta: 'Fre', porcentaje: 85),
                  ComponenteSaludModel(id: '3', nombre: 'ENGINE', etiquetaCorta: 'Mot', porcentaje: 98, esDestacado: true),
                  ComponenteSaludModel(id: '4', nombre: 'TIRES', etiquetaCorta: 'Lla', porcentaje: 78),
                  ComponenteSaludModel(id: '5', nombre: 'FLUIDS', etiquetaCorta: 'Liq', porcentaje: 90),
                ],
          esModoOffline: true,
        );
        return _memoryCache;
      }
    } catch (_) {
      // Ignorar fallback si falla el driver local y retornar caché previo
    }

    if (_memoryCache == null) {
      _memoryCache = const DashboardSummaryModel(
        vehiculoModel: VehiculoModel(
          id: 'veh-stepway-001',
          marca: 'Renault',
          modelo: 'Sandero Stepway',
          version: 'ZEN 1.6 16V',
          placa: 'BXY-492',
          kilometrajeActual: 45280,
          nivelGasolinaTexto: '3/4',
          nivelGasolinaPorcentaje: 75.0,
        ),
        servicioPrioritarioModel: MantenimientoModel(
          id: 'rec-003',
          titulo: 'Limpieza de Cuerpo de Aceleración',
          descripcion: 'Mantenimiento preventivo de inyección electrónica.',
          kilometrosRestantes: 480,
          nivelPrioridad: 'HIGH',
          kilometrajeObjetivo: 45500,
        ),
        componentesSaludModel: [
          ComponenteSaludModel(id: '1', nombre: 'BATTERY', etiquetaCorta: 'Bat', porcentaje: 92),
          ComponenteSaludModel(id: '2', nombre: 'BRAKES', etiquetaCorta: 'Fre', porcentaje: 85),
          ComponenteSaludModel(id: '3', nombre: 'ENGINE', etiquetaCorta: 'Mot', porcentaje: 98, esDestacado: true),
          ComponenteSaludModel(id: '4', nombre: 'TIRES', etiquetaCorta: 'Lla', porcentaje: 78),
          ComponenteSaludModel(id: '5', nombre: 'FLUIDS', etiquetaCorta: 'Liq', porcentaje: 90),
        ],
        esModoOffline: true,
      );
    }
    return _memoryCache;
  }

  @override
  Future<void> cacheDashboardSummary(DashboardSummaryModel summary) async {
    _memoryCache = summary;
  }
}
