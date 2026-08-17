import '../../domain/entities/mantenimiento.dart';

class MantenimientoModel extends MantenimientoEntity {
  const MantenimientoModel({
    required super.id,
    required super.titulo,
    required super.descripcion,
    required super.kilometrosRestantes,
    required super.nivelPrioridad,
    super.kilometrajeObjetivo,
  });

  factory MantenimientoModel.fromJson(Map<String, dynamic> json) {
    return MantenimientoModel(
      id: json['id'] as String? ?? '9b1deb4d-3b7d-4bad-9bdd-2b0d7b3dcb6d',
      titulo: json['title'] as String? ?? 'Próximo Servicio Recomendado',
      descripcion: json['description'] as String? ?? 'Limpieza cuerpo de aceleración',
      kilometrosRestantes: json['remainingKm'] as int? ?? 480,
      nivelPrioridad: json['priorityLevel'] as String? ?? 'HIGH',
      kilometrajeObjetivo: json['dueKm'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': titulo,
      'description': descripcion,
      'remainingKm': kilometrosRestantes,
      'priorityLevel': nivelPrioridad,
      'dueKm': kilometrajeObjetivo,
    };
  }
}
