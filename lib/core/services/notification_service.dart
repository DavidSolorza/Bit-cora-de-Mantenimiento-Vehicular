import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Servicio de Notificaciones Push Locales de Alta Prioridad
/// (Suena, vibra y se despliega como banner flotante heads-up por encima de otras apps)
class NotificationService {
  static final NotificationService instance = NotificationService._internal();
  final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();

  NotificationService._internal();

  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const darwinSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: darwinSettings,
    );

    await _notificationsPlugin.initialize(initSettings);
    _initialized = true;
  }

  /// Solicita el permiso de notificaciones de forma no bloqueante
  Future<void> requestPermissions() async {
    try {
      final androidImplementation = _notificationsPlugin
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      if (androidImplementation != null) {
        await androidImplementation.requestNotificationsPermission();
      }
    } catch (e) {
      debugPrint('Error solicitando permisos de notificaciones: $e');
    }
  }

  Future<void> mostrarAlertaAltaPrioridad({
    required int id,
    required String titulo,
    required String cuerpo,
  }) async {
    await init();

    const androidDetails = AndroidNotificationDetails(
      'bitacora_high_priority_channel',
      'Alertas Críticas de Bitácora Fleet',
      channelDescription: 'Canal de notificaciones de alta prioridad para alerta de combustible y mantenimiento',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
      fullScreenIntent: true,
      styleInformation: BigTextStyleInformation(''),
    );

    const darwinDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: darwinDetails,
    );

    try {
      await _notificationsPlugin.show(
        id,
        titulo,
        cuerpo,
        details,
      );
    } catch (e) {
      debugPrint('Error mostrando notificacion push: $e');
    }
  }
}
