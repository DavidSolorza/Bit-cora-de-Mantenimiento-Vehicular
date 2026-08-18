class PrediccionCombustibleEntity {
  final double autonomiaKm;
  final double galonesRestantes;
  final double capacidadTanqueGalones;
  final double rendimientoKmGal;
  final double nivelCombustibleRatio;
  final bool esAlertaReserva;
  final double umbralAlertaKm;

  const PrediccionCombustibleEntity({
    required this.autonomiaKm,
    required this.galonesRestantes,
    required this.capacidadTanqueGalones,
    required this.rendimientoKmGal,
    required this.nivelCombustibleRatio,
    required this.esAlertaReserva,
    required this.umbralAlertaKm,
  });

  String get autonomiaFormateada => '${autonomiaKm.toInt()} km';
}
