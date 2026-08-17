import '../entities/auth_token.dart';
import '../repositories/i_auth_repository.dart';

class ObtenerSesionLocalUseCase {
  final IAuthRepository repository;

  const ObtenerSesionLocalUseCase(this.repository);

  Future<AuthTokenEntity?> execute() async {
    return await repository.obtenerSesionLocal();
  }
}
