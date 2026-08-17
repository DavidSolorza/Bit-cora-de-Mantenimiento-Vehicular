import '../entities/estacion_servicio.dart';

abstract class IGasolinerasRepository {
  /// Busca estaciones de servicio (gasolineras) cercanas en segundo plano mediante OpenStreetMap
  Future<List<EstacionServicioEntity>> buscarGasolinerasCercanas({
    required double latitud,
    required double longitud,
    double radioKm = 5.0,
  });
}
