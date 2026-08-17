import '../entities/dashboard_data.dart';

abstract class IMantenimientoRepository {
  /// Obtiene los datos del Dashboard de mantenimiento de forma Offline-First
  Future<DashboardDataEntity> getDashboardData({required String vehicleId});
  
  /// Fuerza una sincronización con el servidor remoto
  Future<DashboardDataEntity> refreshDashboardData({required String vehicleId});
}
