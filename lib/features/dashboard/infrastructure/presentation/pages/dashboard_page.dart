import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stitch_stepway_fleet_manager/core/theme/app_colors.dart';
import 'package:stitch_stepway_fleet_manager/core/theme/app_theme.dart';
import 'package:stitch_stepway_fleet_manager/features/auth/application/bloc/auth_bloc.dart';
import 'package:stitch_stepway_fleet_manager/features/auth/application/bloc/auth_state.dart';
import 'package:stitch_stepway_fleet_manager/features/dashboard/application/bloc/dashboard_bloc.dart';
import 'package:stitch_stepway_fleet_manager/features/dashboard/application/bloc/dashboard_event.dart';
import 'package:stitch_stepway_fleet_manager/features/dashboard/application/bloc/dashboard_state.dart';
import 'package:stitch_stepway_fleet_manager/features/dashboard/infrastructure/presentation/components/header_vehicle_card.dart';
import 'package:stitch_stepway_fleet_manager/features/dashboard/infrastructure/presentation/components/stat_metric_card.dart';
import 'package:stitch_stepway_fleet_manager/features/dashboard/infrastructure/presentation/components/priority_service_card.dart';
import 'package:stitch_stepway_fleet_manager/features/dashboard/infrastructure/presentation/components/general_health_card.dart';
import 'package:stitch_stepway_fleet_manager/features/dashboard/infrastructure/presentation/components/custom_bottom_nav_bar.dart';
import 'package:stitch_stepway_fleet_manager/features/mantenimiento/domain/entities/registro_mantenimiento.dart';
import 'package:stitch_stepway_fleet_manager/features/mantenimiento/infrastructure/presentation/pages/historial_page.dart';
import 'package:stitch_stepway_fleet_manager/features/mantenimiento/infrastructure/presentation/pages/nuevo_registro_bottom_sheet.dart';
import 'package:stitch_stepway_fleet_manager/features/configuraciones/infrastructure/presentation/pages/configuraciones_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stitch_stepway_fleet_manager/core/services/pdf_report_service.dart';
import '../components/onboarding_guide_widget.dart';
import '../components/expenses_chart_widget.dart';
import '../components/trips_list_widget.dart';

import '../modals/detalle_servicio_modal.dart';
import '../modals/detalle_salud_modal.dart';
import '../modals/actualizar_metrica_modal.dart';
import 'package:stitch_stepway_fleet_manager/features/combustible/application/bloc/fuel_predictive_bloc.dart';
import 'package:stitch_stepway_fleet_manager/features/combustible/application/bloc/fuel_predictive_event.dart';
import 'package:stitch_stepway_fleet_manager/features/combustible/application/bloc/fuel_predictive_state.dart';

class DashboardPage extends StatefulWidget {
  final String vehicleId;

  const DashboardPage({
    super.key,
    this.vehicleId = 'f47ac10b-58cc-4372-a567-0e02b2c3d479',
  });

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _navIndex = 0;
  String _driverName = 'David';

