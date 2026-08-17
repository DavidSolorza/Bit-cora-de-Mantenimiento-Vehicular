import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class VerificarSesionInicialEvent extends AuthEvent {
  const VerificarSesionInicialEvent();
}

class SolicitarLoginConGoogleEvent extends AuthEvent {
  const SolicitarLoginConGoogleEvent();
}

class CerrarSesionEvent extends AuthEvent {
  const CerrarSesionEvent();
}
