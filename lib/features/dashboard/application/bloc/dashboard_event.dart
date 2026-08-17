import 'package:equatable/equatable.dart';

abstract class DashboardEvent extends Equatable {
  const DashboardEvent();
  @override
  List<Object?> get props => [];
}

class CargarDashboardEvent extends DashboardEvent {
  final String vehicleId;
  final bool forceRefresh;

  const CargarDashboardEvent({required this.vehicleId, this.forceRefresh = false});

  @override
  List<Object?> get props => [vehicleId, forceRefresh];
}

class RefrescarDashboardEvent extends DashboardEvent {
  final String vehicleId;

  const RefrescarDashboardEvent({required this.vehicleId});

  @override
  List<Object?> get props => [vehicleId];
}
