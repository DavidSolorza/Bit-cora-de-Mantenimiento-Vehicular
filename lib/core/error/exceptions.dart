class ServerException implements Exception {
  final String message;
  ServerException([this.message = 'Error interno en el servidor']);
}

class CacheException implements Exception {
  final String message;
  CacheException([this.message = 'Error en la base de datos local']);
}
