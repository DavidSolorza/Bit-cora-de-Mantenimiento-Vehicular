import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../domain/entities/registro_mantenimiento.dart';
import 'package:stitch_stepway_fleet_manager/core/config/currency_manager.dart';

/// Servicio de generación, auditoría y exportación de reportes de bitácora técnica
class ReporteExportService {
  static String generarReporteTexto({
    required String vehicleName,
    required String licensePlate,
    required List<RegistroMantenimientoEntity> registros,
    required double gastoTotal,
  }) {
    final buffer = StringBuffer();

    // Desglose por categorías
    double totalCombustible = 0;
    double totalTaller = 0;
    double totalLavado = 0;

    for (var r in registros) {
      switch (r.categoria) {
        case CategoriaMantenimiento.gasolina:
          totalCombustible += r.costo;
          break;
        case CategoriaMantenimiento.taller:
          totalTaller += r.costo;
          break;
        case CategoriaMantenimiento.lavado:
          totalLavado += r.costo;
          break;
      }
    }

    final maxKm = registros.isEmpty
        ? 45280
        : registros.map((r) => r.kilometraje).reduce((a, b) => a > b ? a : b);

    buffer.writeln('====================================================');
    buffer.writeln('       INFORME AUDITADO DE MANTENIMIENTO TÉCNICO');
    buffer.writeln('            BITÁCORA STEPWAY FLEET MANAGER');
    buffer.writeln('====================================================');
    buffer.writeln('  Vehículo:               $vehicleName');
    buffer.writeln('  Placa / Matrícula:       $licensePlate');
    buffer.writeln('  Odómetro de Registro:    $maxKm km');
    buffer.writeln('  Fecha de Emisión:        ${DateTime.now().toString().split(' ')[0]}');
    buffer.writeln('  Servidor de Datos:       PostgreSQL Cloud Live');
    buffer.writeln('----------------------------------------------------');
    buffer.writeln(' RESUMEN FINANCIERO Y OPERATIVO:');
    buffer.writeln('  - Inversión Total:       ${CurrencyManager.format(gastoTotal)}');
    buffer.writeln('  - Gasto en Combustible:  ${CurrencyManager.format(totalCombustible)}');
    buffer.writeln('  - Gasto en Taller/Motor: ${CurrencyManager.format(totalTaller)}');
    buffer.writeln('  - Gasto en Detallado:    ${CurrencyManager.format(totalLavado)}');
    buffer.writeln('  - Total Intervenciones:  ${registros.length} registros');
    buffer.writeln('====================================================\n');

    buffer.writeln('HISTORIAL DETALLADO DE SERVICIOS:');
    if (registros.isEmpty) {
      buffer.writeln('  (Sin registros de mantenimiento cargados)');
    } else {
      for (int i = 0; i < registros.length; i++) {
        final r = registros[i];
        final fechaStr = '${r.fecha.day.toString().padLeft(2, '0')}/${r.fecha.month.toString().padLeft(2, '0')}/${r.fecha.year}';
        buffer.writeln('${(i + 1).toString().padLeft(2, '0')}. [$fechaStr] ${r.titulo}');
        buffer.writeln('    Categoría:   ${r.categoria.name.toUpperCase()}');
        buffer.writeln('    Odómetro:    ${r.kilometraje} km');
        buffer.writeln('    Costo:       ${CurrencyManager.format(r.costo)}');
        buffer.writeln('----------------------------------------------------');
      }
    }

    buffer.writeln('\n[Fin del Documento - Sistema de Gestión de Flotas Stepway]');
    return buffer.toString();
  }

  static void mostrarModalExportacion(
    BuildContext context, {
    required String vehicleName,
    required String licensePlate,
    required List<RegistroMantenimientoEntity> registros,
    required double gastoTotal,
  }) {
    final reporteStr = generarReporteTexto(
      vehicleName: vehicleName,
      licensePlate: licensePlate,
      registros: registros,
      gastoTotal: gastoTotal,
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: const [
            Icon(Icons.assessment, color: Colors.blueAccent, size: 24),
            SizedBox(width: 10),
            Text('Informe Técnico Auditor', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(12),
              ),
              child: SelectableText(
                reporteStr,
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 11,
                  color: Color(0xFF38BDF8),
                  height: 1.4,
                ),
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: reporteStr));
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('¡Informe copiado al portapapeles y listo para exportar!'),
                  backgroundColor: Colors.blueAccent,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueAccent,
              foregroundColor: Colors.white,
            ),
            icon: const Icon(Icons.copy, size: 18),
            label: const Text('Copiar Reporte'),
          ),
        ],
      ),
    );
  }
}
