import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stitch_stepway_fleet_manager/core/database/sqlite_database_helper.dart';
import 'package:stitch_stepway_fleet_manager/core/theme/app_colors.dart';
import 'package:stitch_stepway_fleet_manager/core/theme/app_theme.dart';
import 'package:stitch_stepway_fleet_manager/features/auth/application/bloc/auth_bloc.dart';
import 'package:stitch_stepway_fleet_manager/features/auth/application/bloc/auth_event.dart';
import 'package:stitch_stepway_fleet_manager/features/auth/application/bloc/auth_state.dart';
import 'package:stitch_stepway_fleet_manager/features/dashboard/application/bloc/dashboard_bloc.dart';
import 'package:stitch_stepway_fleet_manager/features/dashboard/application/bloc/dashboard_event.dart';
import '../modals/cambiar_foto_modal.dart';
import 'package:stitch_stepway_fleet_manager/core/config/currency_manager.dart';

class ConfiguracionesPage extends StatefulWidget {
  final String vehicleId;
  const ConfiguracionesPage({
    super.key,
    this.vehicleId = 'veh-stepway-001',
  });

  @override
  State<ConfiguracionesPage> createState() => _ConfiguracionesPageState();
}

class _ConfiguracionesPageState extends State<ConfiguracionesPage> {
  String _imagenUrl =
      'https://images.unsplash.com/photo-1549399542-7e3f8b79c341?q=80&w=800&auto=format&fit=crop';

  final TextEditingController _nombreController = TextEditingController(text: 'Renault Sandero Stepway');
  final TextEditingController _placaController = TextEditingController(text: 'BXY-492');
  final TextEditingController _odometroController = TextEditingController(text: '45280');
  final TextEditingController _marcaController = TextEditingController(text: 'Renault');
  final TextEditingController _modeloController = TextEditingController(text: 'Sandero Stepway');
  final TextEditingController _versionController = TextEditingController(text: 'ZEN 1.6 16V');

  // Lógica Predictiva de Combustible
  final TextEditingController _tanqueController = TextEditingController(text: '50');
  final TextEditingController _rendimientoController = TextEditingController(text: '12.5');
  final TextEditingController _umbralReservaController = TextEditingController(text: '40');

  final TextEditingController _conductorController = TextEditingController(text: 'David');

  bool _notificacionesActivas = true;
  bool _modoOfflineActivo = true;
  bool _guardando = false;
  String _selectedCurrencyCode = 'COP';

  final List<Map<String, String>> _currenciesList = const [
    {'code': 'COP', 'name': 'Pesos Colombianos (COP)', 'symbol': '\$'},
    {'code': 'USD', 'name': 'Dólares Americanos (USD)', 'symbol': 'US\$'},
    {'code': 'EUR', 'name': 'Euros (EUR)', 'symbol': '€'},
    {'code': 'MXN', 'name': 'Pesos Mexicanos (MXN)', 'symbol': 'Mex\$'},
    {'code': 'ARS', 'name': 'Pesos Argentinos (ARS)', 'symbol': 'Arg\$'},
    {'code': 'PEN', 'name': 'Soles Peruanos (PEN)', 'symbol': 'S/.'},
    {'code': 'CLP', 'name': 'Pesos Chilenos (CLP)', 'symbol': 'CLP\$'},
    {'code': 'BRL', 'name': 'Real Brasileño (BRL)', 'symbol': 'R\$'},
  ];

  String _mapCurrencySymbol(String code) {
    switch (code) {
      case 'COP': return '\$';
      case 'USD': return 'US\$';
      case 'EUR': return '€';
      case 'MXN': return 'Mex\$';
      case 'ARS': return 'Arg\$';
      case 'PEN': return 'S/.';
      case 'CLP': return 'CLP\$';
      case 'BRL': return 'R\$';
      default: return '\$';
    }
  }

  @override
  void initState() {
    super.initState();
    _cargarDatosVehiculo();
    _cargarNombreConductor();
    _selectedCurrencyCode = CurrencyManager.currencyCode;
  }

  Future<void> _cargarNombreConductor() async {
    final prefs = await SharedPreferences.getInstance();
    final savedName = prefs.getString('driver_nickname');
    if (savedName != null && savedName.isNotEmpty) {
      _conductorController.text = savedName;
    }
  }

