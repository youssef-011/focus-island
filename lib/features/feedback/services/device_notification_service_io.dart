import 'dart:io';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'device_notification_service_base.dart';

DeviceNotificationService createPlatformNotificationService() =>
    _IoNotificationService();

class _IoNotificationService implements DeviceNotificationService {
  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  @override
  Future<void> initialize() async {
    if (_isInitialized) {
      return;
    }

    const initializationSettings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(),
      macOS: DarwinInitializationSettings(),
      linux: LinuxInitializationSettings(
        defaultActionName: 'Open Focus Island',
      ),
    );

    await _plugin.initialize(initializationSettings);

    if (Platform.isAndroid) {
      await _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.requestNotificationsPermission();
    }

    if (Platform.isIOS || Platform.isMacOS) {
      await _plugin
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >()
          ?.requestPermissions(
            alert: true,
            badge: false,
            sound: true,
          );
      await _plugin
          .resolvePlatformSpecificImplementation<
            MacOSFlutterLocalNotificationsPlugin
          >()
          ?.requestPermissions(
            alert: true,
            badge: false,
            sound: true,
          );
    }

    _isInitialized = true;
  }

  @override
  Future<void> showSessionNotification({
    required String title,
    required String body,
  }) async {
    await initialize();

    const notificationDetails = NotificationDetails(
      android: AndroidNotificationDetails(
        'focus_session_updates',
        'Focus Sessions',
        channelDescription:
            'Session completion, planting, and daily goal feedback.',
        importance: Importance.max,
        priority: Priority.high,
      ),
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: false,
        presentSound: true,
      ),
      macOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: false,
        presentSound: true,
      ),
      linux: LinuxNotificationDetails(),
    );

    await _plugin.show(
      4001,
      title,
      body,
      notificationDetails,
    );
  }
}
