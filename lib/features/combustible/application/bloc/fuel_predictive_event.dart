abstract class FuelPredictiveEvent {
  const FuelPredictiveEvent();
}

class EvaluarAutonomiaEvent extends FuelPredictiveEvent {
  final double nivelCombustibleRatio;
  final double capacidadTanqueGalones;
  final double rendimientoKmGal;
  final double umbralAlertaKm;
  final double? latitudActual;
  final double? longitudActual;

  const EvaluarAutonomiaEvent({
    required this.nivelCombustibleRatio,
    this.capacidadTanqueGalones = 13.2,
    this.rendimientoKmGal = 47.3,
    this.umbralAlertaKm = 40.0,
    this.latitudActual,
    this.longitudActual,
  });
}
