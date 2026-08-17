class EstacionServicioEntity {
  final String id;
  final String nombre;
  final String marca;
  final double distanciaKm;
  final int tiempoEstimadoMinutos;
  final double latitud;
  final double longitud;

  const EstacionServicioEntity({
    required this.id,
    required this.nombre,
    required this.marca,
    required this.distanciaKm,
    required this.tiempoEstimadoMinutos,
    required this.latitud,
    required this.longitud,
  });

  String get distanciaFormateada => '${distanciaKm.toStringAsFixed(1)} km';
  String get tiempoFormateado => '~$tiempoEstimadoMinutos min';
}