  Future<void> _cargarDatosVehiculo() async {
    try {
      final db = await SqliteDatabaseHelper.instance.database;
      final res = await db.query('vehicles');
      if (res.isNotEmpty) {
        final v = res.firstWhere(
          (element) => element['id'] == widget.vehicleId,
          orElse: () => res.first,
        );
        setState(() {
          _marcaController.text = (v['brand'] as String?) ?? 'Renault';
          _modeloController.text = (v['model'] as String?) ?? 'Sandero Stepway';
          _versionController.text = (v['version'] as String?) ?? 'ZEN 1.6';
          _placaController.text = (v['license_plate'] as String?) ?? 'BXY-492';
          _odometroController.text = ((v['current_odometer_km'] as int?) ?? 45280).toString();
          _nombreController.text = '${_marcaController.text} ${_modeloController.text}';
          
          final cap = (v['tank_capacity_liters'] as num?)?.toDouble() ?? 50.0;
          final eff = (v['fuel_efficiency_km_l'] as num?)?.toDouble() ?? 12.5;
          final resKm = (v['reserve_threshold_km'] as num?)?.toDouble() ?? 40.0;

          _tanqueController.text = cap.toStringAsFixed(0);
          _rendimientoController.text = eff.toStringAsFixed(1);
          _umbralReservaController.text = resKm.toStringAsFixed(0);

          final img = v['image_url'] as String?;
          if (img != null && img.isNotEmpty) {
            _imagenUrl = img;
          }
        });
      }
    } catch (e) {
      debugPrint('Error cargando vehículo: $e');
    }
  }

