abstract class Failure {
  final String message;
  const Failure(this.message);
}

class ServerFailure extends Failure {
  const ServerFailure([super.message = 'Error en la conexión con el servidor.']);
}

class CacheFailure extends Failure {
  const CacheFailure([super.message = 'No se encontraron datos guardados localmente.']);
}

class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'Sin conexión a Internet. Operando en modo offline.']);
}
