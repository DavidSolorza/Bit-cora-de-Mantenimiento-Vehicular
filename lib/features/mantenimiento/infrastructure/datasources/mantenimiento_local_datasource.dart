import 'package:sqflite/sqflite.dart';
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
      String catStr = (row['category'] as String?)?.toLowerCase() ?? 'taller';
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

  Future<void> _ensureForeignKeysExist(Database db, String vehicleId, String categoryId) async {
    final now = DateTime.now().toIso8601String();
    try {
      await db.insert(
        'vehicles',
        {
          'id': vehicleId,
          'brand': 'Renault',
          'model': 'Sandero Stepway',
          'year': 2022,
          'version': 'ZEN 1.6 16V',
          'license_plate': 'BXY-492',
          'current_odometer_km': 45280,
          'fuel_level_ratio': 0.75,
          'image_url': 'https://images.unsplash.com/photo-1549399542-7e3f8b79c341?q=80&w=800&auto=format&fit=crop',
          'tank_capacity_liters': 13.2,
          'fuel_efficiency_km_l': 47.3,
          'reserve_threshold_km': 40.0,
          'created_at': now,
          'updated_at': now,
        },
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
    } catch (_) {}

    try {
      await db.insert(
        'maintenance_categories',
        {
          'id': categoryId,
          'name': 'Mantenimiento General',
          'description': 'Categoría general de servicio.',
          'created_at': now,
        },
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
    } catch (_) {}
  }

  @override
  Future<void> addRegistro(String vehicleId, RegistroMantenimientoModel registro) async {
    final db = await _dbHelper.database;
    try {
      await db.execute('ALTER TABLE maintenance_records ADD COLUMN category TEXT DEFAULT \'taller\';');
    } catch (_) {}

    const categoryId = '25bff32a-5c63-47b1-be0c-9a6eefa7ae3d';
    await _ensureForeignKeysExist(db, vehicleId, categoryId);

    try {
      await db.insert(
        'maintenance_records',
        {
          'id': registro.id,
          'vehicle_id': vehicleId,
          'category_id': categoryId,
          'category': registro.categoria.name,
          'title': registro.titulo,
          'performed_at': registro.fecha.toIso8601String(),
          'cost': registro.costo,
          'odometer_km': registro.kilometraje,
          'description': '',
          'next_recommended_km': registro.kilometraje + 5000,
          'priority_level': 'MEDIUM',
          'created_at': DateTime.now().toIso8601String(),
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (_) {
      // Fallback seguro con ConflictAlgorithm.replace sin category_id
      await db.insert(
        'maintenance_records',
        {
          'id': registro.id,
          'vehicle_id': vehicleId,
          'category_id': null,
          'category': registro.categoria.name,
          'title': registro.titulo,
          'performed_at': registro.fecha.toIso8601String(),
          'cost': registro.costo,
          'odometer_km': registro.kilometraje,
          'description': '',
          'next_recommended_km': registro.kilometraje + 5000,
          'priority_level': 'MEDIUM',
          'created_at': DateTime.now().toIso8601String(),
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  }

  @override
  Future<void> updateRegistro(String vehicleId, RegistroMantenimientoModel registro) async {
    final db = await _dbHelper.database;
    try {
      await db.execute('ALTER TABLE maintenance_records ADD COLUMN category TEXT DEFAULT \'taller\';');
    } catch (_) {}

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
