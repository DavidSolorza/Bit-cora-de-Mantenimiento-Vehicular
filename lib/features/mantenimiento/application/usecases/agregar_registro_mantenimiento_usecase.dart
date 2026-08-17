import '../../domain/entities/registro_mantenimiento.dart';
import '../../domain/repositories/i_mantenimiento_repository.dart';

class AgregarRegistroMantenimientoUseCase {
  final IMantenimientoRepository repository;

  AgregarRegistroMantenimientoUseCase(this.repository);

  Future<void> call({required String vehicleId, required RegistroMantenimientoEntity registro}) async {
    await repository.agregarRegistro(vehicleId: vehicleId, registro: registro);
  }
}
