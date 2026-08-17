import '../../domain/entities/vehiculo.dart';

class VehiculoModel extends VehiculoEntity {
  const VehiculoModel({
    required super.id,
    required super.marca,
    required super.modelo,
    required super.version,
    required super.placa,
    required super.kilometrajeActual,
    required super.nivelGasolinaTexto,
    required super.nivelGasolinaPorcentaje,
    super.imagenUrl,
  });

  factory VehiculoModel.fromJson(Map<String, dynamic> json) {
    return VehiculoModel(
      id: json['id'] as String? ?? 'f47ac10b-58cc-4372-a567-0e02b2c3d479',
      marca: json['brand'] as String? ?? 'Renault',
      modelo: json['model'] as String? ?? 'Stepway',
      version: json['version'] as String? ?? 'ZEN 2024',
      placa: json['licensePlate'] as String? ?? 'BXY-492',
      kilometrajeActual: json['currentOdometerKm'] as int? ?? 45020,
      nivelGasolinaTexto: json['fuelLevelFraction'] as String? ?? '3/4',
      nivelGasolinaPorcentaje: (json['fuelLevelPercentage'] as num?)?.toDouble() ?? 75.0,
      imagenUrl: json['imageUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'brand': marca,
      'model': modelo,
      'version': version,
      'licensePlate': placa,
      'currentOdometerKm': kilometrajeActual,
      'fuelLevelFraction': nivelGasolinaTexto,
      'fuelLevelPercentage': nivelGasolinaPorcentaje,
      'imageUrl': imagenUrl,
    };
  }
}
