import '../../../../core/http/native_http_client.dart';
import '../../../../core/config/app_config.dart';
import '../models/dashboard_summary_model.dart';

abstract class IDashboardRemoteDataSource {
  Future<DashboardSummaryModel> fetchDashboardSummary(String vehicleId);
}

class DashboardRemoteDataSourceImpl implements IDashboardRemoteDataSource {
  final NativeHttpClient _httpClient;

  DashboardRemoteDataSourceImpl({NativeHttpClient? httpClient})
      : _httpClient = httpClient ?? NativeHttpClient();

  @override
  Future<DashboardSummaryModel> fetchDashboardSummary(String vehicleId) async {
    final response = await _httpClient.get(
      '${AppConfig.apiBaseUrl}${AppConfig.endpointDashboard}',
    );

    final dataJson = (response['data'] as Map<String, dynamic>?) ?? response;
    return DashboardSummaryModel.fromJson(dataJson, isOffline: false);
  }
}
