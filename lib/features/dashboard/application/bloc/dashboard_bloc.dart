import 'package:flutter_bloc/flutter_bloc.dart';
import '../usecases/get_dashboard_summary_usecase.dart';
import 'dashboard_event.dart';
import 'dashboard_state.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final GetDashboardSummaryUseCase getDashboardSummaryUseCase;

  DashboardBloc({required this.getDashboardSummaryUseCase}) : super(DashboardInitialState()) {
    on<CargarDashboardEvent>(_onCargarDashboard);
    on<RefrescarDashboardEvent>(_onRefrescarDashboard);
  }

  Future<void> _onCargarDashboard(
    CargarDashboardEvent event,
    Emitter<DashboardState> emit,
  ) async {
    emit(DashboardLoadingState());
    try {
      final summary = await getDashboardSummaryUseCase(
        vehicleId: event.vehicleId,
        forceRefresh: event.forceRefresh,
      );
      emit(DashboardLoadedState(
        summary: summary,
        esModoOffline: summary.esModoOffline,
      ));
    } catch (e) {
      emit(DashboardErrorState(
        mensajeError: 'Error al consultar datos del vehículo: ${e.toString()}',
      ));
    }
  }

  Future<void> _onRefrescarDashboard(
    RefrescarDashboardEvent event,
    Emitter<DashboardState> emit,
  ) async {
    try {
      final summary = await getDashboardSummaryUseCase(
        vehicleId: event.vehicleId,
        forceRefresh: true,
      );
      emit(DashboardLoadedState(
        summary: summary,
        esModoOffline: summary.esModoOffline,
      ));
    } catch (e) {
      emit(DashboardErrorState(
        mensajeError: 'No se pudo sincronizar: ${e.toString()}',
      ));
    }
  }
}
