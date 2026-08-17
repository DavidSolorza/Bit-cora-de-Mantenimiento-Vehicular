import 'package:equatable/equatable.dart';
import '../../domain/entities/dashboard_data.dart';

abstract class MantenimientoState extends Equatable {
  const MantenimientoState();

  @override
  List<Object?> get props => [];
}

class MantenimientoInicialState extends MantenimientoState {}

class MantenimientoCargandoState extends MantenimientoState {}

class MantenimientoCargadoState extends MantenimientoState {
  final DashboardDataEntity dashboardData;
  final bool esModoOffline;

  const MantenimientoCargadoState({
    required this.dashboardData,
    this.esModoOffline = false,
  });

  @override
  List<Object?> get props => [dashboardData, esModoOffline];
}

class MantenimientoErrorState extends MantenimientoState {
  final String mensajeError;

  const MantenimientoErrorState({required this.mensajeError});

  @override
  List<Object?> get props => [mensajeError];
}
