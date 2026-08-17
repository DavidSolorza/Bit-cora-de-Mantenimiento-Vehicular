import '../../../../core/database/sqlite_database_helper.dart';
import '../../domain/entities/auth_token.dart';
import '../../domain/entities/usuario.dart';

abstract class IAuthLocalDataSource {
  Future<void> guardarSesion(AuthTokenEntity session);
  Future<AuthTokenEntity?> obtenerSesionGuardada();
  Future<void> eliminarSesion();
}

class AuthLocalDataSourceImpl implements IAuthLocalDataSource {
  Future<void> _asegurarTabla(dynamic db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS active_sessions (
        id TEXT PRIMARY KEY NOT NULL,
        jwt_token TEXT NOT NULL,
        refresh_token TEXT,
        user_id TEXT NOT NULL,
        user_email TEXT NOT NULL,
        user_name TEXT NOT NULL,
        user_picture TEXT,
        created_at TEXT NOT NULL
      );
    ''');
  }

  @override
  Future<void> guardarSesion(AuthTokenEntity session) async {
    final db = await SqliteDatabaseHelper.instance.database;
    await _asegurarTabla(db);

    await db.delete('active_sessions');
    await db.insert('active_sessions', {
      'id': 'active_user_session',
      'jwt_token': session.jwtToken,
      'refresh_token': session.refreshToken,
      'user_id': session.usuario.id,
      'user_email': session.usuario.email,
      'user_name': session.usuario.nombre,
      'user_picture': session.usuario.fotoUrl,
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  @override
  Future<AuthTokenEntity?> obtenerSesionGuardada() async {
    try {
      final db = await SqliteDatabaseHelper.instance.database;
      await _asegurarTabla(db);

      final res = await db.query('active_sessions');
      if (res.isEmpty) return null;

      final row = res.first;
      return AuthTokenEntity(
        jwtToken: row['jwt_token'] as String,
        refreshToken: (row['refresh_token'] as String?) ?? '',
        usuario: UsuarioEntity(
          id: row['user_id'] as String,
          email: row['user_email'] as String,
          nombre: row['user_name'] as String,
          fotoUrl: row['user_picture'] as String?,
        ),
      );
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> eliminarSesion() async {
    try {
      final db = await SqliteDatabaseHelper.instance.database;
      await _asegurarTabla(db);
      await db.delete('active_sessions');
    } catch (_) {}
  }
}
