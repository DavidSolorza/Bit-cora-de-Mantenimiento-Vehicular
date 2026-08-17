import 'dart:async';
import '../../domain/entities/dashboard_summary.dart';
import '../../domain/repositories/i_dashboard_repository.dart';
import '../datasources/dashboard_local_datasource.dart';
import '../datasources/dashboard_remote_datasource.dart';
import '../models/dashboard_summary_model.dart';
import '../../../vehiculo/infrastructure/models/vehiculo_model.dart';
import '../../../mantenimiento/infrastructure/models/mantenimiento_model.dart';
import '../../../vehiculo/infrastructure/models/salud_general_model.dart';

class DashboardRepositoryImpl implements IDashboardRepository {
  final IDashboardLocalDataSource localDataSource;
  final IDashboardRemoteDataSource remoteDataSource;

  DashboardRepositoryImpl({
    required this.localDataSource,
    required this.remoteDataSource,
  });

  @override
  Future<DashboardSummaryEntity> getDashboardSummary({required String vehicleId}) async {
    final cached = await localDataSource.getCachedDashboardSummary(vehicleId);
    if (cached != null) {
      return cached;
    }

    try {
      final remote = await remoteDataSource
          .fetchDashboardSummary(vehicleId)
          .timeout(const Duration(seconds: 3));
      await localDataSource.cacheDashboardSummary(remote);
      return remote;
    } catch (_) {
      rethrow;
    }
  }

  @override
  Future<DashboardSummaryEntity> refreshDashboardSummary({required String vehicleId}) async {
    final localData = await localDataSource.getCachedDashboardSummary(vehicleId);

    try {
      final remote = await remoteDataSource
          .fetchDashboardSummary(vehicleId)
          .timeout(const Duration(seconds: 4));
      
      if (localData != null) {
        final merged = DashboardSummaryModel(
          vehiculoModel: localData.vehiculo as VehiculoModel,
          servicioPrioritarioModel: remote.servicioPrioritario as MantenimientoModel,
          componentesSaludModel: localData.componentesSalud.cast<ComponenteSaludModel>(),
          esModoOffline: false,
        );
        await localDataSource.cacheDashboardSummary(merged);
        return merged;
      }
      
      await localDataSource.cacheDashboardSummary(remote);
      return remote;
    } catch (_) {
      if (localData != null) {
        return localData;
      }
      rethrow;
    }
  }

  Future<void> _tryBackgroundRefresh(String vehicleId) async {
    try {
      final remote = await remoteDataSource
          .fetchDashboardSummary(vehicleId)
          .timeout(const Duration(seconds: 3));
      await localDataSource.cacheDashboardSummary(remote);
    } catch (_) {
      // Ignorar fallos de red en segundo plano para mantener la estabilidad offline
    }
  }
}
