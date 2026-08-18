import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stitch_stepway_fleet_manager/core/theme/app_colors.dart';
import 'package:stitch_stepway_fleet_manager/core/theme/app_theme.dart';
import 'package:stitch_stepway_fleet_manager/features/auth/application/bloc/auth_bloc.dart';
import 'package:stitch_stepway_fleet_manager/features/auth/application/bloc/auth_state.dart';
import 'package:stitch_stepway_fleet_manager/features/mantenimiento/domain/entities/registro_mantenimiento.dart';
import 'package:stitch_stepway_fleet_manager/features/mantenimiento/application/bloc/mantenimiento_historial_bloc.dart';
import 'package:stitch_stepway_fleet_manager/features/mantenimiento/application/bloc/mantenimiento_historial_event.dart';
import 'package:stitch_stepway_fleet_manager/features/mantenimiento/application/bloc/mantenimiento_historial_state.dart';
import 'package:stitch_stepway_fleet_manager/features/mantenimiento/application/services/reporte_export_service.dart';
import 'package:stitch_stepway_fleet_manager/core/config/currency_manager.dart';
import 'package:stitch_stepway_fleet_manager/core/database/sqlite_database_helper.dart';
import 'nuevo_registro_bottom_sheet.dart';

class HistorialPage extends StatefulWidget {
  final String vehicleId;
  final VoidCallback? onProfileTap;

  const HistorialPage({
    super.key,
    this.vehicleId = '40cc315c-ad6f-449e-8e16-48c5564bdc27',
    this.onProfileTap,
  });

  @override
  State<HistorialPage> createState() => _HistorialPageState();
}

class _HistorialPageState extends State<HistorialPage> {
  final TextEditingController _searchController = TextEditingController();
  String _busqueda = '';
  Future<List<Map<String, dynamic>>>? _tripsFuture;

  @override
  void initState() {
    super.initState();
    context.read<MantenimientoHistorialBloc>().add(
          CargarHistorialEvent(vehicleId: widget.vehicleId),
        );
    _reloadTrips();
  }

  void _reloadTrips() {
    setState(() {
      _tripsFuture = _loadTripsFromDb();
    });
  }

