import '../../domain/entities/prediccion_combustible.dart';
import '../../domain/entities/estacion_servicio.dart';

abstract class FuelPredictiveState {
  const FuelPredictiveState();
}

class FuelPredictiveInitialState extends FuelPredictiveState {
  const FuelPredictiveInitialState();
}

class FuelNormalState extends FuelPredictiveState {
  final PrediccionCombustibleEntity prediccion;

  const FuelNormalState({required this.prediccion});
}

class FuelWarningState extends FuelPredictiveState {
  final PrediccionCombustibleEntity prediccion;
  final EstacionServicioEntity estacionSugerida;
  final List<EstacionServicioEntity> estacionesCercanas;

  const FuelWarningState({
    required this.prediccion,
    required this.estacionSugerida,
    required this.estacionesCercanas,
  });
}
