import 'package:flutter/material.dart';
import 'package:stitch_stepway_fleet_manager/core/database/sqlite_database_helper.dart';
import 'package:stitch_stepway_fleet_manager/core/theme/app_colors.dart';
import 'package:stitch_stepway_fleet_manager/core/theme/app_theme.dart';
import 'package:stitch_stepway_fleet_manager/core/config/currency_manager.dart';

class ExpensesChartWidget extends StatefulWidget {
  final String vehicleId;

  const ExpensesChartWidget({
    super.key,
    required this.vehicleId,
  });

  @override
  State<ExpensesChartWidget> createState() => _ExpensesChartWidgetState();
}

class _ExpensesChartWidgetState extends State<ExpensesChartWidget> {
  Map<String, double> _categoryCosts = {
    'gasolina': 0.0,
    'taller': 0.0,
    'lavado': 0.0,
    'otros': 0.0,
  };
  double _totalSpend = 0.0;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadExpenses();
  }

  Future<void> _loadExpenses() async {
    setState(() => _loading = true);
    try {
      final db = await SqliteDatabaseHelper.instance.database;
      final results = await db.query(
        'maintenance_records',
        where: 'vehicle_id = ?',
        whereArgs: [widget.vehicleId],
      );

      double gas = 0.0;
      double workshop = 0.0;
      double wash = 0.0;
      double other = 0.0;
      double total = 0.0;

      for (final row in results) {
        final cost = (row['cost'] as num?)?.toDouble() ?? 0.0;
        final cat = (row['category'] as String?)?.toLowerCase() ?? 'otros';
        total += cost;
        if (cat == 'gasolina' || cat == 'combustible') {
          gas += cost;
        } else if (cat == 'taller' || cat == 'mantenimiento') {
          workshop += cost;
        } else if (cat == 'lavado' || cat == 'detallado') {
          wash += cost;
        } else {
          other += cost;
        }
      }

      setState(() {
        _categoryCosts = {
          'gasolina': gas,
          'taller': workshop,
          'lavado': wash,
          'otros': other,
        };
        _totalSpend = total;
        _loading = false;
      });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const SizedBox(
        height: 100,
        child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
      );
    }

    // Calcular porcentajes
    final gasPct = _totalSpend > 0 ? (_categoryCosts['gasolina']! / _totalSpend) : 0.0;
    final shopPct = _totalSpend > 0 ? (_categoryCosts['taller']! / _totalSpend) : 0.0;
    final washPct = _totalSpend > 0 ? (_categoryCosts['lavado']! / _totalSpend) : 0.0;
    final otherPct = _totalSpend > 0 ? (_categoryCosts['otros']! / _totalSpend) : 0.0;

    return Container(
      padding: AppSpacing.paddingMd,
      decoration: AppDecorations.cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: const [
                  Icon(Icons.pie_chart, color: AppColors.primary, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'DISTRIBUCIÓN DE GASTOS',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.onSurfaceVariant, letterSpacing: 0.5),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.refresh, size: 16, color: AppColors.primary),
                onPressed: _loadExpenses,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Inversión Acumulada:', style: TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant)),
              Text(
                CurrencyManager.format(_totalSpend),
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primary),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),

          // Barras de Progreso Dinámicas
          _buildBarChartRow('Gasolina', _categoryCosts['gasolina']!, gasPct, Colors.amber),
          const SizedBox(height: AppSpacing.sm),
          _buildBarChartRow('Taller / Motor', _categoryCosts['taller']!, shopPct, Colors.blueAccent),
          const SizedBox(height: AppSpacing.sm),
          _buildBarChartRow('Lavado / Estética', _categoryCosts['lavado']!, washPct, Colors.cyan),
          const SizedBox(height: AppSpacing.sm),
          _buildBarChartRow('Otros Gastos', _categoryCosts['otros']!, otherPct, Colors.grey),
        ],
      ),
    );
  }

  Widget _buildBarChartRow(String label, double amount, double percentage, Color barColor) {
    final pctText = (percentage * 100).toStringAsFixed(0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.onSurface)),
            Text(
              '${CurrencyManager.format(amount)} ($pctText%)',
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.onSurfaceVariant),
            ),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Container(
            height: 8,
            width: double.infinity,
            color: AppColors.background,
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: percentage.clamp(0.0, 1.0),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      barColor.withValues(alpha: 0.7),
                      barColor,
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
