abstract class DeviceNotificationService {
  Future<void> initialize();

  Future<void> showSessionNotification({
    required String title,
    required String body,
  });
}
