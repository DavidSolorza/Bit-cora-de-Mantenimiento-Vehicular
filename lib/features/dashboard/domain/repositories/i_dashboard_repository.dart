import '../entities/dashboard_summary.dart';

abstract class IDashboardRepository {
  Future<DashboardSummaryEntity> getDashboardSummary({required String vehicleId});
  Future<DashboardSummaryEntity> refreshDashboardSummary({required String vehicleId});
}
