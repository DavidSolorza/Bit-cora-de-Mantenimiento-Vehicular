import '../../domain/entities/dashboard_summary.dart';
import '../../domain/repositories/i_dashboard_repository.dart';

class GetDashboardSummaryUseCase {
  final IDashboardRepository repository;

  GetDashboardSummaryUseCase(this.repository);

  Future<DashboardSummaryEntity> call({required String vehicleId, bool forceRefresh = false}) async {
    if (forceRefresh) {
      return await repository.refreshDashboardSummary(vehicleId: vehicleId);
    }
    return await repository.getDashboardSummary(vehicleId: vehicleId);
  }
}
