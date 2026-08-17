import '../../domain/entities/dashboard_data.dart';
import '../../domain/repositories/i_mantenimiento_repository.dart';
import '../datasources/mantenimiento_local_datasource.dart';
import '../datasources/mantenimiento_remote_datasource.dart';

class MantenimientoRepositoryImpl implements IMantenimientoRepository {
  final IMantenimientoLocalDataSource localDataSource;
  final IMantenimientoRemoteDataSource remoteDataSource;

  MantenimientoRepositoryImpl({
    required this.localDataSource,
    required this.remoteDataSource,
  });

  @override
  Future<DashboardDataEntity> getDashboardData({required String vehicleId}) async {
    // 1. Estrategia Offline-First: Retorna primero los datos cacheados localmente
    final localData = await localDataSource.getLastCachedDashboard(vehicleId);

    // 2. Intenta refrescar silenciosamente los datos remotos si es posible
    try {
      final remoteData = await remoteDataSource.fetchDashboardData(vehicleId);
      await localDataSource.cacheDashboardData(remoteData);
      return remoteData;
    } catch (_) {
      // Si falla la red, retorna los datos locales garantizando disponibilidad
      if (localData != null) {
        return localData;
      }
      rethrow;
    }
  }

  @override
  Future<DashboardDataEntity> refreshDashboardData({required String vehicleId}) async {
    try {
      final remoteData = await remoteDataSource.fetchDashboardData(vehicleId);
      await localDataSource.cacheDashboardData(remoteData);
      return remoteData;
    } catch (_) {
      final fallbackData = await localDataSource.getLastCachedDashboard(vehicleId);
      if (fallbackData != null) {
        return fallbackData;
      }
      rethrow;
    }
  }
}
