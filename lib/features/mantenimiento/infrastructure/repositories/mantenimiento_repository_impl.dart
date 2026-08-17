import '../../domain/entities/registro_mantenimiento.dart';
import '../../domain/repositories/i_mantenimiento_repository.dart';
import '../datasources/mantenimiento_local_datasource.dart';
import '../models/registro_mantenimiento_model.dart';

class MantenimientoRepositoryImpl implements IMantenimientoRepository {
  final IMantenimientoLocalDataSource localDataSource;

  MantenimientoRepositoryImpl({required this.localDataSource});

  @override
  Future<List<RegistroMantenimientoEntity>> getHistorialRegistros({required String vehicleId}) async {
    return await localDataSource.getRegistros(vehicleId);
  }

  @override
  Future<void> agregarRegistro({required String vehicleId, required RegistroMantenimientoEntity registro}) async {
    final model = RegistroMantenimientoModel(
      id: registro.id,
      titulo: registro.titulo,
      fecha: registro.fecha,
      costo: registro.costo,
      kilometraje: registro.kilometraje,
      categoria: registro.categoria,
    );
    await localDataSource.addRegistro(vehicleId, model);
  }

  @override
  Future<void> actualizarRegistro({required String vehicleId, required RegistroMantenimientoEntity registro}) async {
    final model = RegistroMantenimientoModel(
      id: registro.id,
      titulo: registro.titulo,
      fecha: registro.fecha,
      costo: registro.costo,
      kilometraje: registro.kilometraje,
      categoria: registro.categoria,
    );
    await localDataSource.updateRegistro(vehicleId, model);
  }

  @override
  Future<void> eliminarRegistro({required String vehicleId, required String id}) async {
    await localDataSource.deleteRegistro(vehicleId, id);
  }
}