  Future<void> _actualizarFotoInstantanea(String nuevaUrl) async {
    if (_imagenUrl.isNotEmpty && _imagenUrl != nuevaUrl && !_imagenUrl.startsWith('http')) {
      try {
        final oldFile = File(_imagenUrl);
        if (oldFile.existsSync()) {
          oldFile.deleteSync();
        }
      } catch (_) {}
    }

    setState(() {
      _imagenUrl = nuevaUrl;
    });

    await _persistirEnSqlite();

    if (mounted) {
      context.read<DashboardBloc>().add(
            RefrescarDashboardEvent(vehicleId: widget.vehicleId),
          );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('¡Nueva foto inyectada en SQLite y actualizada en Home!'),
          backgroundColor: AppColors.primary,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _persistirEnSqlite() async {
    final km = int.tryParse(_odometroController.text) ?? 45280;
    final cap = double.tryParse(_tanqueController.text) ?? 50.0;
    final eff = double.tryParse(_rendimientoController.text) ?? 12.5;
    final resKm = double.tryParse(_umbralReservaController.text) ?? 40.0;

    try {
      final db = await SqliteDatabaseHelper.instance.database;
      try {
        await db.execute('ALTER TABLE vehicles ADD COLUMN image_url TEXT;');
      } catch (_) {}
      try {
        await db.execute('ALTER TABLE vehicles ADD COLUMN tank_capacity_liters REAL DEFAULT 50.0;');
        await db.execute('ALTER TABLE vehicles ADD COLUMN fuel_efficiency_km_l REAL DEFAULT 12.5;');
        await db.execute('ALTER TABLE vehicles ADD COLUMN reserve_threshold_km REAL DEFAULT 40.0;');
      } catch (_) {}

      await db.update(
        'vehicles',
        {
          'brand': _marcaController.text,
          'model': _modeloController.text,
          'version': _versionController.text,
          'license_plate': _placaController.text,
          'current_odometer_km': km,
          'image_url': _imagenUrl,
          'tank_capacity_liters': cap,
          'fuel_efficiency_km_l': eff,
          'reserve_threshold_km': resKm,
          'updated_at': DateTime.now().toIso8601String(),
        },
        where: 'id = ?',
        whereArgs: [widget.vehicleId],
      );
    } catch (e) {
      debugPrint('Error actualizando SQLite: $e');
    }
  }

  void _confirmarCerrarSesion(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: AppColors.surfaceContainerHigh,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: const [
              Icon(Icons.logout_rounded, color: Colors.redAccent),
              SizedBox(width: 8),
              Text('Cerrar Sesión', style: TextStyle(color: AppColors.onSurface, fontWeight: FontWeight.bold)),
            ],
          ),
          content: const Text(
            '¿Estás seguro de que deseas cerrar sesión?\nLos datos guardados en SQLite se conservarán en tu dispositivo.',
            style: TextStyle(color: AppColors.onSurfaceVariant),
          ),
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
                context.read<AuthBloc>().add(const CerrarSesionEvent());
              },
              child: const Text('Cerrar Sesión'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.cardWhite.withValues(alpha: 0.95),
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'Ajustes del Sistema',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.onSurface),
            ),
            Text(
              'Cuenta de Usuario, Ficha Técnica y Preferencias',
              style: TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          children: [
            // CARD DE CUENTA DE GOOGLE & AUTENTICACIÓN
            BlocBuilder<AuthBloc, AuthState>(
              builder: (context, authState) {
                if (authState is AuthenticatedState) {
                  final usr = authState.authToken.usuario;
                  return Container(
                    margin: const EdgeInsets.only(bottom: AppSpacing.md),
                    padding: AppSpacing.paddingMd,
                    decoration: BoxDecoration(
                      color: AppColors.cardWhite,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: const [AppColors.cardShadow],
                      border: Border.all(color: AppColors.primary.withValues(alpha: 0.3), width: 1.5),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.account_circle_rounded, color: AppColors.primary, size: 24),
                            ),
                            const SizedBox(width: AppSpacing.xs),
                            const Text(
                              'CUENTA CONECTADA',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.green.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: const [
                                  Icon(Icons.check_circle, size: 12, color: Colors.green),
                                  SizedBox(width: 4),
                                  Text(
                                    'Activa',
                                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.green),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.sm),

                        Row(
                          children: [
                            CircleAvatar(
                              radius: 26,
                              backgroundColor: AppColors.primary.withValues(alpha: 0.2),
                              backgroundImage: (usr.fotoUrl != null && usr.fotoUrl!.startsWith('http'))
                                  ? NetworkImage(usr.fotoUrl!)
                                  : null,
                              child: (usr.fotoUrl == null || !usr.fotoUrl!.startsWith('http'))
                                  ? Text(
                                      usr.nombre.isNotEmpty ? usr.nombre[0].toUpperCase() : 'U',
                                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.primary),
                                    )
                                  : null,
                            ),
                            const SizedBox(width: AppSpacing.md),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    usr.nombre,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.onSurface,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    usr.email,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: AppColors.onSurfaceVariant,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        const Divider(),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Respaldo SQLite:',
                              style: TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant),
                            ),
                            Text(
                              'Sincronizado',
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primary),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.sm),

                        // BOTÓN DE CERRAR SESIÓN
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: TextButton.icon(
                            style: TextButton.styleFrom(
                              backgroundColor: Colors.redAccent.withValues(alpha: 0.08),
                              foregroundColor: Colors.redAccent,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            ),
                            onPressed: () => _confirmarCerrarSesion(context),
                            icon: const Icon(Icons.logout_rounded, size: 20),
                            label: const Text(
                              'Cerrar Sesión de Google',
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                } else {
                  return Container(
                    margin: const EdgeInsets.only(bottom: AppSpacing.md),
                    padding: AppSpacing.paddingMd,
                    decoration: AppDecorations.cardDecoration(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: const [
                            Icon(Icons.no_accounts_rounded, color: AppColors.onSurfaceVariant, size: 22),
                            SizedBox(width: AppSpacing.xs),
                            Text(
                              'CUENTA DE USUARIO',
                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.onSurfaceVariant, letterSpacing: 0.5),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        const Text(
                          'No has iniciado sesión. Conéctate con Google para respaldar tu bitácora en la nube.',
                          style: TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        SizedBox(
                          width: double.infinity,
                          height: 46,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.cardWhite,
                              foregroundColor: AppColors.onSurface,
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                                side: BorderSide(color: AppColors.primary.withValues(alpha: 0.3)),
                              ),
                            ),
                            onPressed: () {
                              context.read<AuthBloc>().add(const SolicitarLoginConGoogleEvent());
                            },
                            icon: const Icon(Icons.g_mobiledata_rounded, color: AppColors.primary, size: 28),
                            label: const Text(
                              'Iniciar Sesión con Google',
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }
              },
            ),

            // Banner Rectangular Horizontal del Vehículo con Botón de Cámara Integrado
            GestureDetector(
              onTap: () {
                CambiarFotoModal.show(
                  context,
                  onFotoSeleccionada: (url) {
                    _actualizarFotoInstantanea(url);
                  },
                );
              },
              child: Stack(
                children: [
                  Container(
                    width: double.infinity,
                    height: 210,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: const [AppColors.cardShadow],
                      border: Border.all(color: AppColors.primary.withValues(alpha: 0.2), width: 2),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(18),
                      child: _buildVehicleImage(_imagenUrl),
                    ),
                  ),
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(18),
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.7),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 12,
                    left: 14,
                    right: 14,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _nombreController.text,
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                            Text(
                              'Placa: ${_placaController.text} • Toca para cambiar foto',
                              style: const TextStyle(fontSize: 12, color: Colors.white70),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.photo_camera, color: AppColors.onPrimary, size: 20),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            // Formulario de Configuración
            Container(
              padding: AppSpacing.paddingMd,
              decoration: AppDecorations.cardDecoration(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('INFORMACIÓN DEL VEHÍCULO', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.onSurfaceVariant, letterSpacing: 0.5)),
                  const SizedBox(height: AppSpacing.sm),

                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _marcaController,
                          decoration: InputDecoration(
                            labelText: 'Marca',
                            prefixIcon: const Icon(Icons.directions_car, color: AppColors.primary),
                            filled: true,
                            fillColor: AppColors.background,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: TextField(
                          controller: _modeloController,
                          decoration: InputDecoration(
                            labelText: 'Modelo',
                            prefixIcon: const Icon(Icons.time_to_leave, color: AppColors.primary),
                            filled: true,
                            fillColor: AppColors.background,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),

                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _versionController,
                          decoration: InputDecoration(
                            labelText: 'Versión / Año',
                            prefixIcon: const Icon(Icons.verified, color: AppColors.primary),
                            filled: true,
                            fillColor: AppColors.background,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: TextField(
                          controller: _placaController,
                          decoration: InputDecoration(
                            labelText: 'Placa',
                            prefixIcon: const Icon(Icons.badge, color: AppColors.primary),
                            filled: true,
                            fillColor: AppColors.background,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),

                  TextField(
                    controller: _odometroController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Kilometraje Actual (km)',
                      prefixIcon: const Icon(Icons.speed, color: AppColors.primary),
                      filled: true,
                      fillColor: AppColors.background,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            // Lógica Predictiva de Combustible & Alerta de Gasolineras
            Container(
              padding: AppSpacing.paddingMd,
              decoration: AppDecorations.cardDecoration(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: const [
                      Icon(Icons.auto_awesome, color: AppColors.primary, size: 18),
                      SizedBox(width: AppSpacing.xs),
                      Text('PARÁMETROS PREDICTIVOS DE COMBUSTIBLE', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.onSurfaceVariant, letterSpacing: 0.5)),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),

                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _tanqueController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'Tanque (Litros)',
                            prefixIcon: const Icon(Icons.local_gas_station, color: AppColors.primary),
                            filled: true,
                            fillColor: AppColors.background,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: TextField(
                          controller: _rendimientoController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          decoration: InputDecoration(
                            labelText: 'Rendimiento (km/L)',
                            prefixIcon: const Icon(Icons.equalizer, color: AppColors.primary),
                            filled: true,
                            fillColor: AppColors.background,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),

                  TextField(
                    controller: _umbralReservaController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Umbral Alerta Reserva (km de Autonomía)',
                      prefixIcon: const Icon(Icons.warning_amber, color: Colors.amber),
                      filled: true,
                      fillColor: AppColors.background,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            // Ficha Técnica del Vehículo
            Container(
              padding: AppSpacing.paddingMd,
              decoration: AppDecorations.cardDecoration(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: const [
                      Icon(Icons.construction, color: AppColors.primary, size: 18),
                      SizedBox(width: AppSpacing.xs),
                      Text('ESPECIFICACIONES TÉCNICAS', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.onSurfaceVariant, letterSpacing: 0.5)),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  _buildSpecRow('Motor', '1.6L 16V HR16DE (111 HP)'),
                  _buildSpecRow('Capacidad Tanque', '50 Litros (~13.2 Gal)'),
                  _buildSpecRow('Presión Llantas', '32 PSI Delantera / 30 PSI Trasera'),
                  _buildSpecRow('Aceite Sintético', 'Elf Evolution 10W40 / 5W30'),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            // Preferencias del Sistema
            Container(
              padding: AppSpacing.paddingMd,
              decoration: AppDecorations.cardDecoration(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('PREFERENCIAS DEL SISTEMA', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.onSurfaceVariant, letterSpacing: 0.5)),
                  const SizedBox(height: AppSpacing.xs),

                  SwitchListTile(
                    activeThumbColor: AppColors.primary,
                    secondary: const Icon(Icons.notifications_active, color: AppColors.primary),
                    title: const Text('Notificaciones de Mantenimiento', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                    subtitle: const Text('Alertas preventivas por kilometraje', style: TextStyle(fontSize: 12)),
                    value: _notificacionesActivas,
                    onChanged: (val) => setState(() => _notificacionesActivas = val),
                  ),
                  const Divider(),

                  SwitchListTile(
                    activeThumbColor: AppColors.primary,
                    secondary: const Icon(Icons.wifi_off, color: AppColors.primary),
                    title: const Text('Modo Offline-First (SQLite)', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                    subtitle: const Text('Sincronización silenciosa en segundo plano', style: TextStyle(fontSize: 12)),
                    value: _modoOfflineActivo,
                    onChanged: (val) => setState(() => _modoOfflineActivo = val),
                  ),
                  const Divider(),

                   // Selector de Moneda
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: DropdownButtonFormField<String>(
                      value: _selectedCurrencyCode,
                      decoration: InputDecoration(
                        labelText: 'Moneda de la Aplicación',
                        prefixIcon: const Icon(Icons.monetization_on, color: AppColors.primary),
                        filled: true,
                        fillColor: AppColors.background,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                      ),
                      items: _currenciesList.map((c) {
                        return DropdownMenuItem<String>(
                          value: c['code'],
                          child: Text(c['name']!, style: const TextStyle(fontSize: 14)),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setState(() {
                            _selectedCurrencyCode = val;
                          });
                        }
                      },
                    ),
                  ),
                  const Divider(),

                  // Campo de Apodo de Conductor
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: TextField(
                      controller: _conductorController,
                      textCapitalization: TextCapitalization.words,
                      decoration: InputDecoration(
                        labelText: 'Nombre / Apodo Conductor',
                        prefixIcon: const Icon(Icons.edit, color: AppColors.primary),
                        filled: true,
                        fillColor: AppColors.background,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Botón Guardar Cambios
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton.icon(
                onPressed: _guardando ? null : _guardarCambios,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.onPrimary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                  elevation: 4,
                ),
                icon: _guardando
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.onPrimary),
                      )
                    : const Icon(Icons.save),
                label: Text(
                  _guardando ? 'Guardando...' : 'Guardar Cambios Instantáneamente',
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
          ],
        ),
      ),
    );
  }

  Widget _buildVehicleImage(String pathOrUrl) {
    ImageProvider provider;
    if (pathOrUrl.startsWith('http://') || pathOrUrl.startsWith('https://')) {
      provider = NetworkImage(pathOrUrl);
    } else {
      final file = File(pathOrUrl);
      if (file.existsSync()) {
        provider = FileImage(file);
      } else {
        provider = const NetworkImage('https://images.unsplash.com/photo-1549399542-7e3f8b79c341?q=80&w=800&auto=format&fit=crop');
      }
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        Image(
          image: provider,
          fit: BoxFit.cover,
          alignment: Alignment.center,
          errorBuilder: (_, __, ___) => const SizedBox(),
        ),
        Container(
          color: Colors.black.withValues(alpha: 0.55),
        ),
        Image(
          image: provider,
          fit: BoxFit.contain,
          alignment: Alignment.center,
          errorBuilder: (_, __, ___) => const Center(
            child: Icon(Icons.directions_car, size: 70, color: AppColors.primary),
          ),
        ),
      ],
    );
  }

  Widget _buildSpecRow(String label, String val) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 13, color: AppColors.onSurfaceVariant)),
          Text(val, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.onSurface)),
        ],
      ),
    );
  }

  void _guardarCambios() async {
    setState(() {
      _guardando = true;
    });

    await _persistirEnSqlite();

    // Guardar apodo del conductor en SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    final conductorName = _conductorController.text.trim().split(' ').first;
    if (conductorName.isNotEmpty) {
      await prefs.setString('driver_nickname', conductorName);
    }

    // Guardar moneda elegida
    final symbol = _mapCurrencySymbol(_selectedCurrencyCode);
    await CurrencyManager.setCurrency(_selectedCurrencyCode, symbol);

    if (!mounted) return;

    setState(() {
      _guardando = false;
    });

    context.read<DashboardBloc>().add(
          RefrescarDashboardEvent(vehicleId: widget.vehicleId),
        );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('¡Ficha y apodo guardados instantáneamente!'),
        backgroundColor: AppColors.primary,
        duration: Duration(seconds: 2),
      ),
    );
  }
}
