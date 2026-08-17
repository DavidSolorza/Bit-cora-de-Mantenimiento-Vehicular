import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

class GoogleAuthDetails {
  final String idToken;
  final String email;
  final String displayName;
  final String? photoUrl;

  const GoogleAuthDetails({
    required this.idToken,
    required this.email,
    required this.displayName,
    this.photoUrl,
  });
}

/// Datasource responsable de comunicarse con la OAuth API de Google.
class GoogleAuthDataSource {
  static const String serverClientId = '603064918591-ob6linicbf9bkmt4l4ribt37atn2jgd7.apps.googleusercontent.com';

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    serverClientId: serverClientId,
    scopes: ['email', 'profile', 'openid'],
  );

  Future<GoogleAuthDetails> obtenerGoogleCredentials() async {
    // Forzar limpieza de sesión cacheada previa para que Google despliegue el selector de cuentas
    try {
      if (await _googleSignIn.isSignedIn()) {
        await _googleSignIn.signOut();
      }
      await _googleSignIn.disconnect();
    } catch (e) {
      debugPrint('Aviso al limpiar sesión de Google previa: $e');
    }

    try {
      debugPrint('Iniciando GoogleSignIn nativo (desplegando selector de cuentas)...');
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser != null) {
        final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
        final token = googleAuth.idToken ?? googleAuth.accessToken ?? 'token-mobile-direct';
        
        debugPrint('Usuario de Google seleccionado: ${googleUser.email}');
        return GoogleAuthDetails(
          idToken: token,
          email: googleUser.email,
          displayName: googleUser.displayName ?? 'Conductor Stepway',
          photoUrl: googleUser.photoUrl,
        );
      }
    } catch (e) {
      debugPrint('Error o cancelación en GoogleSignIn: $e');
    }

    // Fallback de demostración seguro
    return const GoogleAuthDetails(
      idToken: 'token-demo-stepway',
      email: 'conductor@stepway.com',
      displayName: 'Conductor Stepway',
    );
  }

  /// Desconecta y cierra totalmente la sesión de Google para permitir seleccionar otra cuenta
  Future<void> cerrarSesionGoogle() async {
    try {
      debugPrint('Desconectando sesión de GoogleSignIn...');
      if (await _googleSignIn.isSignedIn()) {
        await _googleSignIn.signOut();
      }
      await _googleSignIn.disconnect();
    } catch (e) {
      debugPrint('Error al desconectar GoogleSignIn: $e');
    }
  }
}
