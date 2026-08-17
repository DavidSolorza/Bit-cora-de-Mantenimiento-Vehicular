import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_mantenimiento_dashboard_usecase.dart';
import 'mantenimiento_event.dart';
import 'mantenimiento_state.dart';

class MantenimientoBloc extends Bloc<MantenimientoEvent, MantenimientoState> {
  final GetMantenimientoDashboardUseCase getDashboardUseCase;

  MantenimientoBloc({required this.getDashboardUseCase}) : super(MantenimientoInicialState()) {
    on<CargarDashboardEvent>(_onCargarDashboard);
    on<RefrescarDashboardEvent>(_onRefrescarDashboard);
  }

  Future<void> _onCargarDashboard(
    CargarDashboardEvent event,
    Emitter<MantenimientoState> emit,
  ) async {
    emit(MantenimientoCargandoState());
    try {
      final dashboardData = await getDashboardUseCase(
        vehicleId: event.vehicleId,
        forceRefresh: event.forceRefresh,
      );
      emit(MantenimientoCargadoState(
        dashboardData: dashboardData,
        esModoOffline: dashboardData.esModoOffline,
      ));
    } catch (e) {
      emit(MantenimientoErrorState(
        mensajeError: 'No se pudieron cargar los datos del vehículo. ${e.toString()}',
      ));
    }
  }

  Future<void> _onRefrescarDashboard(
    RefrescarDashboardEvent event,
    Emitter<MantenimientoState> emit,
  ) async {
    try {
      final dashboardData = await getDashboardUseCase(
        vehicleId: event.vehicleId,
        forceRefresh: true,
      );
      emit(MantenimientoCargadoState(
        dashboardData: dashboardData,
        esModoOffline: dashboardData.esModoOffline,
      ));
    } catch (e) {
      emit(MantenimientoErrorState(
        mensajeError: 'Error al refrescar la información: ${e.toString()}',
      ));
    }
  }
}
