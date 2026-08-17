import '../entities/auth_token.dart';
import '../repositories/i_auth_repository.dart';

class IniciarSesionConGoogleUseCase {
  final IAuthRepository repository;

  const IniciarSesionConGoogleUseCase(this.repository);

  Future<AuthTokenEntity> execute() async {
    return await repository.iniciarSesionConGoogle();
  }
}