  Future<List<Map<String, dynamic>>> _loadTripsFromDb() async {
    try {
      final db = await SqliteDatabaseHelper.instance.database;
      final res = await db.query(
        'trips',
        where: 'vehicle_id = ?',
        whereArgs: [widget.vehicleId],
        orderBy: 'trip_date DESC',
      );
      if (res.isEmpty) {
        // Fallback fallback id en caso de que este buscando con un ID diferente al semilla
        return await db.query('trips', orderBy: 'trip_date DESC');
      }
      return res;
    } catch (e) {
      debugPrint('Error cargando viajes: $e');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.cardWhite.withOpacity(0.9),
          elevation: 0,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                'Seguimiento Integral',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.onSurfaceVariant),
              ),
              Text(
                'Historial & Rutas',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.onSurface),
              ),
            ],
          ),
          actions: [
            BlocBuilder<AuthBloc, AuthState>(
              builder: (context, authState) {
                String userName = 'David';
                String? fotoUrl;

                if (authState is AuthenticatedState) {
                  final user = authState.authToken.usuario;
                  if (user.nombre.isNotEmpty) {
                    userName = user.nombre;
                  }
                  fotoUrl = user.fotoUrl;
                }

                String initials = userName.isNotEmpty ? userName[0].toUpperCase() : 'U';

                return Semantics(
                  label: 'Ver perfil y ajustes del vehículo',
                  button: true,
                  child: GestureDetector(
                    onTap: widget.onProfileTap,
                    child: Hero(
                      tag: 'profile_avatar_hero_historial',
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
                                  initials,
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
                );
              },
            ),
            const SizedBox(width: AppSpacing.sm),
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(50),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
              child: Container(
                height: 38,
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const TabBar(
                  indicatorSize: TabBarIndicatorSize.tab,
                  indicator: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                  ),
                  labelColor: Colors.white,
                  unselectedLabelColor: AppColors.onSurfaceVariant,
                  labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  tabs: [
                    Tab(text: 'Gastos & Bitácora'),
                    Tab(text: 'Historial Kilometraje'),
                  ],
                ),
              ),
            ),
          ),
        ),
        body: TabBarView(
          children: [
            _buildGastosTab(context),
            _buildViajesTab(context),
          ],
        ),
      ),
    );
  }

  Widget _buildGastosTab(BuildContext context) {
    return BlocBuilder<MantenimientoHistorialBloc, MantenimientoHistorialState>(
      builder: (context, state) {
        if (state is MantenimientoHistorialLoadingState) {
          return const Center(child: CircularProgressIndicator(color: AppColors.primary));
        } else if (state is MantenimientoHistorialLoadedState) {
          final registrosFiltradosBusqueda = state.registrosFiltrados.where((r) {
            if (_busqueda.isEmpty) return true;
            return r.titulo.toLowerCase().contains(_busqueda.toLowerCase()) ||
                r.kilometraje.toString().contains(_busqueda);
          }).toList();

          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTotalExpensesCard(state.gastoTotal, state.registrosFiltrados),
                const SizedBox(height: AppSpacing.md),

                // Buscador Intuitivo
                TextField(
                  controller: _searchController,
                  onChanged: (val) {
                    setState(() {
                      _busqueda = val;
                    });
                  },
                  decoration: InputDecoration(
                    hintText: 'Buscar registro por concepto o km...',
                    prefixIcon: const Icon(Icons.search, color: AppColors.primary),
                    suffixIcon: _busqueda.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 18),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {
                                _busqueda = '';
                              });
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: AppColors.cardWhite,
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),

                _buildCategoryFilters(context, state.categoriaSeleccionada),
                const SizedBox(height: AppSpacing.md),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Historial de Mantenimientos',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.onSurface),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerHigh,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        '${registrosFiltradosBusqueda.length} ítems',
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primary),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),

                registrosFiltradosBusqueda.isEmpty
                    ? Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        decoration: AppDecorations.cardDecoration(),
                        child: Column(
                          children: const [
                            Icon(Icons.search_off, size: 48, color: AppColors.onSurfaceVariant),
                            SizedBox(height: AppSpacing.xs),
                            Text('No se encontraron registros', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.onSurface)),
                            Text('Intenta cambiar el filtro o agregar un nuevo gasto.', style: TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant)),
                          ],
                        ),
                      )
                    : ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: registrosFiltradosBusqueda.length,
                        separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
                        itemBuilder: (context, index) {
                          final registro = registrosFiltradosBusqueda[index];
                          return _buildRegistroCard(registro);
                        },
                      ),
                const SizedBox(height: AppSpacing.lg),
              ],
            ),
          );
        } else if (state is MantenimientoHistorialErrorState) {
          return Center(child: Text(state.mensajeError));
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildViajesTab(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _tripsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: AppColors.primary));
        }
        if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.map_outlined, size: 48, color: AppColors.onSurfaceVariant),
                  SizedBox(height: 12),
                  Text(
                    'No hay viajes registrados',
                    style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.onSurface),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Los viajes se registrarán automáticamente basándose en los cambios de odómetro.',
                    style: TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }

        final trips = snapshot.data!;
        return ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.md),
          itemCount: trips.length,
          separatorBuilder: (_, __) => const SizedBox(height: 16),
          itemBuilder: (context, index) {
            final trip = trips[index];
            final origin = trip['origin'] as String;
            final dest = trip['destination'] as String;
            final startKm = trip['start_km'] as int;
            final endKm = trip['end_km'] as int;
            final distance = endKm - startKm;
            final fuelLiters = (trip['fuel_used_liters'] as num).toDouble();
            final dateStr = trip['trip_date'] as String;
            final date = DateTime.parse(dateStr);

            return Container(
              padding: AppSpacing.paddingMd,
              decoration: AppDecorations.cardDecoration(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Cabecera del Viaje
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.calendar_today, size: 12, color: AppColors.primary),
                                const SizedBox(width: 4),
                                Text(
                                  '${date.day}/${date.month}/${date.year}',
                                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primary),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      Text(
                        '+$distance km recorridos',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.onSurface),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Mapa / Trazado de Ruta Simulado
                  Container(
                    width: double.infinity,
                    height: 100,
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.surfaceContainerHigh),
                    ),
                    child: Stack(
                      children: [
                        // Cuadrícula y línea de ruta abstracta simulando mapa GPS
                        Positioned.fill(
                          child: Opacity(
                            opacity: 0.08,
                            child: GridPaper(
                              color: AppColors.primary,
                              interval: 30,
                              divisions: 2,
                              subdivisions: 1,
                            ),
                          ),
                        ),
                        // Línea de ruta con puntos
                        Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.my_location, size: 18, color: Colors.green),
                                  const SizedBox(height: 4),
                                  Text(origin, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppColors.onSurfaceVariant)),
                                ],
                              ),
                              // Conector de ruta
                              Expanded(
                                child: Container(
                                  height: 2,
                                  decoration: const BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [Colors.green, AppColors.primary, Colors.redAccent],
                                    ),
                                  ),
                                ),
                              ),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.location_on, size: 18, color: Colors.redAccent),
                                  const SizedBox(height: 4),
                                  Text(dest, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppColors.onSurfaceVariant)),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Fila de Métricas del Viaje
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildTripStat(Icons.speed, 'Odómetro', '$startKm - $endKm km'),
                      _buildTripStat(Icons.local_gas_station, 'Consumo', '${fuelLiters.toStringAsFixed(1)} Gal (Gasolina)'),
                      _buildTripStat(Icons.electric_car, 'Rendimiento', '${(distance / fuelLiters).toStringAsFixed(1)} km/Gal'),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildTripStat(IconData icon, String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 14, color: AppColors.onSurfaceVariant),
            const SizedBox(width: 4),
            Text(
              label,
              style: const TextStyle(fontSize: 10, color: AppColors.onSurfaceVariant, fontWeight: FontWeight.w600),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.onSurface),
        ),
      ],
    );
  }

  Widget _buildTotalExpensesCard(double total, List<RegistroMantenimientoEntity> registros) {
    return Container(
      width: double.infinity,
      padding: AppSpacing.paddingMd,
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [AppColors.cardShadow],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'GASTO TOTAL ACUMULADO',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                  color: AppColors.onPrimary,
                ),
              ),
              const SizedBox(height: 4),
               Text(
                CurrencyManager.format(total),
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.onPrimary,
                ),
              ),
            ],
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.cardWhite,
              foregroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              ReporteExportService.mostrarModalExportacion(
                context,
                vehicleName: 'Renault Sandero Stepway',
                licensePlate: 'BXY-492',
                registros: registros,
                gastoTotal: total,
              );
            },
            icon: const Icon(Icons.file_download, size: 18),
            label: const Text('Exportar Reporte', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryFilters(BuildContext context, CategoriaMantenimiento? seleccionada) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: CategoriaMantenimiento.values.map((cat) {
          final isSelected = seleccionada == cat;
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: ChoiceChip(
              label: Text(
                _getCategoryLabel(cat),
                style: TextStyle(
                  color: isSelected ? AppColors.onPrimary : AppColors.onSurfaceVariant,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
              selected: isSelected,
              selectedColor: AppColors.primary,
              backgroundColor: AppColors.cardWhite,
              onSelected: (selected) {
                context.read<MantenimientoHistorialBloc>().add(
                      FiltrarCategoriaEvent(
                        categoria: selected ? cat : null,
                      ),
                    );
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  String _getCategoryLabel(CategoriaMantenimiento cat) {
    switch (cat) {
      case CategoriaMantenimiento.gasolina:
        return 'Gasolina';
      case CategoriaMantenimiento.taller:
        return 'Taller / Mecánico';
      case CategoriaMantenimiento.lavado:
        return 'Lavado';
    }
  }

  Widget _buildRegistroCard(RegistroMantenimientoEntity registro) {
    IconData icon;
    Color iconBg;

    switch (registro.categoria) {
      case CategoriaMantenimiento.gasolina:
        icon = Icons.local_gas_station;
        iconBg = AppColors.secondaryContainer;
        break;
      case CategoriaMantenimiento.lavado:
        icon = Icons.local_car_wash;
        iconBg = AppColors.secondaryContainer;
        break;
      case CategoriaMantenimiento.taller:
      default:
        icon = Icons.build;
        iconBg = AppColors.surfaceContainerHigh;
        break;
    }

    return GestureDetector(
      onTap: () {
        _mostrarOpcionesRegistro(context, registro);
      },
      child: Container(
        padding: AppSpacing.paddingMd,
        decoration: AppDecorations.cardDecoration(),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
              child: Icon(icon, color: AppColors.primary, size: 24),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    registro.titulo,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.onSurface),
                  ),
                  Text(
                    '${registro.fecha.day}/${registro.fecha.month}/${registro.fecha.year}',
                    style: const TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  CurrencyManager.format(registro.costo),
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.onSurface),
                ),
                Text(
                  '${registro.kilometraje} km',
                  style: const TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _mostrarOpcionesRegistro(BuildContext context, RegistroMantenimientoEntity registro) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surfaceContainerHigh,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (modalContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.onSurfaceVariant.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.edit_road, color: AppColors.primary),
                title: const Text('Editar Registro', style: TextStyle(fontWeight: FontWeight.bold)),
                onTap: () {
                  Navigator.pop(modalContext);
                  NuevoRegistroBottomSheet.show(
                    context,
                    vehicleId: widget.vehicleId,
                    categoriaInicial: registro.categoria,
                    registroParaEditar: registro,
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete_forever, color: Colors.redAccent),
                title: const Text('Eliminar Registro', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.redAccent)),
                onTap: () {
                  Navigator.pop(modalContext);
                  _confirmarEliminar(context, registro);
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  void _confirmarEliminar(BuildContext context, RegistroMantenimientoEntity registro) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: AppColors.surfaceContainerHigh,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: const [
              Icon(Icons.warning, color: Colors.redAccent),
              SizedBox(width: 8),
              Text('Eliminar Registro', style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          content: Text('¿Estás seguro de que deseas eliminar "${registro.titulo}" de tu bitácora?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancelar', style: TextStyle(color: AppColors.onSurfaceVariant)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () {
                Navigator.pop(dialogContext);
                context.read<MantenimientoHistorialBloc>().add(
                      EliminarRegistroEvent(vehicleId: widget.vehicleId, registroId: registro.id),
                    );
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Registro eliminado de la bitácora local.'),
                    backgroundColor: Colors.redAccent,
                  ),
                );
              },
              child: const Text('Eliminar'),
            ),
          ],
        );
      },
    );
  }
}
