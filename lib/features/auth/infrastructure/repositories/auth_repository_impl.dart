import '../../domain/entities/auth_token.dart';
import '../../domain/repositories/i_auth_repository.dart';
import '../datasources/auth_local_datasource.dart';
import '../datasources/auth_remote_datasource.dart';
import '../datasources/google_auth_datasource.dart';

class AuthRepositoryImpl implements IAuthRepository {
  final GoogleAuthDataSource googleAuthDataSource;
  final IAuthRemoteDataSource remoteDataSource;
  final IAuthLocalDataSource localDataSource;

  AuthRepositoryImpl({
    GoogleAuthDataSource? googleDS,
    IAuthRemoteDataSource? remoteDS,
    IAuthLocalDataSource? localDS,
  })  : googleAuthDataSource = googleDS ?? GoogleAuthDataSource(),
        remoteDataSource = remoteDS ?? AuthRemoteDataSourceImpl(),
        localDataSource = localDS ?? AuthLocalDataSourceImpl();

  @override
  Future<AuthTokenEntity> iniciarSesionConGoogle() async {
    final details = await googleAuthDataSource.obtenerGoogleCredentials();
    final tokenEntity = await remoteDataSource.autenticarConServidorPropio(details);
    await localDataSource.guardarSesion(tokenEntity);
    return tokenEntity;
  }

  @override
  Future<AuthTokenEntity?> obtenerSesionLocal() async {
    final sesionLocal = await localDataSource.obtenerSesionGuardada();
    if (sesionLocal == null) return null;

    // Intentar renovación silenciosa en segundo plano si hay red
    if (sesionLocal.refreshToken.isNotEmpty) {
      final nuevoAccessToken = await remoteDataSource.renovarTokenSilencioso(sesionLocal.refreshToken);
      if (nuevoAccessToken != null) {
        final nuevaSesion = AuthTokenEntity(
          jwtToken: nuevoAccessToken,
          refreshToken: sesionLocal.refreshToken,
          usuario: sesionLocal.usuario,
        );
        await localDataSource.guardarSesion(nuevaSesion);
        return nuevaSesion;
      }
    }

    return sesionLocal;
  }

  @override
  Future<void> cerrarSesion() async {
    final sesionLocal = await localDataSource.obtenerSesionGuardada();
    if (sesionLocal != null && sesionLocal.refreshToken.isNotEmpty) {
      await remoteDataSource.cerrarSesionServidor(sesionLocal.refreshToken);
    }
    await localDataSource.eliminarSesion();
  }
}
