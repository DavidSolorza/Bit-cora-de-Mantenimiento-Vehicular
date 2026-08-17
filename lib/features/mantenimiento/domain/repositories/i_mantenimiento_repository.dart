import '../entities/registro_mantenimiento.dart';

abstract class IMantenimientoRepository {
  Future<List<RegistroMantenimientoEntity>> getHistorialRegistros({required String vehicleId});
  Future<void> agregarRegistro({required String vehicleId, required RegistroMantenimientoEntity registro});
  Future<void> actualizarRegistro({required String vehicleId, required RegistroMantenimientoEntity registro});
  Future<void> eliminarRegistro({required String vehicleId, required String id});
}
