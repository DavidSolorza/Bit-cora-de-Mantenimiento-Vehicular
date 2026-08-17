import 'package:flutter_bloc/flutter_bloc.dart';
import '../usecases/get_historial_mantenimientos_usecase.dart';
import '../usecases/agregar_registro_mantenimiento_usecase.dart';
import '../../domain/entities/registro_mantenimiento.dart';
import 'mantenimiento_historial_event.dart';
import 'mantenimiento_historial_state.dart';

class MantenimientoHistorialBloc extends Bloc<MantenimientoHistorialEvent, MantenimientoHistorialState> {
  final GetHistorialMantenimientosUseCase getHistorialUseCase;
  final AgregarRegistroMantenimientoUseCase agregarRegistroUseCase;

  MantenimientoHistorialBloc({
    required this.getHistorialUseCase,
    required this.agregarRegistroUseCase,
  }) : super(MantenimientoHistorialInitialState()) {
    on<CargarHistorialEvent>(_onCargarHistorial);
    on<AgregarNuevoRegistroEvent>(_onAgregarRegistro);
    on<FiltrarCategoriaEvent>(_onFiltrarCategoria);
    on<EditarRegistroEvent>(_onEditarRegistro);
    on<EliminarRegistroEvent>(_onEliminarRegistro);
  }

  Future<void> _onCargarHistorial(
    CargarHistorialEvent event,
    Emitter<MantenimientoHistorialState> emit,
  ) async {
    emit(MantenimientoHistorialLoadingState());
    try {
      final registros = await getHistorialUseCase(vehicleId: event.vehicleId);
      final total = _calcularTotal(registros);
      emit(MantenimientoHistorialLoadedState(
        todosLosRegistros: registros,
        registrosFiltrados: registros,
        gastoTotal: total,
      ));
    } catch (e) {
      emit(MantenimientoHistorialErrorState(
        mensajeError: 'No se pudo cargar el historial: ${e.toString()}',
      ));
    }
  }

  Future<void> _onAgregarRegistro(
    AgregarNuevoRegistroEvent event,
    Emitter<MantenimientoHistorialState> emit,
  ) async {
    try {
      await agregarRegistroUseCase(vehicleId: event.vehicleId, registro: event.registro);
      final nuevosRegistros = await getHistorialUseCase(vehicleId: event.vehicleId);
      final total = _calcularTotal(nuevosRegistros);
      
      emit(MantenimientoHistorialLoadedState(
        todosLosRegistros: nuevosRegistros,
        registrosFiltrados: nuevosRegistros,
        gastoTotal: total,
      ));
    } catch (e) {
      emit(MantenimientoHistorialErrorState(
        mensajeError: 'No se pudo guardar el registro: ${e.toString()}',
      ));
    }
  }

  void _onFiltrarCategoria(
    FiltrarCategoriaEvent event,
    Emitter<MantenimientoHistorialState> emit,
  ) {
    if (state is MantenimientoHistorialLoadedState) {
      final currentState = state as MantenimientoHistorialLoadedState;
      final categoria = event.categoria;

      final filtrados = categoria == null
          ? currentState.todosLosRegistros
          : currentState.todosLosRegistros.where((r) => r.categoria == categoria).toList();

      emit(MantenimientoHistorialLoadedState(
        todosLosRegistros: currentState.todosLosRegistros,
        registrosFiltrados: filtrados,
        gastoTotal: _calcularTotal(filtrados),
        categoriaSeleccionada: categoria,
      ));
    }
  }

  Future<void> _onEditarRegistro(
    EditarRegistroEvent event,
    Emitter<MantenimientoHistorialState> emit,
  ) async {
    try {
      await agregarRegistroUseCase.repository.actualizarRegistro(
        vehicleId: event.vehicleId,
        registro: event.registro,
      );
      final nuevosRegistros = await getHistorialUseCase(vehicleId: event.vehicleId);
      final total = _calcularTotal(nuevosRegistros);
      
      emit(MantenimientoHistorialLoadedState(
        todosLosRegistros: nuevosRegistros,
        registrosFiltrados: nuevosRegistros,
        gastoTotal: total,
      ));
    } catch (e) {
      emit(MantenimientoHistorialErrorState(
        mensajeError: 'No se pudo editar el registro: ${e.toString()}',
      ));
    }
  }

  Future<void> _onEliminarRegistro(
    EliminarRegistroEvent event,
    Emitter<MantenimientoHistorialState> emit,
  ) async {
    try {
      await agregarRegistroUseCase.repository.eliminarRegistro(
        vehicleId: event.vehicleId,
        id: event.registroId,
      );
      final nuevosRegistros = await getHistorialUseCase(vehicleId: event.vehicleId);
      final total = _calcularTotal(nuevosRegistros);
      
      emit(MantenimientoHistorialLoadedState(
        todosLosRegistros: nuevosRegistros,
        registrosFiltrados: nuevosRegistros,
        gastoTotal: total,
      ));
    } catch (e) {
      emit(MantenimientoHistorialErrorState(
        mensajeError: 'No se pudo eliminar el registro: ${e.toString()}',
      ));
    }
  }

  double _calcularTotal(List<RegistroMantenimientoEntity> lista) {
    return lista.fold(0.0, (sum, item) => sum + item.costo);
  }
}
