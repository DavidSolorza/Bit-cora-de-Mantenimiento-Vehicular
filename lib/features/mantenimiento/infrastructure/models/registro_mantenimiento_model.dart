import '../../domain/entities/registro_mantenimiento.dart';

class RegistroMantenimientoModel extends RegistroMantenimientoEntity {
  const RegistroMantenimientoModel({
    required super.id,
    required super.titulo,
    required super.fecha,
    required super.costo,
    required super.kilometraje,
    required super.categoria,
  });

  factory RegistroMantenimientoModel.fromJson(Map<String, dynamic> json) {
    return RegistroMantenimientoModel(
      id: json['id'] as String,
      titulo: json['title'] as String,
      fecha: DateTime.parse(json['date'] as String),
      costo: (json['cost'] as num).toDouble(),
      kilometraje: json['odometerKm'] as int,
      categoria: _parseCategoria(json['category'] as String),
    );
  }

  static CategoriaMantenimiento _parseCategoria(String catStr) {
    switch (catStr.toUpperCase()) {
      case 'GASOLINA':
      case 'FUEL':
        return CategoriaMantenimiento.gasolina;
      case 'LAVADO':
      case 'WASH':
        return CategoriaMantenimiento.lavado;
      default:
        return CategoriaMantenimiento.taller;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': titulo,
      'date': fecha.toIso8601String(),
      'cost': costo,
      'odometerKm': kilometraje,
      'category': categoria.name,
    };
  }
}
