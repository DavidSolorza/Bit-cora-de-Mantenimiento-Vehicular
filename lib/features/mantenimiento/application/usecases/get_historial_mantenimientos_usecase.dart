import '../../domain/entities/registro_mantenimiento.dart';
import '../../domain/repositories/i_mantenimiento_repository.dart';

class GetHistorialMantenimientosUseCase {
  final IMantenimientoRepository repository;

  GetHistorialMantenimientosUseCase(this.repository);

  Future<List<RegistroMantenimientoEntity>> call({required String vehicleId}) async {
    return await repository.getHistorialRegistros(vehicleId: vehicleId);
  }
}
