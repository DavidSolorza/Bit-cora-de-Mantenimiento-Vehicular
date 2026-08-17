import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../bloc/mantenimiento_bloc.dart';
import '../bloc/mantenimiento_event.dart';
import '../bloc/mantenimiento_state.dart';
import '../components/header_vehicle_card.dart';
import '../components/stat_metric_card.dart';
import '../components/priority_service_card.dart';
import '../components/general_health_card.dart';
import '../components/custom_bottom_nav_bar.dart';
import '../../features/dashboard/infrastructure/presentation/modals/detalle_salud_modal.dart';
import '../../features/dashboard/infrastructure/presentation/modals/selector_vehiculo_modal.dart';
import '../../features/mantenimiento/infrastructure/presentation/pages/nuevo_registro_bottom_sheet.dart';
import '../../features/configuraciones/infrastructure/presentation/pages/configuraciones_page.dart';

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

  @override
  void initState() {
    super.initState();
    // Disparar la carga inicial del BLoC
    context.read<MantenimientoBloc>().add(
          CargarDashboardEvent(vehicleId: widget.vehicleId),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(context),
      body: BlocConsumer<MantenimientoBloc, MantenimientoState>(
        listener: (context, state) {
          if (state is MantenimientoErrorState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.mensajeError),
                backgroundColor: AppColors.onErrorContainer,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is MantenimientoCargandoState) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          } else if (state is MantenimientoCargadoState) {
            final data = state.dashboardData;
            return RefreshIndicator(
              color: AppColors.primary,
              onRefresh: () async {
                context.read<MantenimientoBloc>().add(
                      RefrescarDashboardEvent(vehicleId: widget.vehicleId),
                    );
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Indicador de modo Offline-First si aplica
                    if (state.esModoOffline) ...[
                      _buildOfflineBadge(),
                      const SizedBox(height: AppSpacing.sm),
                    ],

                    // 1. Tarjeta de Cabecera del Vehículo (Renault Stepway / Flota)
                    HeaderVehicleCard(
                      vehiculo: data.vehiculo,
                      onVehiculoTap: () {
                        SelectorVehiculoModal.show(
                          context,
                          onVehiculoSeleccionado: (vehiculoSeleccionado) {
                            context.read<MantenimientoBloc>().add(
                                  CargarDashboardEvent(vehicleId: vehiculoSeleccionado.id),
                                );
                          },
                        );
                      },
                    ),
                    const SizedBox(height: AppSpacing.md),

                    // 2. Grilla de Métricas Desacopladas (Odómetro & Combustible)
                    Row(
                      children: [
                        Expanded(
                          child: StatMetricCard(
                            icon: Icons.speed,
                            label: 'Kilometraje',
                            valor: _formatKm(data.vehiculo.kilometrajeActual),
                            unidad: 'km',
                            iconBackgroundColor: AppColors.surfaceContainerHigh,
                            iconColor: AppColors.primary,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: StatMetricCard(
                            icon: Icons.local_gas_station,
                            label: 'Combustible',
                            valor: data.vehiculo.nivelGasolinaTexto,
                            unidad: 'Tanque',
                            iconBackgroundColor: AppColors.secondaryContainer,
                            iconColor: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),

                    // 3. Tarjeta de Servicio Prioritario Recomendado
                    PriorityServiceCard(
                      servicio: data.servicioPrioritario,
                      onTapAction: () {
                        // Detalle del servicio prioritario
                      },
                    ),
                    const SizedBox(height: AppSpacing.md),

                    // 4. Componente de Salud General Interactivo
                    GeneralHealthCard(
                      componentes: data.componentesSalud,
                      onVerDetallesTap: () {
                        DetalleSaludModal.show(
                          context,
                          vehicleId: data.vehiculo.id,
                          componentes: data.componentesSalud,
                          onSaludActualizada: () {
                            context.read<MantenimientoBloc>().add(
                                  RefrescarDashboardEvent(vehicleId: data.vehiculo.id),
                                );
                          },
                        );
                      },
                    ),
                    const SizedBox(height: AppSpacing.lg),
                  ],
                ),
              ),
            );
          } else if (state is MantenimientoErrorState) {
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
                      context.read<MantenimientoBloc>().add(
                            CargarDashboardEvent(vehicleId: widget.vehicleId),
                          );
                    },
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
      bottomNavigationBar: CustomBottomNavBar(
        selectedIndex: _navIndex,
        onItemTapped: (index) {
          setState(() {
            _navIndex = index;
          });
        },
        onAddTapped: () {
          NuevoRegistroBottomSheet.show(
            context,
            vehicleId: widget.vehicleId,
          );
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.cardWhite.withOpacity(0.9),
      elevation: 0,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text(
            'Hola, David',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.onSurfaceVariant,
            ),
          ),
          Text(
            'Dashboard',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.onSurface,
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          onPressed: () {
            context.read<MantenimientoBloc>().add(
                  RefrescarDashboardEvent(vehicleId: widget.vehicleId),
                );
          },
          icon: const Icon(Icons.cloud_done, color: AppColors.onSurfaceVariant),
          tooltip: 'Sincronizar Datos',
        ),
        Padding(
          padding: const EdgeInsets.only(right: AppSpacing.sm),
          child: GestureDetector(
            onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ConfiguracionesPage(vehicleId: widget.vehicleId),
                ),
              );
              if (context.mounted) {
                context.read<MantenimientoBloc>().add(
                      RefrescarDashboardEvent(vehicleId: widget.vehicleId),
                    );
              }
            },
            child: const CircleAvatar(
              radius: 16,
              backgroundColor: AppColors.primary,
              child: Icon(Icons.settings, size: 18, color: AppColors.onPrimary),
            ),
          ),
        ),
      ],
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
            'Modo Offline-First (Datos locales cargados)',
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
}
