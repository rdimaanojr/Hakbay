import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/foundation.dart';

class NotificationProvider {
  final FlutterLocalNotificationsPlugin notificationPlugin =
      FlutterLocalNotificationsPlugin();
  bool _isInitialized = false;

  bool get isInitialized => _isInitialized;

  /// Requests notification permissions (only needed for iOS/macOS).
  Future<bool> requestPermissions() async {
    try {
      if (kIsWeb) return false; // Not supported on web

      // iOS
      final bool? iosResult = await notificationPlugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(alert: true, badge: true, sound: true);

      // macOS
      final bool? macosResult = await notificationPlugin
          .resolvePlatformSpecificImplementation<
              MacOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(alert: true, badge: true, sound: true);

      return (iosResult ?? false) || (macosResult ?? false);
    } catch (e) {
      debugPrint("Failed to request notification permissions: $e");
      return false;
    }
  }

  /// Initializes notifications with platform-specific settings.
  Future<bool> initNotification() async {
    if (_isInitialized) return true;

    try {
      const AndroidInitializationSettings androidSettings =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      const DarwinInitializationSettings darwinSettings =
          DarwinInitializationSettings(
        requestAlertPermission: false, // Manually handled via requestPermissions()
        requestBadgePermission: false,
        requestSoundPermission: false,
      );

      const InitializationSettings initializationSettings =
          InitializationSettings(
        android: androidSettings,
        iOS: darwinSettings,
        macOS: darwinSettings,
      );

      await notificationPlugin.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: (_) {},
        onDidReceiveBackgroundNotificationResponse: (_) {},
      );

      _isInitialized = true;
      return true;
    } catch (e) {
      debugPrint("Failed to initialize notifications: $e");
      return false;
    }
  }

  /// Shows a notification with customizable details.
  Future<void> showNotification({
    required String title,
    required String body,
    String? payload,
    String channelId = 'default_channel',
    String channelName = 'Default Channel',
    String channelDescription = 'Default Notification Channel',
  }) async {
    if (!_isInitialized) {
      final bool initialized = await initNotification();
      if (!initialized) throw Exception("Notifications not initialized");
    }

    try {
      const Importance importance = Importance.max;
      const Priority priority = Priority.high;

      final AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails(
        channelId,
        channelName,
        channelDescription: channelDescription,
        importance: importance,
        priority: priority,
        ticker: 'ticker',
      );

      const DarwinNotificationDetails darwinDetails =
          DarwinNotificationDetails();

      final NotificationDetails platformDetails = NotificationDetails(
        android: androidDetails,
        iOS: darwinDetails,
        macOS: darwinDetails,
      );

      await notificationPlugin.show(
        0, // Notification ID
        title,
        body,
        platformDetails,
        payload: payload,
      );
    } catch (e) {
      debugPrint("Failed to show notification: $e");
      rethrow;
    }
  }
}