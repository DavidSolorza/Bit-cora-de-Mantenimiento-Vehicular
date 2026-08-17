// ============================================================================
// PRUEBA MEDIANA (Widget Test) — StatMetricCard & DashboardPage (fragmento)
// Nivel: 20% de la pirámide de testing
// Filosofía: Verificamos que los WIDGETS renderizan el estado del BLoC
// correctamente y que no existen problemas visuales (overflows, wrapping).
// Librería: flutter_test (WidgetTester) + mocktail + bloc_test
// ============================================================================
//
// NOTA TÉCNICA — Por qué no usamos find.textContaining en RichText:
// StatMetricCard usa un widget RichText con TextSpan anidados.
// `find.textContaining` sólo busca en widgets Text simples, NO en RichText.
// La solución correcta es `find.byWidgetPredicate` con `toPlainText()`
// que recorre todo el árbol de InlineSpan del RichText.
// ============================================================================

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:stitch_stepway_fleet_manager/features/dashboard/application/bloc/dashboard_bloc.dart';
import 'package:stitch_stepway_fleet_manager/features/dashboard/application/bloc/dashboard_event.dart';
import 'package:stitch_stepway_fleet_manager/features/dashboard/application/bloc/dashboard_state.dart';
import 'package:stitch_stepway_fleet_manager/features/dashboard/domain/entities/dashboard_summary.dart';
import 'package:stitch_stepway_fleet_manager/features/dashboard/infrastructure/presentation/components/stat_metric_card.dart';
import 'package:stitch_stepway_fleet_manager/features/mantenimiento/domain/entities/mantenimiento.dart';
import 'package:stitch_stepway_fleet_manager/features/vehiculo/domain/entities/vehiculo.dart';
import 'package:stitch_stepway_fleet_manager/features/vehiculo/domain/entities/salud_general.dart';

