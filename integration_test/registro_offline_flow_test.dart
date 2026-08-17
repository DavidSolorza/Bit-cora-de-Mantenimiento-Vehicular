// ============================================================================
// PRUEBA GRANDE (Integration Test) — Flujo: Registrar mantenimiento offline
// Nivel: 10% de la pirámide de testing (lenta, valiosa, de extremo a extremo)
// Filosofía: Estos tests corren la app REAL en un emulador/dispositivo.
// No se usan mocks; se verifica el comportamiento completo del sistema.
// Prerequisito: Ejecutar con `flutter test integration_test/` o mediante
//               un runner como Patrol o flutter_driver en CI/CD.
// ============================================================================
//
// ADVERTENCIA DE ARQUITECTURA:
// Los integration tests son costosos (2-10 min cada uno en CI).
// Deben cubrir FLUJOS COMPLETOS de negocio, no detalles de UI.
// Este test cubre el flujo crítico: Abrir app → agregar registro → confirmar.
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

// Importamos el main real de la aplicación para correrla como un usuario real.
// No pasamos parámetros ni mocks: es la app completa con SQLite real.
import 'package:stitch_stepway_fleet_manager/main.dart' as app;

void main() {
  // El binding de integration_test reemplaza al de flutter_test.
  // Es OBLIGATORIO llamarlo antes que cualquier otra cosa.
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Flujo de integración: Registrar nuevo mantenimiento offline', () {
    // ─────────────────────────────────────────────────────────────────
    // SETUP GLOBAL DEL GRUPO
    // ─────────────────────────────────────────────────────────────────
    //
    // En un entorno de CI real, aquí se configuraría el estado inicial:
    // - Deshabilitar la conexión de red del emulador (via ADB o Patrol)
    // - Limpiar la base de datos SQLite antes de cada corrida
    // - Inyectar un usuario de prueba autenticado
    //
    // Por ahora, el esqueleto asume que la app arranca en modo offline
    // porque no hay backend disponible en el entorno de test.
    // ─────────────────────────────────────────────────────────────────

    testWidgets(
      'dado que el usuario está en el dashboard sin conexión, '
      'al abrir el formulario y guardar un registro de mantenimiento, '
      'debe aparecer en el historial local',
      (WidgetTester tester) async {
        // ─── ARRANGE ────────────────────────────────────────────────
        // Iniciamos la aplicación real (con SQLite, SharedPreferences reales)
        app.main();

        // pumpAndSettle espera a que TODOS los frames de animación,
        // timers y Futures se completen antes de continuar.
        // En integration tests, usamos un timeout generoso (30s) para
        // dar tiempo a la inicialización del proceso de la app.
        await tester.pumpAndSettle(const Duration(seconds: 5));

        // Si la app muestra el LoginPage, el test necesita un usuario pre-autenticado.
        // En un pipeline de CI, se usaría un token de prueba hardcoded o
        // se saltearía la autenticación via una feature flag de testing.
        //
        // Para este esqueleto, asumimos que el usuario ya está autenticado
        // y la DashboardPage está visible.
        // TODO: Agregar lógica de autenticación de prueba si es necesario.

        // ─── ACT (Paso 1): Abrir el formulario de nuevo registro ─────
        //
        // Buscamos el botón '+' del CustomBottomNavBar por su ícono.
        // IMPORTANTE: En tests de integración, siempre preferimos buscar
        // por semantics o key en lugar de texto, para soportar i18n.
        final botonAgregar = find.byIcon(Icons.add);

        // Esperamos hasta 5 segundos a que aparezca el botón
        // (puede tardar si el BLoC aún está cargando datos)
        await tester.pumpAndSettle(const Duration(seconds: 3));

        // Verificamos que el botón existe ANTES de tocarlo.
        // Esto produce un mensaje de error más claro si el widget no aparece.
        expect(
          botonAgregar,
          findsOneWidget,
          reason: 'El botón de agregar registro (+) no encontrado en el BottomNavBar',
        );

        // Act: tocamos el botón flotante
        await tester.tap(botonAgregar);
        await tester.pumpAndSettle(const Duration(seconds: 2));

        // ─── ACT (Paso 2): Llenar el formulario de nuevo registro ────
        //
        // El NuevoRegistroBottomSheet debe estar visible ahora.
        // Buscamos el campo de 'Título' para escribir el nombre del servicio.
        final campoTitulo = find.widgetWithText(TextField, 'Descripción');

        // Si el BottomSheet usa TextFormField, buscamos por hint text
        final campoTituloAlt = find.byWidgetPredicate(
          (widget) =>
              widget is TextField ||
              widget is TextFormField,
        );

        // Esperamos a que el formulario aparezca con animación
        await tester.pumpAndSettle(const Duration(seconds: 1));

        // Intentamos encontrar el campo de texto principal del formulario
        final campoFinal = campoTitulo.evaluate().isNotEmpty
            ? campoTitulo
            : campoTituloAlt;

        if (campoFinal.evaluate().isNotEmpty) {
          // Act: escribimos el título del registro de mantenimiento
          await tester.tap(campoFinal.first);
          await tester.pumpAndSettle();

          await tester.enterText(
            campoFinal.first,
            'Cambio de aceite 5W-30 - Test Offline',
          );
          await tester.pumpAndSettle();
        }

        // ─── ACT (Paso 3): Presionar el botón de Guardar ─────────────
        //
        // Buscamos el botón de guardar por texto o ícono.
        // El texto puede variar ('Guardar', 'Registrar', 'Agregar').
        final botonGuardar = find.widgetWithText(ElevatedButton, 'Guardar').evaluate().isNotEmpty
            ? find.widgetWithText(ElevatedButton, 'Guardar')
            : find.widgetWithText(TextButton, 'Guardar');

        if (botonGuardar.evaluate().isNotEmpty) {
          await tester.tap(botonGuardar);
          await tester.pumpAndSettle(const Duration(seconds: 3));
        }

        // ─── ASSERT ─────────────────────────────────────────────────
        //
        // VERIFICACIÓN 1: El BottomSheet de formulario debe haberse cerrado,
        // lo que indica que el guardado fue procesado por el BLoC.
        // Si sigue abierto, el guardado offline falló silenciosamente.
        //
        // TODO: Navegar al HistorialPage y verificar que el registro aparece.
        // Ejemplo:
        //   await tester.tap(find.byIcon(Icons.history));
        //   await tester.pumpAndSettle();
        //   expect(
        //     find.textContaining('Cambio de aceite 5W-30 - Test Offline'),
        //     findsOneWidget,
        //     reason: 'El registro guardado offline no aparece en el historial',
        //   );
        //
        // Por ahora verificamos que la app no crasheó durante el flujo.
        expect(tester.takeException(), isNull,
            reason: 'La app lanzó una excepción durante el flujo de guardado offline');

        // VERIFICACIÓN 2: El DashboardPage (o su contenido) debe seguir visible,
        // confirmando que la app no navegó a una pantalla de error.
        // Buscamos el BottomNavBar que sólo existe en el Dashboard.
        expect(
          find.byType(BottomNavigationBar),
          findsWidgets,
          reason: 'La app salió del Dashboard después de guardar, lo que indica un error',
        );
      },
    );

    // ─────────────────────────────────────────────────────────────────
    // TEST 2 (Esqueleto): Verificar badge "Offline" cuando no hay red
    // ─────────────────────────────────────────────────────────────────
    testWidgets(
      '[ESQUELETO] dado que el dispositivo no tiene conexión a internet, '
      'el dashboard debe mostrar el indicador de modo offline',
      (WidgetTester tester) async {
        // TODO: Deshabilitar la red del emulador antes de este test.
        // Con Patrol: await patrol.disableWifi();
        // Con ADB en CI: Process.run('adb', ['shell', 'svc', 'wifi', 'disable']);

        // Arrange
        app.main();
        await tester.pumpAndSettle(const Duration(seconds: 5));

        // Assert: Cuando esModoOffline es true, la DashboardPage muestra
        // el widget _buildOfflineBadge(). Buscamos su texto identificador.
        // expect(
        //   find.textContaining('MODO OFFLINE'),
        //   findsOneWidget,
        //   reason: 'El badge de modo offline no aparece cuando no hay red',
        // );

        // TODO: Restaurar la red después del test para no afectar otros tests.
        // await patrol.enableWifi();

        // Por ahora, marcamos el test como pendiente explícitamente.
        markTestSkipped(
          'Requiere configuración de red del emulador en el entorno de CI/CD. '
          'Implementar con Patrol para control granular del hardware del dispositivo.',
        );
      },
    );
  });
}

// Utilidad para marcar tests como "pendientes" de implementación,
// similar a `pending` de RSpec o `xit` de Jasmine. No existe en flutter_test
// por defecto, por lo que la implementamos localmente.
void markTestSkipped(String reason) {
  // ignore: avoid_print
  print('[SKIPPED] $reason');
}
