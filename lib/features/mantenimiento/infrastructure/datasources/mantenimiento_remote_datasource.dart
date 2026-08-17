import '../../../../core/config/app_config.dart';
import '../../../../core/http/native_http_client.dart';
import '../models/mantenimiento_model.dart';

abstract class IMantenimientoRemoteDataSource {
  Future<List<MantenimientoModel>> fetchHistorial(String vehicleId);
  Future<MantenimientoModel> crearRegistro(Map<String, dynamic> body);
}

class MantenimientoRemoteDataSourceImpl implements IMantenimientoRemoteDataSource {
  final NativeHttpClient _httpClient;

  MantenimientoRemoteDataSourceImpl({NativeHttpClient? httpClient})
      : _httpClient = httpClient ?? NativeHttpClient();

  @override
  Future<List<MantenimientoModel>> fetchHistorial(String vehicleId) async {
    final url = '${AppConfig.apiBaseUrl}${AppConfig.endpointRegistros}?vehicle_id=$vehicleId';
    final response = await _httpClient.get(url);
    final dataList = (response['data'] as List<dynamic>?) ?? [];

    return dataList
        .map((json) => MantenimientoModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<MantenimientoModel> crearRegistro(Map<String, dynamic> body) async {
    final url = '${AppConfig.apiBaseUrl}${AppConfig.endpointRegistros}';
    final response = await _httpClient.post(url, body: body);
    final dataJson = (response['data'] as Map<String, dynamic>?) ?? response;

    return MantenimientoModel.fromJson(dataJson);
  }
}
