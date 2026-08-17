abstract class FuelPredictiveEvent {
  const FuelPredictiveEvent();
}

class EvaluarAutonomiaEvent extends FuelPredictiveEvent {
  final double nivelCombustibleRatio;
  final double capacidadTanqueLitros;
  final double rendimientoKmL;
  final double umbralAlertaKm;
  final double? latitudActual;
  final double? longitudActual;

  const EvaluarAutonomiaEvent({
    required this.nivelCombustibleRatio,
    this.capacidadTanqueLitros = 50.0,
    this.rendimientoKmL = 12.5,
    this.umbralAlertaKm = 40.0,
    this.latitudActual,
    this.longitudActual,
  });
}
