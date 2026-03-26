import 'device_notification_service_base.dart';
import 'device_notification_service_stub.dart'
    if (dart.library.html) 'device_notification_service_web.dart'
    if (dart.library.io) 'device_notification_service_io.dart';

DeviceNotificationService createDeviceNotificationService() =>
    createPlatformNotificationService();

final DeviceNotificationService deviceNotificationService =
    createDeviceNotificationService();
