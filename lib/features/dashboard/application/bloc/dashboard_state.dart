import 'package:equatable/equatable.dart';
import '../../domain/entities/dashboard_summary.dart';

abstract class DashboardState extends Equatable {
  const DashboardState();
  @override
  List<Object?> get props => [];
}

class DashboardInitialState extends DashboardState {}
class DashboardLoadingState extends DashboardState {}

class DashboardLoadedState extends DashboardState {
  final DashboardSummaryEntity summary;
  final bool esModoOffline;

  const DashboardLoadedState({
    required this.summary,
    this.esModoOffline = false,
  });

  @override
  List<Object?> get props => [summary, esModoOffline];
}

class DashboardErrorState extends DashboardState {
  final String mensajeError;
  const DashboardErrorState({required this.mensajeError});

  @override
  List<Object?> get props => [mensajeError];
}
