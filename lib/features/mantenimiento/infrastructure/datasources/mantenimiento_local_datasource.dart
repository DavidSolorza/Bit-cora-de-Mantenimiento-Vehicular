import '../../../../core/database/sqlite_database_helper.dart';
import '../models/registro_mantenimiento_model.dart';
import '../../domain/entities/registro_mantenimiento.dart';

abstract class IMantenimientoLocalDataSource {
  Future<List<RegistroMantenimientoModel>> getRegistros(String vehicleId);
  Future<void> addRegistro(String vehicleId, RegistroMantenimientoModel registro);
  Future<void> updateRegistro(String vehicleId, RegistroMantenimientoModel registro);
  Future<void> deleteRegistro(String vehicleId, String id);
}

class MantenimientoLocalDataSourceImpl implements IMantenimientoLocalDataSource {
  final SqliteDatabaseHelper _dbHelper;

  MantenimientoLocalDataSourceImpl({SqliteDatabaseHelper? dbHelper})
      : _dbHelper = dbHelper ?? SqliteDatabaseHelper.instance;

  @override
  Future<List<RegistroMantenimientoModel>> getRegistros(String vehicleId) async {
    final db = await _dbHelper.database;
    final results = await db.query(
      'maintenance_records',
      where: 'vehicle_id = ?',
      whereArgs: [vehicleId],
      orderBy: 'performed_at DESC',
    );

    return results.map((row) {
      String catStr = (row['category'] as String).toLowerCase();
      CategoriaMantenimiento cat;
      if (catStr == 'gasolina' || catStr == 'combustible') {
        cat = CategoriaMantenimiento.gasolina;
      } else if (catStr == 'taller' || catStr == 'mantenimiento') {
        cat = CategoriaMantenimiento.taller;
      } else if (catStr == 'lavado' || catStr == 'detallado') {
        cat = CategoriaMantenimiento.lavado;
      } else {
        cat = CategoriaMantenimiento.taller;
      }

      return RegistroMantenimientoModel(
        id: row['id'] as String,
        titulo: row['title'] as String,
        fecha: DateTime.tryParse(row['performed_at'] as String) ?? DateTime.now(),
        costo: (row['cost'] as num?)?.toDouble() ?? 0.0,
        kilometraje: (row['odometer_km'] as num?)?.toInt() ?? 0,
        categoria: cat,
      );
    }).toList();
  }

  @override
  Future<void> addRegistro(String vehicleId, RegistroMantenimientoModel registro) async {
    final db = await _dbHelper.database;
    await db.insert('maintenance_records', {
      'id': registro.id,
      'vehicle_id': vehicleId,
      'title': registro.titulo,
      'category': registro.categoria.name,
      'performed_at': registro.fecha.toIso8601String(),
      'cost': registro.costo,
      'odometer_km': registro.kilometraje,
      'description': '',
      'next_recommended_km': registro.kilometraje + 5000,
    });
  }

  @override
  Future<void> updateRegistro(String vehicleId, RegistroMantenimientoModel registro) async {
    final db = await _dbHelper.database;
    await db.update(
      'maintenance_records',
      {
        'title': registro.titulo,
        'category': registro.categoria.name,
        'performed_at': registro.fecha.toIso8601String(),
        'cost': registro.costo,
        'odometer_km': registro.kilometraje,
      },
      where: 'id = ? AND vehicle_id = ?',
      whereArgs: [registro.id, vehicleId],
    );
  }

  @override
  Future<void> deleteRegistro(String vehicleId, String id) async {
    final db = await _dbHelper.database;
    await db.delete(
      'maintenance_records',
      where: 'id = ? AND vehicle_id = ?',
      whereArgs: [id, vehicleId],
    );
  }
}
