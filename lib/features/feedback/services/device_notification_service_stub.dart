import 'device_notification_service_base.dart';

DeviceNotificationService createPlatformNotificationService() =>
    _StubNotificationService();

class _StubNotificationService implements DeviceNotificationService {
  @override
  Future<void> initialize() async {}

  @override
  Future<void> showSessionNotification({
    required String title,
    required String body,
  }) async {}
}
