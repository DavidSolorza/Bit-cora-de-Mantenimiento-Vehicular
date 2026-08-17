import '../repositories/i_auth_repository.dart';

class CerrarSesionUseCase {
  final IAuthRepository repository;

  CerrarSesionUseCase(this.repository);

  Future<void> execute() async {
    return await repository.cerrarSesion();
  }
}
