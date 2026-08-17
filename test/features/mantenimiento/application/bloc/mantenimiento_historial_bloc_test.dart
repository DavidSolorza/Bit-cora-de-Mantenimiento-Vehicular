// ============================================================================
// PRUEBA PEQUEÑA (Unit Test) — MantenimientoHistorialBloc
// Nivel: 70% de la pirámide de testing (capa más densa y barata)
// Filosofía: Estos tests NO tocan widgets ni el árbol de Flutter.
// Solo verifican la lógica pura de transformación de estados en el BLoC.
// Librerías: bloc_test + mocktail (sin generación de código)
// ============================================================================

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:stitch_stepway_fleet_manager/features/mantenimiento/application/bloc/mantenimiento_historial_bloc.dart';
import 'package:stitch_stepway_fleet_manager/features/mantenimiento/application/bloc/mantenimiento_historial_event.dart';
import 'package:stitch_stepway_fleet_manager/features/mantenimiento/application/bloc/mantenimiento_historial_state.dart';
import 'package:stitch_stepway_fleet_manager/features/mantenimiento/application/usecases/get_historial_mantenimientos_usecase.dart';
import 'package:stitch_stepway_fleet_manager/features/mantenimiento/application/usecases/agregar_registro_mantenimiento_usecase.dart';
import 'package:stitch_stepway_fleet_manager/features/mantenimiento/domain/entities/registro_mantenimiento.dart';
import 'package:stitch_stepway_fleet_manager/features/mantenimiento/domain/repositories/i_mantenimiento_repository.dart';

// ─────────────────────────────────────────────────────────────────────────────
// DOBLES DE PRUEBA (Test Doubles)
// Mockeamos el REPOSITORIO, la frontera de infraestructura.
// Nunca instanciamos la implementación real (SQLite) en tests unitarios.
// ─────────────────────────────────────────────────────────────────────────────

class MockMantenimientoRepository extends Mock
    implements IMantenimientoRepository {}

/// Fake para registrar el tipo de fallback en mocktail.
/// Sin esto, `any(named: 'registro')` lanzaría un error de tipo.
class FakeRegistroMantenimiento extends Fake
    implements RegistroMantenimientoEntity {}

// ─────────────────────────────────────────────────────────────────────────────
// FIXTURES: Datos de prueba constantes e inmutables para garantizar
// la reproducibilidad de cada test (principio de Idempotencia).
// ─────────────────────────────────────────────────────────────────────────────

const _kVehicleId = 'test-vehicle-uuid-1234';

/// Registro de muestra que representa datos cacheados en SQLite local
/// después de haberse guardado sin conexión a internet.
final _kRegistroCacheado = RegistroMantenimientoEntity(
  id: 'reg-offline-001',
  titulo: 'Cambio de aceite 5W-30',
  fecha: DateTime(2026, 8, 15),
  costo: 85000,
  kilometraje: 47320,
  categoria: CategoriaMantenimiento.taller,
);

// ─────────────────────────────────────────────────────────────────────────────

