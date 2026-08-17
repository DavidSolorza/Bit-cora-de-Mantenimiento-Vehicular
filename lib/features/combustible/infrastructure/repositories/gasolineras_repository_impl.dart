import '../../domain/entities/estacion_servicio.dart';
import '../../domain/repositories/i_gasolineras_repository.dart';
import '../datasources/open_street_map_datasource.dart';

class GasolinerasRepositoryImpl implements IGasolinerasRepository {
  final OpenStreetMapDataSource _openStreetMapDataSource;

  GasolinerasRepositoryImpl({OpenStreetMapDataSource? openStreetMapDataSource})
      : _openStreetMapDataSource = openStreetMapDataSource ?? OpenStreetMapDataSource();

  @override
  Future<List<EstacionServicioEntity>> buscarGasolinerasCercanas({
    required double latitud,
    required double longitud,
    double radioKm = 5.0,
  }) async {
    return await _openStreetMapDataSource.fetchNearbyFuelStations(
      latitud: latitud,
      longitud: longitud,
      radioKm: radioKm,
    );
  }
}
