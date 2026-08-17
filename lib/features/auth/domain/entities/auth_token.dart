import 'usuario.dart';

class AuthTokenEntity {
  final String jwtToken;
  final String refreshToken;
  final UsuarioEntity usuario;

  const AuthTokenEntity({
    required this.jwtToken,
    required this.refreshToken,
    required this.usuario,
  });
}
