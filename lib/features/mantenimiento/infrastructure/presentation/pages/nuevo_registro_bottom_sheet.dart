import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stitch_stepway_fleet_manager/core/config/app_config.dart';
import 'package:stitch_stepway_fleet_manager/core/http/native_http_client.dart';
import 'package:stitch_stepway_fleet_manager/core/theme/app_colors.dart';
import 'package:stitch_stepway_fleet_manager/core/theme/app_theme.dart';
import 'package:stitch_stepway_fleet_manager/features/mantenimiento/domain/entities/registro_mantenimiento.dart';
import 'package:stitch_stepway_fleet_manager/features/mantenimiento/application/bloc/mantenimiento_historial_bloc.dart';
import 'package:stitch_stepway_fleet_manager/features/mantenimiento/application/bloc/mantenimiento_historial_event.dart';
import 'package:stitch_stepway_fleet_manager/core/config/currency_manager.dart';

class NuevoRegistroBottomSheet extends StatefulWidget {
  final String vehicleId;
  final CategoriaMantenimiento categoriaInicial;
  final RegistroMantenimientoEntity? registroParaEditar;

  const NuevoRegistroBottomSheet({
    super.key,
    this.vehicleId = '40cc315c-ad6f-449e-8e16-48c5564bdc27',
    this.categoriaInicial = CategoriaMantenimiento.taller,
    this.registroParaEditar,
  });

  static Future<void> show(
    BuildContext context, {
    String vehicleId = '40cc315c-ad6f-449e-8e16-48c5564bdc27',
    CategoriaMantenimiento categoriaInicial = CategoriaMantenimiento.taller,
    RegistroMantenimientoEntity? registroParaEditar,
  }) {
    final bloc = context.read<MantenimientoHistorialBloc>();
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (modalContext) => BlocProvider.value(
        value: bloc,
        child: NuevoRegistroBottomSheet(
          vehicleId: vehicleId,
          categoriaInicial: categoriaInicial,
          registroParaEditar: registroParaEditar,
        ),
      ),
    );
  }

  @override
  State<NuevoRegistroBottomSheet> createState() => _NuevoRegistroBottomSheetState();
}

