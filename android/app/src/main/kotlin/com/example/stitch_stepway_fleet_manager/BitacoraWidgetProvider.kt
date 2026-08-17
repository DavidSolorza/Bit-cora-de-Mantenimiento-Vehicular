package com.example.stitch_stepway_fleet_manager

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.Intent
import android.widget.RemoteViews
import com.example.stitch_stepway_fleet_manager.R

class BitacoraWidgetProvider : AppWidgetProvider() {

    override fun onUpdate(context: Context, appWidgetManager: AppWidgetManager, appWidgetIds: IntArray) {
        val prefs = context.getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
        val odometer = prefs.getString("flutter.odometer_value", "45,200 km") ?: "45,200 km"
        val health = prefs.getString("flutter.health_value", "95%") ?: "95%"

        for (appWidgetId in appWidgetIds) {
            val startIntent = Intent(context, MainActivity::class.java).apply {
                action = "START_MONITORING"
                flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
            }
            val startPendingIntent = PendingIntent.getActivity(
                context,
                1,
                startIntent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )

            val refuelIntent = Intent(context, MainActivity::class.java).apply {
                action = "QUICK_REFUEL"
                flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
            }
            val refuelPendingIntent = PendingIntent.getActivity(
                context,
                2,
                refuelIntent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )

            val views = RemoteViews(context.packageName, R.layout.bitacora_widget).apply {
                setTextViewText(R.id.widget_odometer, "Odometer: $odometer")
                setTextViewText(R.id.widget_health, "Salud General: $health")
                setOnClickPendingIntent(R.id.widget_btn_start, startPendingIntent)
                setOnClickPendingIntent(R.id.widget_btn_refuel, refuelPendingIntent)
            }

            appWidgetManager.updateAppWidget(appWidgetId, views)
        }
    }
}
