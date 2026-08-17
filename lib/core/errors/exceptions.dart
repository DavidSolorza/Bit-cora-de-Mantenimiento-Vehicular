class ServerException implements Exception {
  final String message;
  ServerException([this.message = 'Error interno en la API del servidor']);
}

class CacheException implements Exception {
  final String message;
  CacheException([this.message = 'Error al acceder a la caché local']);
}

class NetworkException implements Exception {
  final String message;
  NetworkException([this.message = 'Sin conectividad a la red']);
}