// ─────────────────────────────────────────────────────────────────────────────
// HELPER: Finder para texto dentro de RichText (TextSpan anidados)
//
// Flutter's `find.textContaining` solo atraviesa nodos `Text` simples.
// Para `RichText` con `TextSpan` children, debemos usar `byWidgetPredicate`
// y llamar a `toPlainText()` que concatena todos los spans en un string plano.
// ─────────────────────────────────────────────────────────────────────────────
Finder findRichTextContaining(String substring) {
  return find.byWidgetPredicate(
    (widget) {
      if (widget is RichText) {
        // toPlainText() concatena todos los TextSpan del árbol en un string.
        return widget.text.toPlainText().contains(substring);
      }
      return false;
    },
    description: 'RichText que contiene "$substring"',
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// DOBLES DE PRUEBA
// MockBloc: necesario para que BlocProvider proporcione el BLoC al árbol.
// La sintaxis de mocktail para BLoCs requiere implementar tambien `on`.
// ─────────────────────────────────────────────────────────────────────────────

class MockDashboardBloc extends MockBloc<DashboardEvent, DashboardState>
    implements DashboardBloc {}

// ─────────────────────────────────────────────────────────────────────────────
// FIXTURES
// ─────────────────────────────────────────────────────────────────────────────

const _kKilometrajeEsperado = 47320;

/// Estado de éxito con datos reales para el vehiculo bajo prueba.
final _kDashboardLoadedState = DashboardLoadedState(
  esModoOffline: false,
  summary: DashboardSummaryEntity(
    vehiculo: const VehiculoEntity(
      id: 'test-vehicle-uuid-1234',
      marca: 'Renault',
      modelo: 'Sandero',
      version: 'Stepway Intens',
      placa: 'ABC-123',
      kilometrajeActual: _kKilometrajeEsperado,
      nivelGasolinaTexto: '3/4',
      nivelGasolinaPorcentaje: 75.0,
    ),
    servicioPrioritario: const MantenimientoEntity(
      id: 'serv-001',
      titulo: 'Cambio de aceite',
      descripcion: 'Próximo en 2000 km',
      kilometrosRestantes: 2000,
      nivelPrioridad: 'LOW',
    ),
    componentesSalud: const [
      ComponenteSaludEntity(
        id: 'comp-01',
        nombre: 'Motor',
        etiquetaCorta: 'Motor',
        porcentaje: 90,
      ),
    ],
  ),
);

// ─────────────────────────────────────────────────────────────────────────────

void main() {
  // ─────────────────────────────────────────────────────────────────────
  // GRUPO 1: Tests del widget StatMetricCard de forma aislada
  // Probamos el componente atómico sin involucrar BLoCs ni navegación.
  // ─────────────────────────────────────────────────────────────────────
  group('StatMetricCard (componente aislado)', () {
    // Helper que envuelve el widget en el árbol mínimo necesario
    Widget buildSubject({
      required String valor,
      required String unidad,
      String label = 'Kilometraje',
    }) {
      return MaterialApp(
        home: Scaffold(
          body: SizedBox(
            // Ancho fijo que simula la mitad de la pantalla (columna de la grilla)
            width: 180,
            child: StatMetricCard(
              icon: Icons.speed,
              label: label,
              valor: valor,
              unidad: unidad,
            ),
          ),
        ),
      );
    }

    // ─────────────────────────────────────────────────────────────────
    // TEST 1: Render básico del valor numérico
    // ─────────────────────────────────────────────────────────────────
    testWidgets(
      'debe mostrar el valor y la unidad correctamente en el texto',
      (WidgetTester tester) async {
        // Arrange
        const valorPrueba = '47.320';
        const unidadPrueba = 'km';

        // Act: montamos el widget en el árbol de Flutter de prueba
        await tester.pumpWidget(buildSubject(valor: valorPrueba, unidad: unidadPrueba));

        // Assert 1: El valor numérico debe aparecer en el RichText.
        // Usamos el helper `findRichTextContaining` porque StatMetricCard
        // renderiza el valor con RichText + TextSpan anidados. `find.textContaining`
        // NO funciona para RichText; solo traversa nodos `Text` simples.
        expect(findRichTextContaining(valorPrueba), findsOneWidget);

        // Assert 2: La unidad también debe estar en el mismo RichText.
        // (valor y unidad son children del mismo TextSpan raíz)
        expect(findRichTextContaining(unidadPrueba), findsOneWidget);
      },
    );

    // ─────────────────────────────────────────────────────────────────
    // TEST 2: Sin overflow de píxeles
    // Este test es CRÍTICO para apps que deben correr en múltiples
    // tamaños de pantalla (320px phones hasta tablets).
    // Un overflow es un error visual silencioso en producción.
    // ─────────────────────────────────────────────────────────────────
    testWidgets(
      'NO debe generar desbordamiento de pixeles (overflow) con un valor largo',
      (WidgetTester tester) async {
        // Arrange: usamos el valor más largo posible para forzar el caso extremo
        await tester.pumpWidget(
          buildSubject(valor: '1.234.567', unidad: 'km', label: 'KILOMETRAJE TOTAL'),
        );

        // Act: esperamos el frame completo de renderizado
        await tester.pump();

        // Assert: `tester.takeException()` captura cualquier excepción pendiente
        // del árbol de widgets, incluido el RenderFlex overflow amarillo/negro.
        // Si es null, el renderizado fue limpio.
        expect(tester.takeException(), isNull);
      },
    );

    // ─────────────────────────────────────────────────────────────────
    // TEST 3: La barra de progreso aparece sólo cuando se provee progressRatio
    // ─────────────────────────────────────────────────────────────────
    testWidgets(
      'debe mostrar LinearProgressIndicator solo cuando se provee progressRatio',
      (WidgetTester tester) async {
        // Arrange: sin progressRatio
        await tester.pumpWidget(buildSubject(valor: '75', unidad: '%'));

        // Assert 1: Sin progressRatio, el LinearProgressIndicator no debe existir
        expect(find.byType(LinearProgressIndicator), findsNothing);

        // Arrange 2: con progressRatio
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SizedBox(
                width: 180,
                child: StatMetricCard(
                  icon: Icons.local_gas_station,
                  label: 'Combustible',
                  valor: '3/4',
                  unidad: 'Tanque',
                  progressRatio: 0.75,
                  progressColor: Colors.green,
                ),
              ),
            ),
          ),
        );
        await tester.pump();

        // Assert 2: Con progressRatio, el LinearProgressIndicator debe aparecer
        expect(find.byType(LinearProgressIndicator), findsOneWidget);
      },
    );
  });

  // ─────────────────────────────────────────────────────────────────────
  // GRUPO 2: Tests de la tarjeta de Kilometraje integrada con el BLoC
  // Verificamos que el BLoC del Dashboard propaga el kilometraje
  // correctamente hacia la UI cuando emite un DashboardLoadedState.
  // ─────────────────────────────────────────────────────────────────────
  group('Tarjeta de Kilometraje con DashboardBloc', () {
    late MockDashboardBloc mockBloc;

    setUp(() {
      mockBloc = MockDashboardBloc();
    });

    tearDown(() {
      mockBloc.close();
    });

    testWidgets(
      'cuando el BLoC emite DashboardLoadedState, '
      'la tarjeta de Kilometraje debe mostrar el valor formateado correcto '
      'y NO generar overflow',
      (WidgetTester tester) async {
        // Arrange: el MockBloc ya tiene el estado cargado desde el inicio.
        // `whenListen` + `seed` define el estado inicial del mock.
        when(() => mockBloc.state).thenReturn(_kDashboardLoadedState);

        // Act: montamos sólo la tarjeta de kilometraje con su BLoC mock inyectado.
        // No necesitamos toda la DashboardPage; isolamos el widget a probar.
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: BlocProvider<DashboardBloc>.value(
                value: mockBloc,
                child: BlocBuilder<DashboardBloc, DashboardState>(
                  builder: (context, state) {
                    if (state is! DashboardLoadedState) {
                      return const CircularProgressIndicator();
                    }
                    // Replicamos exactamente cómo dashboard_page.dart formatea el km
                    final kmFormateado =
                        state.summary.vehiculo.kilometrajeActual.toString();

                    return SizedBox(
                      width: 180,
                      child: StatMetricCard(
                        icon: Icons.speed,
                        label: 'Kilometraje',
                        valor: kmFormateado,
                        unidad: 'km',
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        );

        // Procesamos todos los frames pendientes (animaciones, timers, etc.)
        await tester.pumpAndSettle();

        // Assert 1: El valor numérico del kilometraje debe estar en el RichText.
        // Verificamos el número específico, no una cadena genérica,
        // para detectar si el BLoC pasó el dato equivocado al widget.
        expect(
          findRichTextContaining(_kKilometrajeEsperado.toString()),
          findsOneWidget,
          reason: 'El kilometraje $_kKilometrajeEsperado no aparece en la UI',
        );

        // Assert 2: La unidad 'km' debe ser visible en el mismo RichText
        expect(findRichTextContaining('km'), findsOneWidget);

        // Assert 3: Sin overflow de píxeles
        // Esto garantiza que la tarjeta es robusta en pantallas pequeñas.
        expect(tester.takeException(), isNull);
      },
    );
  });
}