  @override
  void initState() {
    super.initState();
    context.read<DashboardBloc>().add(
          CargarDashboardEvent(vehicleId: widget.vehicleId),
        );
    _cargarNombreConductor();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _comprobarOnboarding();
    });
  }

  Future<void> _cargarNombreConductor() async {
    final prefs = await SharedPreferences.getInstance();
    final savedName = prefs.getString('driver_nickname');
    if (savedName != null && savedName.isNotEmpty) {
      setState(() {
        _driverName = savedName;
      });
    }
  }

  Future<void> _comprobarOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    final onboardingCompleted = prefs.getBool('onboarding_completed') ?? false;
    if (!onboardingCompleted) {
      if (!mounted) return;
      showDialog(
        context: context,
        barrierDismissible: false,
        barrierColor: Colors.black.withValues(alpha: 0.82),
        builder: (context) => OnboardingGuideWidget(
          vehicleId: widget.vehicleId,
          onCompleted: () {
            Navigator.pop(context);
            _cargarNombreConductor();
            context.read<DashboardBloc>().add(
                  RefrescarDashboardEvent(vehicleId: widget.vehicleId),
                );
          },
        ),
      );
    }
  }

  void _irAConfiguracion() {
    setState(() {
      _navIndex = 2; // Ir a Ajustes
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _navIndex == 0 ? _buildAppBar(context) : null,
      body: IndexedStack(
        index: _navIndex,
        children: [
          _buildDashboardContent(context),
          HistorialPage(
            vehicleId: widget.vehicleId,
            onProfileTap: _irAConfiguracion,
          ),
           ConfiguracionesPage(
            vehicleId: widget.vehicleId,
          ),
        ],
      ),
      bottomNavigationBar: CustomBottomNavBar(
        selectedIndex: _navIndex,
        onItemTapped: (index) {
          if (index == 0 && _navIndex != 0) {
            context.read<DashboardBloc>().add(
                  RefrescarDashboardEvent(vehicleId: widget.vehicleId),
                );
          }
          setState(() {
            _navIndex = index;
          });
        },
        onAddTapped: () {
          NuevoRegistroBottomSheet.show(context, vehicleId: widget.vehicleId);
        },
      ),
    );
  }

  Widget _buildDashboardContent(BuildContext context) {
    return BlocConsumer<DashboardBloc, DashboardState>(
      listener: (context, state) {
        if (state is DashboardErrorState) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.mensajeError),
              backgroundColor: AppColors.onErrorContainer,
            ),
          );
        }
      },
      builder: (context, state) {
        if (state is DashboardLoadedState) {
          final summary = state.summary;
          return RefreshIndicator(
            color: AppColors.primary,
            onRefresh: () async {
              context.read<DashboardBloc>().add(
                    RefrescarDashboardEvent(vehicleId: widget.vehicleId),
                  );
            },
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (state.esModoOffline) ...[
                    _buildOfflineBadge(),
                    const SizedBox(height: AppSpacing.sm),
                  ],

                  // Header del Vehículo
                  RepaintBoundary(
                    child: GestureDetector(
                      onTap: _irAConfiguracion,
                      child: HeaderVehicleCard(vehiculo: summary.vehiculo),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),

                  // Banner Predictivo de Combustible & Gasolinera Sugerida
                  _buildFuelPredictiveBanner(context, summary.vehiculo.nivelGasolinaPorcentaje / 100.0),
                  const SizedBox(height: AppSpacing.sm),

                  // Sección: Accesos Rápidos
                  _buildSectionHeader('ACCIONES RÁPIDAS', 'Registra recargas o gastos al instante'),
                  const SizedBox(height: AppSpacing.xs),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildQuickActionButton(
                          icon: Icons.local_gas_station,
                          label: '+ Tanqueo',
                          onTap: () {
                            NuevoRegistroBottomSheet.show(
                              context,
                              vehicleId: widget.vehicleId,
                              categoriaInicial: CategoriaMantenimiento.gasolina,
                            );
                          },
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        _buildQuickActionButton(
                          icon: Icons.build,
                          label: '+ Taller',
                          onTap: () {
                            NuevoRegistroBottomSheet.show(
                              context,
                              vehicleId: widget.vehicleId,
                              categoriaInicial: CategoriaMantenimiento.taller,
                            );
                          },
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        _buildQuickActionButton(
                          icon: Icons.local_car_wash,
                          label: '+ Lavado',
                          onTap: () {
                            NuevoRegistroBottomSheet.show(
                              context,
                              vehicleId: widget.vehicleId,
                              categoriaInicial: CategoriaMantenimiento.lavado,
                            );
                          },
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        _buildQuickActionButton(
                          icon: Icons.picture_as_pdf,
                          label: 'Ficha PDF',
                          onTap: () {
                            PdfReportService.generateAndShareVehicleReport(context, widget.vehicleId);
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // Sección: Métricas Principales
                  _buildSectionHeader('MÉTRICAS CLAVE', 'Monitorea autonomía y kilometraje'),
                  const SizedBox(height: AppSpacing.xs),
                  RepaintBoundary(
                    child: Row(
                      children: [
                        Expanded(
                          child: StatMetricCard(
                            icon: Icons.speed,
                            label: 'Kilometraje',
                            valor: _formatKm(summary.vehiculo.kilometrajeActual),
                            unidad: 'km',
                            iconBackgroundColor: AppColors.surfaceContainerHigh,
                            iconColor: AppColors.primary,
                            onTap: () {
                              ActualizarMetricaModal.show(
                                context,
                                titulo: 'Kilometraje',
                                valorActual: '${summary.vehiculo.kilometrajeActual}',
                                icon: Icons.speed,
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: StatMetricCard(
                            icon: Icons.local_gas_station,
                            label: 'Combustible',
                            valor: summary.vehiculo.nivelGasolinaTexto,
                            unidad: 'Tanque',
                            iconBackgroundColor: AppColors.secondaryContainer,
                            iconColor: AppColors.primary,
                            progressRatio: summary.vehiculo.nivelGasolinaPorcentaje / 100.0,
                            progressColor: (summary.vehiculo.nivelGasolinaPorcentaje <= 25)
                                ? Colors.redAccent
                                : (summary.vehiculo.nivelGasolinaPorcentaje <= 50)
                                    ? Colors.amber
                                    : Colors.green,
                            onTap: () {
                              ActualizarMetricaModal.show(
                                context,
                                titulo: 'Nivel de Combustible',
                                valorActual: summary.vehiculo.nivelGasolinaTexto,
                                icon: Icons.local_gas_station,
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // Sección: Alertas Prioritarias
                  if (summary.servicioPrioritario.nivelPrioridad.toUpperCase() == 'CRITICAL' || 
                      summary.servicioPrioritario.nivelPrioridad.toUpperCase() == 'HIGH') ...[
                    _buildSectionHeader('ALERTA URGENTE', 'Atención inmediata requerida'),
                    const SizedBox(height: AppSpacing.xs),
                    RepaintBoundary(
                      child: PriorityServiceCard(
                        servicio: summary.servicioPrioritario,
                        onTapAction: () {
                          DetalleServicioModal.show(context, servicio: summary.servicioPrioritario);
                        },
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                  ],

                  // Sección: Diagnóstico de Salud
                  _buildSectionHeader('DIAGNÓSTICO GENERAL', 'Salud estimada de los componentes'),
                  const SizedBox(height: AppSpacing.xs),
                  RepaintBoundary(
                    child: GeneralHealthCard(
                      componentes: summary.componentesSalud,
                      onVerDetallesTap: () {
                        DetalleSaludModal.show(
                          context,
                          vehicleId: summary.vehiculo.id,
                          componentes: summary.componentesSalud,
                          onSaludActualizada: () {
                            context.read<DashboardBloc>().add(
                                  RefrescarDashboardEvent(vehicleId: summary.vehiculo.id),
                                );
                          },
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // Distribución de Gastos
                  ExpensesChartWidget(vehicleId: summary.vehiculo.id),
                  const SizedBox(height: AppSpacing.md),

                  // Bitácora de Viajes
                  TripsListWidget(
                    vehicleId: summary.vehiculo.id,
                    currentVehicleOdometer: summary.vehiculo.kilometrajeActual,
                    onTripAdded: () {
                      context.read<DashboardBloc>().add(
                            RefrescarDashboardEvent(vehicleId: summary.vehiculo.id),
                          );
                    },
                  ),
                  const SizedBox(height: AppSpacing.lg),
                ],
              ),
            ),
          );
        } else if (state is DashboardErrorState) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 48, color: AppColors.onErrorContainer),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  state.mensajeError,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColors.onSurface),
                ),
                const SizedBox(height: AppSpacing.md),
                ElevatedButton(
                  onPressed: () {
                    context.read<DashboardBloc>().add(
                          CargarDashboardEvent(vehicleId: widget.vehicleId),
                        );
                  },
                  child: const Text('Reintentar'),
                ),
              ],
            ),
          );
        }

        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              CircularProgressIndicator(color: AppColors.primary),
              SizedBox(height: AppSpacing.md),
              Text(
                'Cargando información de tu Sandero Stepway...',
                style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 13),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSectionHeader(String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 2.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.8,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 1),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          decoration: BoxDecoration(
            color: AppColors.cardWhite,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.primary.withValues(alpha: 0.1), width: 1.2),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.04),
                blurRadius: 10,
                offset: const Offset(0, 4),
              )
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.08),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, size: 16, color: AppColors.primary),
                ),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.onSurface,
                    letterSpacing: -0.2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(72),
      child: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, authState) {
          String userName = _driverName;
          String? fotoUrl;

          if (authState is AuthenticatedState) {
            final user = authState.authToken.usuario;
            if ((_driverName == 'David' || _driverName.isEmpty) && user.nombre.isNotEmpty) {
              userName = user.nombre;
            } else {
              userName = _driverName;
            }
            fotoUrl = user.fotoUrl;
          }

          // Obtener el primer nombre para una bienvenida más limpia
          String greetingName = userName.split(' ').first;

          return AppBar(
            toolbarHeight: 72,
            backgroundColor: AppColors.cardWhite.withValues(alpha: 0.95),
            elevation: 0,
            titleSpacing: AppSpacing.sm,
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  children: [
                    Text(
                      'Hola, ',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w400,
                        color: AppColors.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                    Text(
                      greetingName,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.onSurface,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                const Text(
                  'Administra tu Sandero Stepway',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            actions: [
              IconButton(
                onPressed: () {
                  context.read<DashboardBloc>().add(
                        RefrescarDashboardEvent(vehicleId: widget.vehicleId),
                      );
                },
                icon: const Icon(Icons.sync, color: AppColors.onSurfaceVariant, size: 24),
                tooltip: 'Sincronizar Datos',
              ),
              const SizedBox(width: 4),
              Semantics(
                label: 'Ver perfil y ajustes del vehículo',
                button: true,
                child: GestureDetector(
                  onTap: _irAConfiguracion,
                  child: Hero(
                    tag: 'profile_avatar_hero',
                    child: Container(
                      width: 48,
                      height: 48,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.primary.withValues(alpha: 0.2),
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          )
                        ],
                      ),
                      child: CircleAvatar(
                        radius: 20,
                        backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                        backgroundImage: (fotoUrl != null && fotoUrl.startsWith('http'))
                            ? NetworkImage(fotoUrl)
                            : null,
                        child: (fotoUrl == null || !fotoUrl.startsWith('http'))
                            ? Text(
                                greetingName.isNotEmpty ? greetingName[0].toUpperCase() : 'U',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                ),
                              )
                            : null,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
            ],
          );
        },
      ),
    );
  }

  Widget _buildOfflineBadge() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: AppColors.secondaryContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.wifi_off, size: 16, color: AppColors.primary),
          SizedBox(width: AppSpacing.xs),
          Text(
            'Modo Offline-First Activado',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  String _formatKm(int km) {
    return km.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        );
  }

  Widget _buildFuelPredictiveBanner(BuildContext context, double fuelRatio) {
    context.read<FuelPredictiveBloc>().add(
          EvaluarAutonomiaEvent(nivelCombustibleRatio: fuelRatio),
        );

    return BlocBuilder<FuelPredictiveBloc, FuelPredictiveState>(
      builder: (context, state) {
        if (state is FuelWarningState) {
          final est = state.estacionSugerida;
          return Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.amber.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.amber.withValues(alpha: 0.3), width: 1.2),
              boxShadow: [
                BoxShadow(
                  color: Colors.amber.withValues(alpha: 0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                )
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.amber.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.local_gas_station, color: Colors.orange, size: 18),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '⚠️ Reserva Detectada (~${state.prediccion.autonomiaFormateada})',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: AppColors.onSurface,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Gasolinera más cercana: ${est.nombre} a ${est.distanciaFormateada} (${est.tiempoFormateado})',
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }
}
