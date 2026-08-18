package com.example.stitch_stepway_fleet_manager

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.widget.RemoteViews
import android.widget.Toast

class BitacoraWidgetProvider : AppWidgetProvider() {

    companion object {
        const val ACTION_BACKGROUND_START_MONITORING = "com.example.stitch_stepway_fleet_manager.ACTION_BACKGROUND_START_MONITORING"
        const val ACTION_BACKGROUND_QUICK_REFUEL = "com.example.stitch_stepway_fleet_manager.ACTION_BACKGROUND_QUICK_REFUEL"
    }

    override fun onReceive(context: Context, intent: Intent) {
        super.onReceive(context, intent)

        when (intent.action) {
            ACTION_BACKGROUND_START_MONITORING -> {
                val prefs = context.getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
                val isMonitoring = prefs.getBoolean("flutter.background_monitoring_active", false)
                prefs.edit().putBoolean("flutter.background_monitoring_active", !isMonitoring).apply()

                val msg = if (!isMonitoring) {
                    "🚗 Monitoreo de Stepway iniciado en 2º plano"
                } else {
                    "⏸️ Monitoreo de Stepway pausado"
                }
                Toast.makeText(context, msg, Toast.LENGTH_SHORT).show()
                updateWidgets(context)
            }
            ACTION_BACKGROUND_QUICK_REFUEL -> {
                val prefs = context.getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
                val refuelCount = prefs.getInt("flutter.quick_refuel_count", 0) + 1
                prefs.edit().putInt("flutter.quick_refuel_count", refuelCount).apply()

                Toast.makeText(context, "⛽ Tanqueo registrado en 2º plano (#$refuelCount)", Toast.LENGTH_SHORT).show()
                updateWidgets(context)
            }
        }
    }

    override fun onUpdate(context: Context, appWidgetManager: AppWidgetManager, appWidgetIds: IntArray) {
        for (appWidgetId in appWidgetIds) {
            updateSingleWidget(context, appWidgetManager, appWidgetId)
        }
    }

    private fun updateWidgets(context: Context) {
        val appWidgetManager = AppWidgetManager.getInstance(context)
        val componentName = ComponentName(context, BitacoraWidgetProvider::class.java)
        val appWidgetIds = appWidgetManager.getAppWidgetIds(componentName)
        onUpdate(context, appWidgetManager, appWidgetIds)
    }

    private fun updateSingleWidget(context: Context, appWidgetManager: AppWidgetManager, appWidgetId: Int) {
        val prefs = context.getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
        val odometer = prefs.getString("flutter.odometer_value", "45,280 km") ?: "45,280 km"
        val health = prefs.getString("flutter.health_value", "95%") ?: "95%"
        val isMonitoring = prefs.getBoolean("flutter.background_monitoring_active", false)

        val startBroadcastIntent = Intent(context, BitacoraWidgetProvider::class.java).apply {
            action = ACTION_BACKGROUND_START_MONITORING
        }
        val startPendingIntent = PendingIntent.getBroadcast(
            context,
            101,
            startBroadcastIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        val refuelBroadcastIntent = Intent(context, BitacoraWidgetProvider::class.java).apply {
            action = ACTION_BACKGROUND_QUICK_REFUEL
        }
        val refuelPendingIntent = PendingIntent.getBroadcast(
            context,
            102,
            refuelBroadcastIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        val views = RemoteViews(context.packageName, R.layout.bitacora_widget).apply {
            setTextViewText(R.id.widget_odometer, "Odómetro: $odometer")
            setTextViewText(
                R.id.widget_health,
                if (isMonitoring) "Salud: $health • Monitoreando 🟢" else "Salud General: $health"
            )
            setOnClickPendingIntent(R.id.widget_btn_start, startPendingIntent)
            setOnClickPendingIntent(R.id.widget_btn_refuel, refuelPendingIntent)
        }

        appWidgetManager.updateAppWidget(appWidgetId, views)
    }
}
