import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:rxdart/rxdart.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationProvider {
  final FlutterLocalNotificationsPlugin notificationPlugin =
      FlutterLocalNotificationsPlugin();
  bool _isInitialized = false;
  static final onClickNotification = BehaviorSubject<String>();

  // on tap notif
  static void onNotificationTap(NotificationResponse notificationResponse){
    onClickNotification.add(notificationResponse.payload!);
  }

  Future<bool> _isAndroid13OrHigher() async {
    if (kIsWeb) {
      return false; // Web platform doesn't support Android version checks
    }
    try {
      final androidInfo = await DeviceInfoPlugin().androidInfo;
      return androidInfo.version.sdkInt >= 33;
    } on PlatformException {
      return false;
    }
  }

  Future<bool> _requestPermissions() async {
    try {
      if (await _isAndroid13OrHigher()) {
        // Request notification permission for Android 13+
        final status = await Permission.notification.request();
        if (!status.isGranted) {
          debugPrint('Notification permission denied on Android 13+');
          return false;
        }
      }

      // For iOS/macOS - request permissions
      final bool? result = await notificationPlugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          ) ??
          await notificationPlugin
              .resolvePlatformSpecificImplementation<
                  MacOSFlutterLocalNotificationsPlugin>()
              ?.requestPermissions(
                alert: true,
                badge: true,
                sound: true,
              );

      return result ?? false;
    } on PlatformException catch (e) {
      debugPrint('Error requesting notification permissions: $e');
      return false;
    }
  }

  Future<void> initialize() async {
    if (_isInitialized) return;

    final hasPermission = await _requestPermissions();
    if (!hasPermission) {
      debugPrint('Notification permissions not granted');
      return;
    }

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
      requestAlertPermission: false, // We handle this manually
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
      macOS: initializationSettingsDarwin,
    );

    await notificationPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: onNotificationTap,
      onDidReceiveBackgroundNotificationResponse: onNotificationTap
    );

    _isInitialized = true;
  }

  String formatRemainingTime(Duration time) {
    if (time.inDays > 0) {
      return '${time.inDays} ${time.inDays == 1 ? 'day' : 'days'}';
    } else if (time.inHours > 0) {
      return '${time.inHours} ${time.inHours == 1 ? 'hour' : 'hours'}';
    } else if (time.inMinutes > 0) {
      return '${time.inMinutes} ${time.inMinutes == 1 ? 'minute' : 'minutes'}';
    }
    return 'less than a minute';
  }

  Future<void> showNotifications({
    required String title,
    required String body,
    required String payload,
    required travelDate,
    required List<Duration> reminders
  }) async {
    tz.initializeTimeZones();
    final localTime = tz.local;
    
    for (final reminder in reminders) {
      final notifTime = travelDate.subtract(reminder);
      if (notifTime.isAfter(DateTime.now())) {
        final remainingTime = travelDate.difference(DateTime.now());
        final remainingTimeMessage = formatRemainingTime(remainingTime); 

        await scheduleNotif(
          title: title,
          body: 'Your trip to $body $remainingTimeMessage!',
          payload: payload,
          scheduledDate: tz.TZDateTime.from(notifTime, localTime),        );
      }
    }
  }

  Future<void> scheduleNotif({
    required String title,
    required String body,
    required String payload,
    required tz.TZDateTime scheduledDate,
  }) async {
    if (!_isInitialized) await initialize();

    const AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
      'travel_reminders',
      'Travel Reminders',
      channelDescription: 'Notifications for upcoming travel plans',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
      icon: '@mipmap/ic_launcher', // Make sure this icon exists
    );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
    );

    try {
      await notificationPlugin.zonedSchedule(
        scheduledDate.millisecondsSinceEpoch ~/ 1000, // Unique ID
        title,
        body,
        scheduledDate,
        notificationDetails,
        payload: payload,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );
    } catch (e) {
      debugPrint('Error scheduling notification: $e');
      rethrow;
    }
  }

  Future<void> cancelTravelNotifications(int travelId) async {
    await notificationPlugin.cancel(travelId);
  }

}