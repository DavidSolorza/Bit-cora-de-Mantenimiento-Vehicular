class PrediccionCombustibleEntity {
  final double autonomiaKm;
  final double litrosRestantes;
  final double capacidadTanqueLitros;
  final double rendimientoKmL;
  final double nivelCombustibleRatio;
  final bool esAlertaReserva;
  final double umbralAlertaKm;

  const PrediccionCombustibleEntity({
    required this.autonomiaKm,
    required this.litrosRestantes,
    required this.capacidadTanqueLitros,
    required this.rendimientoKmL,
    required this.nivelCombustibleRatio,
    required this.esAlertaReserva,
    required this.umbralAlertaKm,
  });

  String get autonomiaFormateada => '${autonomiaKm.toInt()} km';
}
