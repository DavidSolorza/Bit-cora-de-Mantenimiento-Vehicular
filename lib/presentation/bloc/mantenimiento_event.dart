import 'package:equatable/equatable.dart';

abstract class MantenimientoEvent extends Equatable {
  const MantenimientoEvent();

  @override
  List<Object?> get props => [];
}

class CargarDashboardEvent extends MantenimientoEvent {
  final String vehicleId;
  final bool forceRefresh;

  const CargarDashboardEvent({
    required this.vehicleId,
    this.forceRefresh = false,
  });

  @override
  List<Object?> get props => [vehicleId, forceRefresh];
}

class RefrescarDashboardEvent extends MantenimientoEvent {
  final String vehicleId;

  const RefrescarDashboardEvent({required this.vehicleId});

  @override
  List<Object?> get props => [vehicleId];
}
