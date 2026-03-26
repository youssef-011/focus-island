import 'dart:html' as html;

import 'device_notification_service_base.dart';

DeviceNotificationService createPlatformNotificationService() =>
    _WebNotificationService();

class _WebNotificationService implements DeviceNotificationService {
  @override
  Future<void> initialize() async {}

  @override
  Future<void> showSessionNotification({
    required String title,
    required String body,
  }) async {
    if (!html.Notification.supported) {
      return;
    }

    var permission = html.Notification.permission;
    if (permission != 'granted') {
      permission = await html.Notification.requestPermission();
    }

    if (permission != 'granted') {
      return;
    }

    html.Notification(
      title,
      body: body,
    );
  }
}
