import '../../../../core/database/sqlite_database_helper.dart';
import '../../infrastructure/models/vehiculo_model.dart';
import '../../infrastructure/models/salud_general_model.dart';

abstract class IVehiculoLocalDataSource {
  Future<VehiculoModel?> getVehiculo(String vehicleId);
  Future<List<ComponenteSaludModel>> getSaludComponentes(String vehicleId);
  Future<void> updateKilometrajeYCombustible(String vehicleId, int kilometraje, double nivelCombustibleRatio);
}

class VehiculoLocalDataSourceImpl implements IVehiculoLocalDataSource {
  final SqliteDatabaseHelper _dbHelper;

  VehiculoLocalDataSourceImpl({SqliteDatabaseHelper? dbHelper})
      : _dbHelper = dbHelper ?? SqliteDatabaseHelper.instance;

  @override
  Future<VehiculoModel?> getVehiculo(String vehicleId) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'vehicles',
      where: 'id = ?',
      whereArgs: [vehicleId],
      limit: 1,
    );

    if (maps.isEmpty) {
      // Fallback a consultar el primer vehículo si el ID no coincide
      final firstMap = await db.query('vehicles', limit: 1);
      if (firstMap.isEmpty) return null;
      return _mapToVehiculoModel(firstMap.first);
    }

    return _mapToVehiculoModel(maps.first);
  }

  @override
  Future<List<ComponenteSaludModel>> getSaludComponentes(String vehicleId) async {
    final db = await _dbHelper.database;
    var maps = await db.query(
      'vehicle_health_statuses',
      where: 'vehicle_id = ?',
      whereArgs: [vehicleId],
    );

    if (maps.isEmpty) {
      maps = await db.query('vehicle_health_statuses');
    }

    return maps.map((row) {
      final compName = row['component_name'] as String;
      return ComponenteSaludModel(
        id: row['id'] as String,
        nombre: compName,
        etiquetaCorta: _mapLabel(compName),
        porcentaje: row['health_percentage'] as int,
        esDestacado: compName == 'ENGINE',
      );
    }).toList();
  }

  @override
  Future<void> updateKilometrajeYCombustible(String vehicleId, int kilometraje, double nivelCombustibleRatio) async {
    final db = await _dbHelper.database;
    await db.update(
      'vehicles',
      {
        'current_odometer_km': kilometraje,
        'fuel_level_ratio': nivelCombustibleRatio,
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [vehicleId],
    );
  }

  VehiculoModel _mapToVehiculoModel(Map<String, dynamic> row) {
    final fuelRatio = (row['fuel_level_ratio'] as num).toDouble();
    final fuelPct = fuelRatio * 100.0;
    
    String fractionText = 'Full';
    if (fuelRatio <= 0.25) {
      fractionText = '1/4';
    } else if (fuelRatio <= 0.50) {
      fractionText = '1/2';
    } else if (fuelRatio <= 0.75) {
      fractionText = '3/4';
    }

    return VehiculoModel(
      id: row['id'] as String,
      marca: row['brand'] as String,
      modelo: row['model'] as String,
      version: row['version'] as String,
      placa: row['license_plate'] as String,
      kilometrajeActual: row['current_odometer_km'] as int,
      nivelGasolinaTexto: fractionText,
      nivelGasolinaPorcentaje: fuelPct,
      imagenUrl: row['image_url'] as String?,
    );
  }

  String _mapLabel(String comp) {
    switch (comp) {
      case 'BATTERY':
        return 'Bat';
      case 'BRAKES':
        return 'Fre';
      case 'ENGINE':
        return 'Mot';
      case 'TIRES':
        return 'Lla';
      case 'FLUIDS':
        return 'Liq';
      default:
        return comp.length >= 3 ? comp.substring(0, 3) : comp;
    }
  }
}
