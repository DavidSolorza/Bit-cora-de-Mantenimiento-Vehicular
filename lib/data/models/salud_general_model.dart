import '../../features/vehiculo/domain/entities/salud_general.dart';

class ComponenteSaludModel extends ComponenteSaludEntity {
  const ComponenteSaludModel({
    required super.id,
    required super.nombre,
    required super.etiquetaCorta,
    required super.porcentaje,
    super.esDestacado,
  });

  factory ComponenteSaludModel.fromJson(Map<String, dynamic> json) {
    final nombreStr = json['component'] as String? ?? 'ENGINE';
    return ComponenteSaludModel(
      id: json['id'] as String? ?? nombreStr,
      nombre: nombreStr,
      etiquetaCorta: json['label'] as String? ?? _mapLabel(nombreStr),
      porcentaje: json['percentage'] as int? ?? 100,
      esDestacado: nombreStr == 'ENGINE',
    );
  }

  static String _mapLabel(String comp) {
    switch (comp) {
      case 'BATTERY':
        return 'Bat';
      case 'BRAKES':
        return 'Fre';
      case 'ENGINE':
        return 'Mot';
      case 'TIRES':
        return 'Lla';
      case 'FLUIDS':
        return 'Liq';
      default:
        return comp.substring(0, 3);
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'component': nombre,
      'label': etiquetaCorta,
      'percentage': porcentaje,
    };
  }
}
