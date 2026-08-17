import 'package:equatable/equatable.dart';
import '../../domain/entities/auth_token.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitialState extends AuthState {
  const AuthInitialState();
}

class AuthLoadingState extends AuthState {
  const AuthLoadingState();
}

class AuthenticatedState extends AuthState {
  final AuthTokenEntity authToken;

  const AuthenticatedState(this.authToken);

  @override
  List<Object?> get props => [authToken];
}

class UnauthenticatedState extends AuthState {
  final String? mensajeError;

  const UnauthenticatedState({this.mensajeError});

  @override
  List<Object?> get props => [mensajeError];
}
