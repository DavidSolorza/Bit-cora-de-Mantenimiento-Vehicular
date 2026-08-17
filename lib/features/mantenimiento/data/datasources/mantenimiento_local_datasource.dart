import '../../../../core/database/sqlite_database_helper.dart';
import '../../infrastructure/models/mantenimiento_model.dart';

abstract class IMantenimientoLocalDataSource {
  Future<List<MantenimientoModel>> getHistorialMantenimientos(String vehicleId);
  Future<MantenimientoModel?> getServicioPrioritario(String vehicleId);
  Future<void> registrarMantenimiento(Map<String, dynamic> recordMap);
}

class MantenimientoLocalDataSourceImpl implements IMantenimientoLocalDataSource {
  final SqliteDatabaseHelper _dbHelper;

  MantenimientoLocalDataSourceImpl({SqliteDatabaseHelper? dbHelper})
      : _dbHelper = dbHelper ?? SqliteDatabaseHelper.instance;

  @override
  Future<List<MantenimientoModel>> getHistorialMantenimientos(String vehicleId) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'maintenance_records',
      where: 'vehicle_id = ?',
      whereArgs: [vehicleId],
      orderBy: 'performed_at DESC',
    );

    return maps.map((row) => _mapToMantenimientoModel(row)).toList();
  }

  @override
  Future<MantenimientoModel?> getServicioPrioritario(String vehicleId) async {
    final db = await _dbHelper.database;
    // Buscar primero el de mayor prioridad ('CRITICAL', 'HIGH', 'MEDIUM', 'LOW')
    final maps = await db.query(
      'maintenance_records',
      where: 'vehicle_id = ?',
      whereArgs: [vehicleId],
      orderBy: "CASE priority_level WHEN 'CRITICAL' THEN 1 WHEN 'HIGH' THEN 2 WHEN 'MEDIUM' THEN 3 ELSE 4 END, performed_at DESC",
      limit: 1,
    );

    if (maps.isEmpty) return null;
    return _mapToMantenimientoModel(maps.first);
  }

  @override
  Future<void> registrarMantenimiento(Map<String, dynamic> recordMap) async {
    final db = await _dbHelper.database;
    await db.insert('maintenance_records', recordMap);
  }

  MantenimientoModel _mapToMantenimientoModel(Map<String, dynamic> row) {
    final odometerKm = row['odometer_km'] as int;
    final nextKm = row['next_recommended_km'] as int?;
    final remainingKm = nextKm != null ? (nextKm - odometerKm) : 0;

    return MantenimientoModel(
      id: row['id'] as String,
      titulo: row['title'] as String,
      descripcion: row['description'] as String? ?? '',
      kilometrosRestantes: remainingKm > 0 ? remainingKm : 0,
      nivelPrioridad: row['priority_level'] as String? ?? 'MEDIUM',
      kilometrajeObjetivo: nextKm,
      costo: (row['cost'] as num?)?.toDouble(),
    );
  }
}
