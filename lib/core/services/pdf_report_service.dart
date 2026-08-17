import 'dart:io';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:stitch_stepway_fleet_manager/core/database/sqlite_database_helper.dart';

class PdfReportService {
  static Future<void> generateAndShareVehicleReport(BuildContext context, String vehicleId) async {
    try {
      final db = await SqliteDatabaseHelper.instance.database;

      // 1. Obtener Datos del Vehículo
      final vehicleRes = await db.query(
        'vehicles',
        where: 'id = ?',
        whereArgs: [vehicleId],
      );

      if (vehicleRes.isEmpty) {
        throw Exception('Vehículo no encontrado');
      }

      final vehicle = vehicleRes.first;
      final String marca = vehicle['brand'] as String? ?? 'Renault';
      final String modelo = vehicle['model'] as String? ?? 'Sandero Stepway';
      final String placa = vehicle['license_plate'] as String? ?? 'BXY-492';
      final int km = vehicle['current_odometer_km'] as int? ?? 45280;

      // 2. Obtener Historial de Bitácora (Ordenado por fecha descendente)
      final logsRes = await db.query(
        'maintenance_logs',
        where: 'vehicle_id = ?',
        whereArgs: [vehicleId],
        orderBy: 'date DESC',
      );

      // 3. Crear el Documento PDF
      final pdf = pw.Document();

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.letter,
          margin: const pw.EdgeInsets.all(32),
          build: (pw.Context context) {
            return [
              // Encabezado
              pw.Header(
                level: 0,
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          'Ficha de Bitácora Stepway',
                          style: pw.TextStyle(
                            fontSize: 24,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.blue800,
                          ),
                        ),
                        pw.SizedBox(height: 4),
                        pw.Text(
                          'Gestión de Flota Predictiva & Control de Gastos',
                          style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
                        ),
                      ],
                    ),
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        pw.Text(
                          'Fecha Emisión: ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
                          style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 20),

              // Ficha del Vehículo
              pw.Text(
                'Datos del Vehículo',
                style: pw.TextStyle(
                  fontSize: 14,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.blue800,
                ),
              ),
              pw.Divider(color: PdfColors.blue800, thickness: 1),
              pw.SizedBox(height: 8),
              pw.Table(
                border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
                children: [
                  pw.TableRow(
                    children: [
                      _buildTableCell('Marca/Modelo', isHeader: true),
                      _buildTableCell('$marca $modelo'),
                      _buildTableCell('Placa', isHeader: true),
                      _buildTableCell(placa),
                    ],
                  ),
                  pw.TableRow(
                    children: [
                      _buildTableCell('Kilometraje Actual', isHeader: true),
                      _buildTableCell('$km km'),
                      _buildTableCell('Registros Totales', isHeader: true),
                      _buildTableCell('${logsRes.length} registros'),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 24),

              // Tabla de Historial de Bitácora
              pw.Text(
                'Historial de Mantenimientos y Tanqueos',
                style: pw.TextStyle(
                  fontSize: 14,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.blue800,
                ),
              ),
              pw.Divider(color: PdfColors.blue800, thickness: 1),
              pw.SizedBox(height: 8),

              if (logsRes.isEmpty)
                pw.Paragraph(
                  text: 'No se registran tanqueos o mantenimientos en el historial actualmente.',
                  style: const pw.TextStyle(fontSize: 11, color: PdfColors.grey600),
                )
              else
                pw.Table(
                  border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
                  columnWidths: {
                    0: const pw.FixedColumnWidth(80), // Fecha
                    1: const pw.FixedColumnWidth(70), // Categoria
                    2: const pw.FixedColumnWidth(180), // Titulo / Detalle
                    3: const pw.FixedColumnWidth(70), // Costo
                  },
                  children: [
                    // Fila de Encabezado
                    pw.TableRow(
                      decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                      children: [
                        _buildTableCell('Fecha', isHeader: true, alignCenter: true),
                        _buildTableCell('Categoría', isHeader: true, alignCenter: true),
                        _buildTableCell('Detalle / Observación', isHeader: true),
                        _buildTableCell('Costo', isHeader: true, alignCenter: true),
                      ],
                    ),
                    // Filas de Datos
                    ...logsRes.map((log) {
                      final rawDate = log['date'] as String? ?? '';
                      final formattedDate = rawDate.split('T').first;
                      final String category = log['category'] as String? ?? '';
                      final String title = log['title'] as String? ?? '';
                      final double cost = (log['cost'] as num? ?? 0.0).toDouble();

                      return pw.TableRow(
                        children: [
                          _buildTableCell(formattedDate, alignCenter: true),
                          _buildTableCell(category.toUpperCase(), alignCenter: true),
                          _buildTableCell(title),
                          _buildTableCell('\$${cost.toStringAsFixed(0)}', alignCenter: true),
                        ],
                      );
                    }),
                  ],
                ),
            ];
          },
        ),
      );

      // 4. Guardar archivo temporal en el dispositivo
      final output = await getTemporaryDirectory();
      final String filePath = '${output.path}/Bitacora_Stepway_${placa}.pdf';
      final file = File(filePath);
      await file.writeAsBytes(await pdf.save());

      // 5. Compartir usando share_plus
      await Share.shareXFiles(
        [XFile(filePath)],
        text: 'Te comparto la ficha técnica de bitácora del vehículo $marca ($placa).',
      );
    } catch (e) {
      debugPrint('Error generando PDF: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al generar el PDF: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  static pw.Widget _buildTableCell(String text, {bool isHeader = false, bool alignCenter = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(6),
      child: pw.Text(
        text,
        textAlign: alignCenter ? pw.TextAlign.center : pw.TextAlign.left,
        style: pw.TextStyle(
          fontSize: 9,
          fontWeight: isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
        ),
      ),
    );
  }
}