void main() {
  late MockMantenimientoRepository mockRepo;
  late GetHistorialMantenimientosUseCase getHistorialUseCase;
  late AgregarRegistroMantenimientoUseCase agregarRegistroUseCase;

  setUpAll(() {
    // Registramos el tipo de fallback UNA SOLA VEZ antes de todos los tests.
    registerFallbackValue(FakeRegistroMantenimiento());
  });

  setUp(() {
    // Estado limpio antes de cada test para garantizar aislamiento.
    mockRepo = MockMantenimientoRepository();
    getHistorialUseCase = GetHistorialMantenimientosUseCase(mockRepo);
    agregarRegistroUseCase = AgregarRegistroMantenimientoUseCase(mockRepo);
  });

  // Factory del BLoC bajo prueba con dependencias inyectadas.
  MantenimientoHistorialBloc buildBloc() => MantenimientoHistorialBloc(
        getHistorialUseCase: getHistorialUseCase,
        agregarRegistroUseCase: agregarRegistroUseCase,
      );

  group('MantenimientoHistorialBloc', () {
    // ─────────────────────────────────────────────────────────────────────
    // TEST 1: Contrato de estado inicial
    // ─────────────────────────────────────────────────────────────────────
    test(
      'estado inicial debe ser MantenimientoHistorialInitialState',
      () {
        // Assert: Un BLoC recién instanciado no emite nada antes de recibir eventos.
        expect(buildBloc().state, isA<MantenimientoHistorialInitialState>());
      },
    );

    // ─────────────────────────────────────────────────────────────────────
    // TEST 2: Carga exitosa del historial (happy path)
    // ─────────────────────────────────────────────────────────────────────
    blocTest<MantenimientoHistorialBloc, MantenimientoHistorialState>(
      'dado que el repo devuelve registros, '
      'al emitir CargarHistorialEvent, '
      'debe emitir [Loading → Loaded] con la lista correcta',
      build: buildBloc,
      setUp: () {
        // Arrange
        when(
          () => mockRepo.getHistorialRegistros(vehicleId: _kVehicleId),
        ).thenAnswer((_) async => [_kRegistroCacheado]);
      },
      act: (bloc) => bloc.add(const CargarHistorialEvent(vehicleId: _kVehicleId)),
      expect: () => [
        // Loading primero: garantiza feedback visual al usuario mientras se carga
        isA<MantenimientoHistorialLoadingState>(),
        // Luego Loaded con los datos correctos del repositorio
        isA<MantenimientoHistorialLoadedState>().having(
          (s) => s.todosLosRegistros,
          'todosLosRegistros contiene el registro esperado',
          contains(_kRegistroCacheado),
        ),
      ],
    );

    // ─────────────────────────────────────────────────────────────────────
    // TEST 3 [CRÍTICO]: Guardado offline
    //
    // ESCENARIO: El usuario registra un mantenimiento SIN conexión a internet.
    // La capa de infraestructura (SQLite) persiste el dato localmente y
    // retorna exitosamente. El BLoC debe emitir Loaded, NO Error.
    //
    // POR QUÉ es el test más importante de esta suite:
    // La promesa "offline-first" de la app exige que la falta de red
    // sea transparente para el BLoC. Si este test falla, la arquitectura
    // offline-first se rompe y la app es inutilizable sin internet.
    // ─────────────────────────────────────────────────────────────────────
    blocTest<MantenimientoHistorialBloc, MantenimientoHistorialState>(
      '[OFFLINE CRÍTICO] '
      'dado que el repo guarda en caché local y devuelve el registro guardado, '
      'al emitir AgregarNuevoRegistroEvent, '
      'debe emitir [Loaded] con el registro recién guardado (NO Error)',
      build: buildBloc,
      setUp: () {
        // Arrange 1: agregarRegistro completa exitosamente (sqflite local, sin red)
        when(
          () => mockRepo.agregarRegistro(
            vehicleId: _kVehicleId,
            registro: any(named: 'registro'),
          ),
        ).thenAnswer((_) async {});

        // Arrange 2: después de guardar, el repo devuelve el registro del caché
        when(
          () => mockRepo.getHistorialRegistros(vehicleId: _kVehicleId),
        ).thenAnswer((_) async => [_kRegistroCacheado]);
      },
      act: (bloc) => bloc.add(
        AgregarNuevoRegistroEvent(
          vehicleId: _kVehicleId,
          registro: _kRegistroCacheado,
        ),
      ),
      expect: () => [
        // Assert 1: Loaded (no Error) → el guardado offline fue exitoso
        isA<MantenimientoHistorialLoadedState>().having(
          (s) => s.todosLosRegistros,
          'el historial contiene el registro guardado offline',
          contains(_kRegistroCacheado),
        ),
      ],
      verify: (bloc) {
        // Assert 2: El flujo completo escritura+lectura se ejecutó exactamente
        // una vez. Esto previene regresiones si alguien modifica el flujo interno.
        verify(
          () => mockRepo.agregarRegistro(
            vehicleId: _kVehicleId,
            registro: any(named: 'registro'),
          ),
        ).called(1);
        verify(
          () => mockRepo.getHistorialRegistros(vehicleId: _kVehicleId),
        ).called(1);
      },
    );

    // ─────────────────────────────────────────────────────────────────────
    // TEST 4: Cálculo correcto del gasto total
    // Prueba _calcularTotal de forma indirecta (a través del estado emitido)
    // ─────────────────────────────────────────────────────────────────────
    blocTest<MantenimientoHistorialBloc, MantenimientoHistorialState>(
      'el estado Loaded debe calcular gastoTotal sumando los costos de todos los registros',
      build: buildBloc,
      setUp: () {
        // Arrange: costo1 = 85000, costo2 = 50000 → total esperado = 135000
        final registro2 = RegistroMantenimientoEntity(
          id: 'reg-gas-01',
          titulo: 'Tanqueo Terpel',
          fecha: DateTime(2026, 8, 16),
          costo: 50000,
          kilometraje: 47350,
          categoria: CategoriaMantenimiento.gasolina,
        );
        when(
          () => mockRepo.getHistorialRegistros(vehicleId: _kVehicleId),
        ).thenAnswer((_) async => [_kRegistroCacheado, registro2]);
      },
      act: (bloc) => bloc.add(const CargarHistorialEvent(vehicleId: _kVehicleId)),
      expect: () => [
        isA<MantenimientoHistorialLoadingState>(),
        // closeTo maneja imprecisiones de punto flotante en sumas largas
        isA<MantenimientoHistorialLoadedState>().having(
          (s) => s.gastoTotal,
          'gastoTotal = 85000 + 50000',
          closeTo(135000.0, 0.01),
        ),
      ],
    );

    // ─────────────────────────────────────────────────────────────────────
    // TEST 5: Unhappy path — manejo de error del repositorio
    // ─────────────────────────────────────────────────────────────────────
    blocTest<MantenimientoHistorialBloc, MantenimientoHistorialState>(
      'dado que el repo lanza una excepcion, '
      'al emitir CargarHistorialEvent, '
      'debe emitir [Loading → Error] con mensaje descriptivo',
      build: buildBloc,
      setUp: () {
        // Arrange: simula fallo catastrófico de la base de datos
        when(
          () => mockRepo.getHistorialRegistros(vehicleId: _kVehicleId),
        ).thenThrow(Exception('Base de datos corrompida'));
      },
      act: (bloc) => bloc.add(const CargarHistorialEvent(vehicleId: _kVehicleId)),
      expect: () => [
        isA<MantenimientoHistorialLoadingState>(),
        // El mensaje debe incluir el texto original de la excepción para debugging
        isA<MantenimientoHistorialErrorState>().having(
          (s) => s.mensajeError,
          'mensajeError contiene la descripcion del error',
          contains('Base de datos corrompida'),
        ),
      ],
    );

    // ─────────────────────────────────────────────────────────────────────
    // TEST 6: Filtrado por categoría (operación puramente en memoria)
    // ─────────────────────────────────────────────────────────────────────
    blocTest<MantenimientoHistorialBloc, MantenimientoHistorialState>(
      'dado un estado Loaded con registros mixtos, '
      'al emitir FiltrarCategoriaEvent(gasolina), '
      'debe emitir Loaded solo con registros de gasolina SIN llamar al repo',
      build: buildBloc,
      // seed inyecta un estado inicial sin disparar eventos previos.
      // Esto hace el test más rápido y focalizado en la acción a probar.
      seed: () => MantenimientoHistorialLoadedState(
        todosLosRegistros: [
          _kRegistroCacheado, // taller
          RegistroMantenimientoEntity(
            id: 'reg-gas-01',
            titulo: 'Tanqueo Terpel',
            fecha: DateTime(2026, 8, 17),
            costo: 60000,
            kilometraje: 47400,
            categoria: CategoriaMantenimiento.gasolina,
          ),
        ],
        registrosFiltrados: [_kRegistroCacheado],
        gastoTotal: 85000,
      ),
      act: (bloc) =>
          bloc.add(const FiltrarCategoriaEvent(categoria: CategoriaMantenimiento.gasolina)),
      expect: () => [
        isA<MantenimientoHistorialLoadedState>().having(
          (s) => s.registrosFiltrados,
          'registrosFiltrados contiene solo gasolina',
          everyElement(
            isA<RegistroMantenimientoEntity>().having(
              (r) => r.categoria,
              'categoria',
              CategoriaMantenimiento.gasolina,
            ),
          ),
        ),
      ],
      // El filtro es en memoria: NO debe tocar el repositorio
      verify: (_) => verifyNever(
        () => mockRepo.getHistorialRegistros(vehicleId: any(named: 'vehicleId')),
      ),
    );
  });
}
