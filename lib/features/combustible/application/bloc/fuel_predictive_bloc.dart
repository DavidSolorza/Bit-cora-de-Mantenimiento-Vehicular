import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/calculate_fuel_range_usecase.dart';
import '../../domain/repositories/i_gasolineras_repository.dart';
import '../../infrastructure/repositories/gasolineras_repository_impl.dart';
import 'fuel_predictive_event.dart';
import 'fuel_predictive_state.dart';
import '../../../../core/services/notification_service.dart';

class FuelPredictiveBloc extends Bloc<FuelPredictiveEvent, FuelPredictiveState> {
  final CalculateFuelRangeUseCase calculateFuelRangeUseCase;
  final IGasolinerasRepository gasolinerasRepository;

  FuelPredictiveBloc({
    CalculateFuelRangeUseCase? useCase,
    IGasolinerasRepository? repository,
  })  : calculateFuelRangeUseCase = useCase ?? const CalculateFuelRangeUseCase(),
        gasolinerasRepository = repository ?? GasolinerasRepositoryImpl(),
        super(const FuelPredictiveInitialState()) {
    on<EvaluarAutonomiaEvent>(_onEvaluarAutonomia);
  }

  Future<void> _onEvaluarAutonomia(
    EvaluarAutonomiaEvent event,
    Emitter<FuelPredictiveState> emit,
  ) async {
    final prediccion = calculateFuelRangeUseCase.execute(
      nivelCombustibleRatio: event.nivelCombustibleRatio,
      capacidadTanqueLitros: event.capacidadTanqueLitros,
      rendimientoKmL: event.rendimientoKmL,
      umbralAlertaKm: event.umbralAlertaKm,
    );

    if (!prediccion.esAlertaReserva) {
      emit(FuelNormalState(prediccion: prediccion));
      return;
    }

    // Si está en reserva (<40km o <15%), hacer búsqueda en segundo plano con OpenStreetMap
    final lat = event.latitudActual ?? 4.6097; // Latitud por defecto (ej. Bogotá)
    final lon = event.longitudActual ?? -74.0817;

    final estaciones = await gasolinerasRepository.buscarGasolinerasCercanas(
      latitud: lat,
      longitud: lon,
      radioKm: 5.0,
    );

    final sugerida = estaciones.first;

    // Disparar Notificación Push Local de Alta Prioridad con Sonido & Vibración
    NotificationService.instance.mostrarAlertaAltaPrioridad(
      id: 999,
      titulo: '⚠️ ALERTA: RESERVA DE COMBUSTIBLE (${prediccion.autonomiaFormateada})',
      cuerpo: 'Te quedan ~${prediccion.autonomiaFormateada} de autonomía. Gasolinera sugerida: ${sugerida.nombre} a ${sugerida.distanciaFormateada} (${sugerida.tiempoFormateado}).',
    );

    emit(FuelWarningState(
      prediccion: prediccion,
      estacionSugerida: sugerida,
      estacionesCercanas: estaciones,
    ));
  }
}
