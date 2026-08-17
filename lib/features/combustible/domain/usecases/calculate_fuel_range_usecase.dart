import '../entities/prediccion_combustible.dart';

/// Caso de Uso de Cálculo Predictivo de Autonomía de Combustible
/// Fórmula: Autonomía (km) = (Capacidad Tanque * Nivel Ratio) * Rendimiento (km/L)
class CalculateFuelRangeUseCase {
  const CalculateFuelRangeUseCase();

  PrediccionCombustibleEntity execute({
    required double nivelCombustibleRatio,
    double capacidadTanqueLitros = 50.0,
    double rendimientoKmL = 12.5,
    double umbralAlertaKm = 40.0,
  }) {
    final ratioClamped = nivelCombustibleRatio.clamp(0.0, 1.0);
    final litrosRestantes = capacidadTanqueLitros * ratioClamped;
    final autonomiaKm = litrosRestantes * rendimientoKmL;
    final esAlertaReserva = autonomiaKm <= umbralAlertaKm || ratioClamped <= 0.15;

    return PrediccionCombustibleEntity(
      autonomiaKm: autonomiaKm,
      litrosRestantes: litrosRestantes,
      capacidadTanqueLitros: capacidadTanqueLitros,
      rendimientoKmL: rendimientoKmL,
      nivelCombustibleRatio: ratioClamped,
      esAlertaReserva: esAlertaReserva,
      umbralAlertaKm: umbralAlertaKm,
    );
  }
}
