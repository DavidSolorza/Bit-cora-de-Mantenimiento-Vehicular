import '../entities/prediccion_combustible.dart';

/// Caso de Uso de Cálculo Predictivo de Autonomía de Combustible
/// Fórmula: Autonomía (km) = (Capacidad Tanque en Galones * Nivel Ratio) * Rendimiento (km/Gal)
class CalculateFuelRangeUseCase {
  const CalculateFuelRangeUseCase();

  PrediccionCombustibleEntity execute({
    required double nivelCombustibleRatio,
    double capacidadTanqueGalones = 13.2,
    double rendimientoKmGal = 47.3,
    double umbralAlertaKm = 40.0,
  }) {
    final ratioClamped = nivelCombustibleRatio.clamp(0.0, 1.0);
    final galonesRestantes = capacidadTanqueGalones * ratioClamped;
    final autonomiaKm = galonesRestantes * rendimientoKmGal;
    final esAlertaReserva = autonomiaKm <= umbralAlertaKm || ratioClamped <= 0.15;

    return PrediccionCombustibleEntity(
      autonomiaKm: autonomiaKm,
      galonesRestantes: galonesRestantes,
      capacidadTanqueGalones: capacidadTanqueGalones,
      rendimientoKmGal: rendimientoKmGal,
      nivelCombustibleRatio: ratioClamped,
      esAlertaReserva: esAlertaReserva,
      umbralAlertaKm: umbralAlertaKm,
    );
  }
}
