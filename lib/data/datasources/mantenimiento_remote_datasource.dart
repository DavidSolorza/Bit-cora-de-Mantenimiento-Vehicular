import 'dart:convert';
import 'dart:io';
import '../models/dashboard_data_model.dart';
import '../../core/error/exceptions.dart';

abstract class IMantenimientoRemoteDataSource {
  Future<DashboardDataModel> fetchDashboardData(String vehicleId);
}

class MantenimientoRemoteDataSourceImpl implements IMantenimientoRemoteDataSource {
  final HttpClient _httpClient;
  final String _baseUrl;

  MantenimientoRemoteDataSourceImpl({
    HttpClient? httpClient,
    String baseUrl = 'https://api.stepwaymanager.com/v1',
  })  : _httpClient = httpClient ?? HttpClient(),
        _baseUrl = baseUrl;

  @override
  Future<DashboardDataModel> fetchDashboardData(String vehicleId) async {
    try {
      final url = Uri.parse('$_baseUrl/vehicles/$vehicleId/dashboard');
      final request = await _httpClient.getUrl(url);
      
      // Encabezados HTTP nativos
      request.headers.set(HttpHeaders.contentTypeHeader, 'application/json');
      request.headers.set(HttpHeaders.acceptHeader, 'application/json');
      
      final response = await request.close();

        Stream<List<int>> stream = response;
        if (response.headers.value(HttpHeaders.contentEncodingHeader) == 'gzip') {
          stream = response.transform(gzip.decoder);
        }
        final bytes = await stream.fold<List<int>>([], (prev, element) => prev..addAll(element));
        final responseBody = utf8.decode(bytes, allowMalformed: true);
        final Map<String, dynamic> jsonMap = json.decode(responseBody);
        return DashboardDataModel.fromJson(jsonMap, isOffline: false);
      } else {
        throw ServerException('Respuesta de servidor no exitosa: ${response.statusCode}');
      }
    } catch (e) {
      // Si la llamada HTTP falla (ej. sin red), lanzamos una ServerException/NetworkException
      throw ServerException(e.toString());
    }
  }
}
