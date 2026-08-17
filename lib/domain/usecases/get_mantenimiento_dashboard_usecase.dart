import '../entities/dashboard_data.dart';
import '../repositories/i_mantenimiento_repository.dart';

class GetMantenimientoDashboardUseCase {
  final IMantenimientoRepository repository;

  GetMantenimientoDashboardUseCase(this.repository);

  Future<DashboardDataEntity> call({required String vehicleId, bool forceRefresh = false}) async {
    if (forceRefresh) {
      return await repository.refreshDashboardData(vehicleId: vehicleId);
    }
    return await repository.getDashboardData(vehicleId: vehicleId);
  }
}
