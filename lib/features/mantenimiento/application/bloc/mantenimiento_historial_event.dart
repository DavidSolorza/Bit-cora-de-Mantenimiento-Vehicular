import 'package:equatable/equatable.dart';
import '../../domain/entities/registro_mantenimiento.dart';

abstract class MantenimientoHistorialEvent extends Equatable {
  const MantenimientoHistorialEvent();
  @override
  List<Object?> get props => [];
}

class CargarHistorialEvent extends MantenimientoHistorialEvent {
  final String vehicleId;
  const CargarHistorialEvent({required this.vehicleId});

  @override
  List<Object?> get props => [vehicleId];
}

class AgregarNuevoRegistroEvent extends MantenimientoHistorialEvent {
  final String vehicleId;
  final RegistroMantenimientoEntity registro;

  const AgregarNuevoRegistroEvent({required this.vehicleId, required this.registro});

  @override
  List<Object?> get props => [vehicleId, registro];
}

class FiltrarCategoriaEvent extends MantenimientoHistorialEvent {
  final CategoriaMantenimiento? categoria;

  const FiltrarCategoriaEvent({this.categoria});

  @override
  List<Object?> get props => [categoria];
}

class EditarRegistroEvent extends MantenimientoHistorialEvent {
  final String vehicleId;
  final RegistroMantenimientoEntity registro;

  const EditarRegistroEvent({required this.vehicleId, required this.registro});

  @override
  List<Object?> get props => [vehicleId, registro];
}

class EliminarRegistroEvent extends MantenimientoHistorialEvent {
  final String vehicleId;
  final String registroId;

  const EliminarRegistroEvent({required this.vehicleId, required this.registroId});

  @override
  List<Object?> get props => [vehicleId, registroId];
}