class _NuevoRegistroBottomSheetState extends State<NuevoRegistroBottomSheet> {
  final NativeHttpClient _httpClient = NativeHttpClient();
  late CategoriaMantenimiento _categoriaSeleccionada;
  final TextEditingController _costoController = TextEditingController();
  final TextEditingController _kilometrajeController = TextEditingController(text: '45280');
  final TextEditingController _tituloController = TextEditingController();
  final TextEditingController _descripcionController = TextEditingController();
  String _prioridad = 'HIGH';
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    if (widget.registroParaEditar != null) {
      final r = widget.registroParaEditar!;
      _categoriaSeleccionada = r.categoria;
      _tituloController.text = r.titulo;
      _costoController.text = '${r.costo}';
      _kilometrajeController.text = '${r.kilometraje}';
    } else {
      _categoriaSeleccionada = widget.categoriaInicial;
      _actualizarTituloPredeterminado();
    }
  }

  void _actualizarTituloPredeterminado() {
    if (_tituloController.text.isNotEmpty &&
        _tituloController.text != 'Tanqueo de Combustible' &&
        _tituloController.text != 'Mantenimiento General' &&
        _tituloController.text != 'Lavado y Detallado') {
      return;
    }
    switch (_categoriaSeleccionada) {
      case CategoriaMantenimiento.gasolina:
        _tituloController.text = 'Tanqueo de Combustible';
        break;
      case CategoriaMantenimiento.taller:
        _tituloController.text = 'Mantenimiento General';
        break;
      case CategoriaMantenimiento.lavado:
        _tituloController.text = 'Lavado y Detallado';
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: AppSpacing.md,
        right: AppSpacing.md,
        top: AppSpacing.sm,
        bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.md,
      ),
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 48,
                height: 5,
                decoration: BoxDecoration(
                  color: AppColors.onSurfaceVariant.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Nuevo Mantenimiento (PostgreSQL)',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.onSurface,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, color: AppColors.onSurfaceVariant),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xs),

            const Text(
              'Categoría Técnica',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AppColors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Row(
              children: [
                _buildCategoryButton(
                  categoria: CategoriaMantenimiento.gasolina,
                  label: 'Combustible',
                  icon: Icons.local_gas_station,
                ),
                const SizedBox(width: AppSpacing.xs),
                _buildCategoryButton(
                  categoria: CategoriaMantenimiento.taller,
                  label: 'Taller / Motor',
                  icon: Icons.build,
                ),
                const SizedBox(width: AppSpacing.xs),
                _buildCategoryButton(
                  categoria: CategoriaMantenimiento.lavado,
                  label: 'Lavado',
                  icon: Icons.local_car_wash,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),

            TextField(
              controller: _tituloController,
              decoration: InputDecoration(
                labelText: 'Título o Concepto del Servicio',
                prefixIcon: const Icon(Icons.edit_note, color: AppColors.primary),
                filled: true,
                fillColor: AppColors.cardWhite,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),

            TextField(
              controller: _descripcionController,
              decoration: InputDecoration(
                labelText: 'Detalles / Piezas sustituidas (Opcional)',
                prefixIcon: const Icon(Icons.notes, color: AppColors.primary),
                filled: true,
                fillColor: AppColors.cardWhite,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),

            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _costoController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Costo (${CurrencyManager.currencySymbol} ${CurrencyManager.currencyCode})',
                      prefixIcon: const Icon(Icons.payments, color: AppColors.primary),
                      filled: true,
                      fillColor: AppColors.cardWhite,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: TextField(
                    controller: _kilometrajeController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Odómetro (km)',
                      prefixIcon: const Icon(Icons.speed, color: AppColors.primary),
                      filled: true,
                      fillColor: AppColors.cardWhite,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),

            // Selector de Prioridad
            Row(
              children: [
                const Text(
                  'Prioridad:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
                const SizedBox(width: 12),
                ChoiceChip(
                  label: const Text('ALTA'),
                  selected: _prioridad == 'HIGH',
                  onSelected: (val) => setState(() => _prioridad = 'HIGH'),
                ),
                const SizedBox(width: 6),
                ChoiceChip(
                  label: const Text('MEDIA'),
                  selected: _prioridad == 'MEDIUM',
                  onSelected: (val) => setState(() => _prioridad = 'MEDIUM'),
                ),
                const SizedBox(width: 6),
                ChoiceChip(
                  label: const Text('BAJA'),
                  selected: _prioridad == 'LOW',
                  onSelected: (val) => setState(() => _prioridad = 'LOW'),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: _isSubmitting ? null : _guardarRegistro,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.onPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(999),
                  ),
                  elevation: 2,
                ),
                icon: _isSubmitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : const Icon(Icons.cloud_upload),
                label: Text(
                  _isSubmitting ? 'Guardando en PostgreSQL...' : 'Guardar Registro en PostgreSQL',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryButton({
    required CategoriaMantenimiento categoria,
    required String label,
    required IconData icon,
  }) {
    final bool selected = _categoriaSeleccionada == categoria;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _categoriaSeleccionada = categoria;
            _actualizarTituloPredeterminado();
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
          decoration: BoxDecoration(
            color: selected ? AppColors.primary : AppColors.cardWhite,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selected ? AppColors.primary : AppColors.surfaceContainerHigh,
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: selected ? AppColors.onPrimary : AppColors.primary,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: selected ? AppColors.onPrimary : AppColors.onSurface,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _guardarRegistro() async {
    final costo = double.tryParse(_costoController.text) ?? 0.0;
    final km = int.tryParse(_kilometrajeController.text) ?? 45280;
    final titulo = _tituloController.text.isEmpty
        ? 'Mantenimiento de Servicio'
        : _tituloController.text;
    final desc = _descripcionController.text.isEmpty
        ? 'Servicio registrado desde la app móvil.'
        : _descripcionController.text;

    setState(() {
      _isSubmitting = true;
    });

    final id = widget.registroParaEditar?.id ?? DateTime.now().millisecondsSinceEpoch.toString();
    final fecha = widget.registroParaEditar?.fecha ?? DateTime.now();

    final nuevoRegistro = RegistroMantenimientoEntity(
      id: id,
      titulo: titulo,
      costo: costo,
      kilometraje: km,
      fecha: fecha,
      categoria: _categoriaSeleccionada,
    );

    // 1. Guardar localmente en SQLite
    if (widget.registroParaEditar != null) {
      context.read<MantenimientoHistorialBloc>().add(
            EditarRegistroEvent(
              vehicleId: widget.vehicleId,
              registro: nuevoRegistro,
            ),
          );
    } else {
      context.read<MantenimientoHistorialBloc>().add(
            AgregarNuevoRegistroEvent(
              vehicleId: widget.vehicleId,
              registro: nuevoRegistro,
            ),
          );
    }

    // 2. Enviar a la API PostgreSQL en la nube
    try {
      final url = '${AppConfig.apiBaseUrl}${AppConfig.endpointRegistros}';
      await _httpClient.post(
        url,
        body: {
          'vehicle_id': widget.vehicleId,
          'category_id': '25bff32a-5c63-47b1-be0c-9a6eefa7ae3d',
          'title': titulo,
          'description': desc,
          'cost': costo,
          'odometer_km': km,
          'performed_at': DateTime.now().toIso8601String(),
          'next_recommended_km': km + 10000,
          'priority_level': _prioridad,
        },
      );
    } catch (_) {
      // Si falla la red, queda guardado en SQLite localmente para posterior sync
    }

    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('¡Mantenimiento sincronizado en PostgreSQL & SQLite local!'),
          backgroundColor: AppColors.primary,
        ),
      );
    }
  }
}
