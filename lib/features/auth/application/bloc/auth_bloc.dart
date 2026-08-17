import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/cerrar_sesion_usecase.dart';
import '../../domain/usecases/iniciar_sesion_con_google_usecase.dart';
import '../../domain/usecases/obtener_sesion_local_usecase.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final IniciarSesionConGoogleUseCase iniciarSesionConGoogleUseCase;
  final ObtenerSesionLocalUseCase obtenerSesionLocalUseCase;
  final CerrarSesionUseCase cerrarSesionUseCase;

  AuthBloc({
    required this.iniciarSesionConGoogleUseCase,
    required this.obtenerSesionLocalUseCase,
    required this.cerrarSesionUseCase,
  }) : super(const AuthInitialState()) {
    on<VerificarSesionInicialEvent>(_onVerificarSesionInicial);
    on<SolicitarLoginConGoogleEvent>(_onSolicitarLoginConGoogle);
    on<CerrarSesionEvent>(_onCerrarSesion);
  }

  Future<void> _onVerificarSesionInicial(
    VerificarSesionInicialEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoadingState());
    try {
      final sesion = await obtenerSesionLocalUseCase.execute();
      if (sesion != null) {
        emit(AuthenticatedState(sesion));
      } else {
        emit(const UnauthenticatedState());
      }
    } catch (e) {
      emit(UnauthenticatedState(mensajeError: 'Error verificando sesión: $e'));
    }
  }

  Future<void> _onSolicitarLoginConGoogle(
    SolicitarLoginConGoogleEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoadingState());
    try {
      final sesion = await iniciarSesionConGoogleUseCase.execute();
      emit(AuthenticatedState(sesion));
    } catch (e) {
      emit(UnauthenticatedState(mensajeError: 'No se pudo iniciar sesión con Google: $e'));
    }
  }

  Future<void> _onCerrarSesion(
    CerrarSesionEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoadingState());
    try {
      await cerrarSesionUseCase.execute();
      emit(const UnauthenticatedState());
    } catch (e) {
      emit(UnauthenticatedState(mensajeError: 'Error al cerrar sesión: $e'));
    }
  }
}
