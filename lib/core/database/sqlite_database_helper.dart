import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

/// Helper singleton para la gestión de la base de datos SQLite (SQFlite)
/// con soporte Offline-First para la aplicación Bitácora Stepway Fleet Manager.
class SqliteDatabaseHelper {
  static final SqliteDatabaseHelper instance = SqliteDatabaseHelper._internal();
  static Database? _database;

  SqliteDatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'bitacora_stepway.db');

    return await openDatabase(
      path,
      version: 4,
      onOpen: (db) async {
        await _asegurarEsquemaMantenimientos(db);
        try {
          await db.execute('ALTER TABLE vehicles ADD COLUMN image_url TEXT;');
        } catch (_) {}
        try {
          await db.execute('ALTER TABLE vehicles ADD COLUMN tank_capacity_liters REAL DEFAULT 13.2;');
          await db.execute('ALTER TABLE vehicles ADD COLUMN fuel_efficiency_km_l REAL DEFAULT 47.3;');
          await db.execute('ALTER TABLE vehicles ADD COLUMN reserve_threshold_km REAL DEFAULT 40.0;');
        } catch (_) {}
      },
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON;');
      },
      onCreate: (db, version) async {
        await _onCreate(db, version);
        await _onCreateTrips(db);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        await _onUpgrade(db, oldVersion, newVersion);
        if (oldVersion < 4) {
          await _onCreateTrips(db);
        }
      },
    );
  }

  Future<void> _onCreateTrips(Database db) async {
    try {
      await db.execute('''
        CREATE TABLE trips (
          id TEXT PRIMARY KEY NOT NULL,
          vehicle_id TEXT NOT NULL REFERENCES vehicles(id) ON DELETE CASCADE,
          origin TEXT NOT NULL,
          destination TEXT NOT NULL,
          start_km INTEGER NOT NULL,
          end_km INTEGER NOT NULL,
          fuel_used_liters REAL NOT NULL,
          trip_date TEXT NOT NULL
        );
      ''');
      
      final now = DateTime.now().toIso8601String();
      await db.insert('trips', {
        'id': 'trip-001',
        'vehicle_id': 'veh-stepway-001',
        'origin': 'Bogotá (Casa)',
        'destination': 'Estación Terpel Calle 80',
        'start_km': 45200,
        'end_km': 45215,
        'fuel_used_liters': 1.2,
        'trip_date': DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
      });
      await db.insert('trips', {
        'id': 'trip-002',
        'vehicle_id': 'veh-stepway-001',
        'origin': 'Bogotá',
        'destination': 'Chía Centro',
        'start_km': 45215,
        'end_km': 45250,
        'fuel_used_liters': 2.8,
        'trip_date': DateTime.now().subtract(const Duration(days: 2)).toIso8601String(),
      });
      await db.insert('trips', {
        'id': 'trip-003',
        'vehicle_id': 'veh-stepway-001',
        'origin': 'Chía Centro',
        'destination': 'Taller Mecánico Renault',
        'start_km': 45250,
        'end_km': 45280,
        'fuel_used_liters': 2.4,
        'trip_date': DateTime.now().subtract(const Duration(days: 3)).toIso8601String(),
      });
    } catch (_) {}
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      try {
        await db.execute('ALTER TABLE vehicles ADD COLUMN image_url TEXT;');
      } catch (_) {}
    }
    if (oldVersion < 3) {
      try {
        await db.execute('ALTER TABLE vehicles ADD COLUMN tank_capacity_liters REAL DEFAULT 50.0;');
        await db.execute('ALTER TABLE vehicles ADD COLUMN fuel_efficiency_km_l REAL DEFAULT 12.5;');
        await db.execute('ALTER TABLE vehicles ADD COLUMN reserve_threshold_km REAL DEFAULT 40.0;');
      } catch (_) {}
    }
  }

  Future<void> _onCreate(Database db, int version) async {
    // 1. Tabla de Vehículos con Parámetros Predictivos de Combustible
    await db.execute('''
      CREATE TABLE vehicles (
        id TEXT PRIMARY KEY NOT NULL,
        brand TEXT NOT NULL,
        model TEXT NOT NULL,
        year INTEGER NOT NULL CHECK (year >= 1990 AND year <= 2030),
        version TEXT NOT NULL,
        license_plate TEXT NOT NULL UNIQUE,
        current_odometer_km INTEGER NOT NULL CHECK (current_odometer_km >= 0),
        fuel_level_ratio REAL NOT NULL CHECK (fuel_level_ratio >= 0.0 AND fuel_level_ratio <= 1.0),
        image_url TEXT,
        tank_capacity_liters REAL NOT NULL DEFAULT 50.0,
        fuel_efficiency_km_l REAL NOT NULL DEFAULT 12.5,
        reserve_threshold_km REAL NOT NULL DEFAULT 40.0,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      );
    ''');

    // 2. Tabla de Categorías de Mantenimiento
    await db.execute('''
      CREATE TABLE maintenance_categories (
        id TEXT PRIMARY KEY NOT NULL,
        name TEXT NOT NULL UNIQUE,
        description TEXT,
        created_at TEXT NOT NULL
      );
    ''');

    // 3. Tabla de Registros de Mantenimiento
    await db.execute('''
      CREATE TABLE maintenance_records (
        id TEXT PRIMARY KEY NOT NULL,
        vehicle_id TEXT NOT NULL REFERENCES vehicles(id) ON DELETE CASCADE,
        category_id TEXT REFERENCES maintenance_categories(id) ON DELETE RESTRICT,
        category TEXT DEFAULT 'taller',
        title TEXT NOT NULL,
        description TEXT,
        cost REAL NOT NULL CHECK (cost >= 0.00),
        odometer_km INTEGER NOT NULL CHECK (odometer_km >= 0),
        performed_at TEXT NOT NULL,
        next_recommended_km INTEGER CHECK (next_recommended_km > odometer_km),
        priority_level TEXT DEFAULT 'MEDIUM',
        created_at TEXT
      );
    ''');

    // 4. Tabla de Salud del Vehículo por Componentes
    await db.execute('''
      CREATE TABLE vehicle_health_statuses (
        id TEXT PRIMARY KEY NOT NULL,
        vehicle_id TEXT NOT NULL REFERENCES vehicles(id) ON DELETE CASCADE,
        component_name TEXT NOT NULL CHECK (component_name IN ('BATTERY', 'BRAKES', 'ENGINE', 'TIRES', 'FLUIDS')),
        health_percentage INTEGER NOT NULL CHECK (health_percentage >= 0 AND health_percentage <= 100),
        last_inspected_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        UNIQUE (vehicle_id, component_name)
      );
    ''');

    // Semillas / Datos Iniciales Predeterminados
    await _seedInitialData(db);
  }

  Future<void> _seedInitialData(Database db) async {
    final now = DateTime.now().toIso8601String();
    const defaultVehicleId = '40cc315c-ad6f-449e-8e16-48c5564bdc27';

    // Insertar Vehículo Principal (Renault Sandero Stepway)
    await db.insert('vehicles', {
      'id': defaultVehicleId,
      'brand': 'Renault',
      'model': 'Sandero Stepway',
      'year': 2022,
      'version': 'ZEN 1.6 16V',
      'license_plate': 'BXY-492',
      'current_odometer_km': 45280,
      'fuel_level_ratio': 0.75,
      'image_url': 'https://images.unsplash.com/photo-1549399542-7e3f8b79c341?q=80&w=800&auto=format&fit=crop',
      'tank_capacity_liters': 50.0,
      'fuel_efficiency_km_l': 12.5,
      'reserve_threshold_km': 40.0,
      'created_at': now,
      'updated_at': now,
    });

    // Categorías de Mantenimiento
    final categories = [
      {'id': 'cat-001', 'name': 'Motor & Fugas', 'description': 'Inspección de empaques, correas y sistema de combustión.'},
      {'id': 'cat-002', 'name': 'Sistema de Frenos', 'description': 'Pastillas, discos, líquido de frenos y purga.'},
      {'id': 'cat-003', 'name': 'Suspensión & Dirección', 'description': 'Amortiguadores, bujes, terminales y alineación.'},
      {'id': 'cat-004', 'name': 'Fluidos & Filtros', 'description': 'Cambio de aceite 10W40, filtro de aceite, aire y polen.'},
      {'id': 'cat-005', 'name': 'Sistema Eléctrico & Batería', 'description': 'Batería, alternador, fusibles y luces.'},
    ];

    for (var cat in categories) {
      await db.insert('maintenance_categories', {
        ...cat,
        'created_at': now,
      });
    }

    // Salud de Componentes Iniciales
    final healthComponents = [
      {'id': 'hlth-001', 'component_name': 'BATTERY', 'health_percentage': 92},
      {'id': 'hlth-002', 'component_name': 'BRAKES', 'health_percentage': 85},
      {'id': 'hlth-003', 'component_name': 'ENGINE', 'health_percentage': 98},
      {'id': 'hlth-004', 'component_name': 'TIRES', 'health_percentage': 78},
      {'id': 'hlth-005', 'component_name': 'FLUIDS', 'health_percentage': 90},
    ];

    for (var component in healthComponents) {
      await db.insert('vehicle_health_statuses', {
        ...component,
        'vehicle_id': defaultVehicleId,
        'last_inspected_at': now,
        'updated_at': now,
      });
    }

    // Registros de Mantenimiento Iniciales de Muestra
    final sampleRecords = [
      {
        'id': 'rec-001',
        'vehicle_id': defaultVehicleId,
        'category_id': 'cat-004',
        'title': 'Cambio de Aceite de Motor 10W40 y Filtros',
        'description': 'Sintético Renault Approved, filtro de aceite y filtro de aire sustituidos.',
        'cost': 185000.0,
        'odometer_km': 40000,
        'performed_at': DateTime.now().subtract(const Duration(days: 60)).toIso8601String(),
        'next_recommended_km': 50000,
        'priority_level': 'LOW',
        'created_at': now,
      },
      {
        'id': 'rec-002',
        'vehicle_id': defaultVehicleId,
        'category_id': 'cat-002',
        'title': 'Revisión y Cambio Pastillas de Freno Delanteras',
        'description': 'Reemplazo de pastillas cerámicas delanteras por desgaste normal.',
        'cost': 240000.0,
        'odometer_km': 42500,
        'performed_at': DateTime.now().subtract(const Duration(days: 30)).toIso8601String(),
        'next_recommended_km': 62500,
        'priority_level': 'MEDIUM',
        'created_at': now,
      },
      {
        'id': 'rec-003',
        'vehicle_id': defaultVehicleId,
        'category_id': 'cat-001',
        'title': 'Limpieza de Cuerpo de Aceleración',
        'description': 'Mantenimiento preventivo de inyección electrónica.',
        'cost': 120000.0,
        'odometer_km': 45000,
        'performed_at': DateTime.now().subtract(const Duration(days: 5)).toIso8601String(),
        'next_recommended_km': 55000,
        'priority_level': 'HIGH',
        'created_at': now,
      },
    ];

    for (var record in sampleRecords) {
      await db.insert('maintenance_records', record);
    }
  }

  static Future<void> _asegurarEsquemaMantenimientos(Database db) async {
    try {
      final List<Map<String, dynamic>> columns =
          await db.rawQuery('PRAGMA table_info(maintenance_records)');
      final bool existeCategory = columns.any((col) => col['name'] == 'category');
      if (!existeCategory) {
        await db.execute(
          "ALTER TABLE maintenance_records ADD COLUMN category TEXT DEFAULT 'taller';"
        );
      }
    } catch (_) {}

    final now = DateTime.now().toIso8601String();
    try {
      await db.insert('vehicles', {
        'id': '40cc315c-ad6f-449e-8e16-48c5564bdc27',
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
      }, conflictAlgorithm: ConflictAlgorithm.ignore);
    } catch (_) {}

    try {
      await db.insert('vehicles', {
        'id': 'veh-stepway-001',
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
      }, conflictAlgorithm: ConflictAlgorithm.ignore);
    } catch (_) {}

    try {
      await db.insert('maintenance_categories', {
        'id': '25bff32a-5c63-47b1-be0c-9a6eefa7ae3d',
        'name': 'Mantenimiento General',
        'description': 'Categoría general de servicio.',
        'created_at': now,
      }, conflictAlgorithm: ConflictAlgorithm.ignore);
    } catch (_) {}
  }

  Future<void> close() async {
    final db = await instance.database;
    await db.close();
  }
}
