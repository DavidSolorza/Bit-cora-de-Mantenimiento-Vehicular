class VehiculoEntity {
  final String id;
  final String marca;
  final String modelo;
  final String version;
  final String placa;
  final int kilometrajeActual;
  final String nivelGasolinaTexto;
  final double nivelGasolinaPorcentaje;
  final String? imagenUrl;

  const VehiculoEntity({
    required this.id,
    required this.marca,
    required this.modelo,
    required this.version,
    required this.placa,
    required this.kilometrajeActual,
    required this.nivelGasolinaTexto,
    required this.nivelGasolinaPorcentaje,
    this.imagenUrl,
  });

  String get nombreCompleto => '$modelo $version';
}
