abstract class Failure {
  final String message;
  const Failure(this.message);
}

class ServerFailure extends Failure {
  const ServerFailure([super.message = 'Falla de conexión con el servidor REST.']);
}

class CacheFailure extends Failure {
  const CacheFailure([super.message = 'Falla al recuperar los datos almacenados localmente.']);
}

class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'Modo Offline detectado. Mostrando datos locales.']);
}
