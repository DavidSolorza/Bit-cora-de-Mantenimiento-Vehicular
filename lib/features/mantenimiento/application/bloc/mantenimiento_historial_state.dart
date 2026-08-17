import 'package:equatable/equatable.dart';
import '../../domain/entities/registro_mantenimiento.dart';

abstract class MantenimientoHistorialState extends Equatable {
  const MantenimientoHistorialState();
  @override
  List<Object?> get props => [];
}

class MantenimientoHistorialInitialState extends MantenimientoHistorialState {}
class MantenimientoHistorialLoadingState extends MantenimientoHistorialState {}

class MantenimientoHistorialLoadedState extends MantenimientoHistorialState {
  final List<RegistroMantenimientoEntity> todosLosRegistros;
  final List<RegistroMantenimientoEntity> registrosFiltrados;
  final double gastoTotal;
  final CategoriaMantenimiento? categoriaSeleccionada;

  const MantenimientoHistorialLoadedState({
    required this.todosLosRegistros,
    required this.registrosFiltrados,
    required this.gastoTotal,
    this.categoriaSeleccionada,
  });

  @override
  List<Object?> get props => [todosLosRegistros, registrosFiltrados, gastoTotal, categoriaSeleccionada];
}

class MantenimientoHistorialErrorState extends MantenimientoHistorialState {
  final String mensajeError;
  const MantenimientoHistorialErrorState({required this.mensajeError});

  @override
  List<Object?> get props => [mensajeError];
}
