import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import '../config/app_config.dart';
import '../errors/exceptions.dart';
import 'package:stitch_stepway_fleet_manager/features/auth/infrastructure/datasources/auth_local_datasource.dart';

/// Cliente HTTP Nativo basado exclusivamente en `dart:io` HttpClient (Cero SDKs comerciales)
/// para consumo estricto de APIs RESTful con auto-descompresión y codificación UTF-8 tolerante.
class NativeHttpClient {
  final HttpClient _client;

  NativeHttpClient({HttpClient? client}) : _client = client ?? HttpClient() {
    _client.connectionTimeout = AppConfig.timeoutDuration;
  }

  Future<Map<String, String>> _buildHeaders(Map<String, String>? customHeaders) async {
    final headers = <String, String>{
      HttpHeaders.contentTypeHeader: 'application/json; charset=utf-8',
      HttpHeaders.acceptHeader: 'application/json',
      HttpHeaders.authorizationHeader: AppConfig.apiSecretToken,
      'X-API-Key': 'core_backend_secret_key_2026',
    };

    // Intentar inyectar dinámicamente el JWT del usuario autenticado si existe
    try {
      final session = await AuthLocalDataSourceImpl().obtenerSesionGuardada();
      if (session != null && session.jwtToken.isNotEmpty) {
        headers[HttpHeaders.authorizationHeader] = 'Bearer ${session.jwtToken}';
      }
    } catch (_) {
      // Ignorar fallos para no interrumpir el flujo offline
    }

    if (customHeaders != null) {
      headers.addAll(customHeaders);
    }
    return headers;
  }

  Future<String> _readResponseBody(HttpClientResponse response) async {
    try {
      final List<int> bytes = await response.fold<List<int>>([], (prev, element) => prev..addAll(element));
      return utf8.decode(bytes, allowMalformed: true);
    } catch (e) {
      debugPrint('Error leyendo respuesta HTTP en NativeHttpClient: $e');
      return '';
    }
  }

  Future<Map<String, dynamic>> get(String url, {Map<String, String>? headers}) async {
    try {
      final uri = Uri.parse(url);
      final request = await _client.getUrl(uri);
      
      final finalHeaders = await _buildHeaders(headers);
      finalHeaders.forEach((key, value) {
        request.headers.set(key, value);
      });

      final response = await request.close();
      final bodyStr = await _readResponseBody(response);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return bodyStr.isNotEmpty ? json.decode(bodyStr) as Map<String, dynamic> : {};
      } else {
        throw ServerException('HTTP GET Error ${response.statusCode}: $bodyStr');
      }
    } catch (e) {
      if (e is ServerException) rethrow;
      throw NetworkException('Falla de red nativa GET: ${e.toString()}');
    }
  }

  Future<Map<String, dynamic>> post(String url, {required Map<String, dynamic> body, Map<String, String>? headers}) async {
    try {
      final uri = Uri.parse(url);
      final request = await _client.postUrl(uri);

      final finalHeaders = await _buildHeaders(headers);
      finalHeaders.forEach((key, value) {
        request.headers.set(key, value);
      });

      final jsonPayload = json.encode(body);
      final bytes = utf8.encode(jsonPayload);
      request.contentLength = bytes.length;
      request.add(bytes);

      final response = await request.close();
      final bodyStr = await _readResponseBody(response);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return bodyStr.isNotEmpty ? json.decode(bodyStr) as Map<String, dynamic> : {};
      } else {
        throw ServerException('HTTP POST Error ${response.statusCode}: $bodyStr');
      }
    } catch (e) {
      if (e is ServerException) rethrow;
      throw NetworkException('Falla de red nativa POST: ${e.toString()}');
    }
  }

  Future<Map<String, dynamic>> put(String url, {required Map<String, dynamic> body, Map<String, String>? headers}) async {
    try {
      final uri = Uri.parse(url);
      final request = await _client.putUrl(uri);

      final finalHeaders = await _buildHeaders(headers);
      finalHeaders.forEach((key, value) {
        request.headers.set(key, value);
      });

      final jsonPayload = json.encode(body);
      final bytes = utf8.encode(jsonPayload);
      request.contentLength = bytes.length;
      request.add(bytes);

      final response = await request.close();
      final bodyStr = await _readResponseBody(response);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return bodyStr.isNotEmpty ? json.decode(bodyStr) as Map<String, dynamic> : {};
      } else {
        throw ServerException('HTTP PUT Error ${response.statusCode}: $bodyStr');
      }
    } catch (e) {
      if (e is ServerException) rethrow;
      throw NetworkException('Falla de red nativa PUT: ${e.toString()}');
    }
  }

  Future<Map<String, dynamic>> delete(String url, {Map<String, String>? headers}) async {
    try {
      final uri = Uri.parse(url);
      final request = await _client.deleteUrl(uri);

      final finalHeaders = await _buildHeaders(headers);
      finalHeaders.forEach((key, value) {
        request.headers.set(key, value);
      });

      final response = await request.close();
      final bodyStr = await _readResponseBody(response);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return bodyStr.isNotEmpty ? json.decode(bodyStr) as Map<String, dynamic> : {};
      } else {
        throw ServerException('HTTP DELETE Error ${response.statusCode}: $bodyStr');
      }
    } catch (e) {
      if (e is ServerException) rethrow;
      throw NetworkException('Falla de red nativa DELETE: ${e.toString()}');
    }
  }
}
