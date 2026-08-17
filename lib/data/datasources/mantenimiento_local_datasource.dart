import '../models/dashboard_data_model.dart';
import '../models/vehiculo_model.dart';
import '../models/mantenimiento_model.dart';
import '../models/salud_general_model.dart';

abstract class IMantenimientoLocalDataSource {
  Future<DashboardDataModel?> getLastCachedDashboard(String vehicleId);
  Future<void> cacheDashboardData(DashboardDataModel data);
}

class MantenimientoLocalDataSourceImpl implements IMantenimientoLocalDataSource {
  // Simulación de caché local en memoria / SQLite / Hive / SharedPreferences
  DashboardDataModel? _inMemoryCache;

  @override
  Future<DashboardDataModel?> getLastCachedDashboard(String vehicleId) async {
    // Si la caché está vacía, entregamos un estado inicial estático por defecto (Offline First Mock Data)
    if (_inMemoryCache == null) {
      _inMemoryCache = DashboardDataModel(
        vehiculoModel: VehiculoModel(
          id: 'f47ac10b-58cc-4372-a567-0e02b2c3d479',
          marca: 'Renault',
          modelo: 'Stepway',
          version: 'ZEN 2024',
          placa: 'BXY-492',
          kilometrajeActual: 45020,
          nivelGasolinaTexto: '3/4',
          nivelGasolinaPorcentaje: 75.0,
          imagenUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuClHNjwJ9FWqr2RKg6kpnCD5wjEMqSj9PtVEUpqS3HOl6DxJldwOkCbrr5YSc7k_34oBycox3LZsYAwOW1Cfhycp0UmB2a4Z99WenN1ol45MIg1jMsiba133plqT6rmDxlvkmFicxRVmz246PDgXtTfzpK6Swqb5TBkfduaWkgD65KdFktbMuRpsCDTZ4MUE6JPVedvSfTtoNB66YESTpp5XF2A0lfBWSyX1jARojsebGIt7XZyrDOj',
        ),
        servicioPrioritarioModel: MantenimientoModel(
          id: '9b1deb4d-3b7d-4bad-9bdd-2b0d7b3dcb6d',
          titulo: 'Próximo Servicio Recomendado',
          descripcion: 'Limpieza cuerpo de aceleración',
          kilometrosRestantes: 480,
          nivelPrioridad: 'HIGH',
          kilometrajeObjetivo: 45500,
        ),
        componentesSaludModel: [
          ComponenteSaludModel(id: '1', nombre: 'BATTERY', etiquetaCorta: 'Bat', porcentaje: 40),
          ComponenteSaludModel(id: '2', nombre: 'BRAKES', etiquetaCorta: 'Fre', porcentaje: 60),
          ComponenteSaludModel(id: '3', nombre: 'ENGINE', etiquetaCorta: 'Mot', porcentaje: 90, esDestacado: true),
          ComponenteSaludModel(id: '4', nombre: 'TIRES', etiquetaCorta: 'Lla', porcentaje: 75),
          ComponenteSaludModel(id: '5', nombre: 'FLUIDS', etiquetaCorta: 'Liq', porcentaje: 50),
        ],
        esModoOffline: true,
      );
    }
    return _inMemoryCache;
  }

  @override
  Future<void> cacheDashboardData(DashboardDataModel data) async {
    _inMemoryCache = data;
  }
}
