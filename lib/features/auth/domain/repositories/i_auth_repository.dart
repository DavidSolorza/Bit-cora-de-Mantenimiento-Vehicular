import '../entities/auth_token.dart';

abstract class IAuthRepository {
  /// Inicia sesión con Google obtieniendo el idToken de Google
  /// y validándolo contra el servidor propio vía Cloudflare Tunnel.
  Future<AuthTokenEntity> iniciarSesionConGoogle();

  /// Recupera el JWT de la sesión persistida localmente (Offline-First).
  Future<AuthTokenEntity?> obtenerSesionLocal();

  /// Cierra la sesión activa borrando el JWT local.
  Future<void> cerrarSesion();
}
