import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

const String pendingReminderKey = 'pending_reminder_message';
const String notificationPayloadOpenDetails = 'open_details';

const int immediateNotificationId = 0;
const int scheduledReminderNotificationId = 1;

class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  void Function(String message)? onOpenReminderDetails;

  String? _pendingLaunchMessage;

  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;

    tz.initializeTimeZones();

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    await _plugin.initialize(
      const InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      ),
      onDidReceiveNotificationResponse: _onNotificationResponse,
    );

    final launchDetails = await _plugin.getNotificationAppLaunchDetails();
    if (launchDetails?.didNotificationLaunchApp ?? false) {
      final response = launchDetails!.notificationResponse;
      if (response != null) {
        _pendingLaunchMessage = await _extractMessageFromResponse(response);
      }
    }

    _initialized = true;
  }

  /// Call after [onOpenReminderDetails] is set to handle cold-start from notification.
  void consumePendingLaunchNavigation() {
    final message = _pendingLaunchMessage;
    if (message != null && message.isNotEmpty) {
      _pendingLaunchMessage = null;
      onOpenReminderDetails?.call(message);
    }
  }

  Future<bool> requestPermissions() async {
    if (defaultTargetPlatform == TargetPlatform.android) {
      final android =
          _plugin.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      final granted = await android?.requestNotificationsPermission();
      final exactAlarmGranted =
          await android?.requestExactAlarmsPermission();
      return (granted ?? true) && (exactAlarmGranted ?? true);
    }

    if (defaultTargetPlatform == TargetPlatform.iOS) {
      final ios = _plugin.resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>();
      final granted = await ios?.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      return granted ?? false;
    }

    return true;
  }

  Future<void> setReminder(String message) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(pendingReminderKey, message);

    const androidDetails = AndroidNotificationDetails(
      'reminder_channel',
      'Reminders',
      channelDescription: 'Reminder notifications',
      importance: Importance.high,
      priority: Priority.high,
    );
    const iosDetails = DarwinNotificationDetails();
    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _plugin.show(
      immediateNotificationId,
      'Reminder Set',
      'Reminder Set',
      details,
    );

    final scheduledTime =
        tz.TZDateTime.now(tz.local).add(const Duration(seconds: 30));

    await _plugin.zonedSchedule(
      scheduledReminderNotificationId,
      'Reminder',
      'You have a reminder. Click to view it.',
      scheduledTime,
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: jsonEncode({
        'action': notificationPayloadOpenDetails,
        'message': message,
      }),
    );
  }

  Future<String?> getPendingReminderMessage() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(pendingReminderKey);
  }

  Future<void> clearPendingReminder() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(pendingReminderKey);
  }

  void _onNotificationResponse(NotificationResponse response) {
    _handleNotificationResponse(response);
  }

  Future<void> _handleNotificationResponse(
    NotificationResponse response,
  ) async {
    final message = await _extractMessageFromResponse(response);
    if (message != null && message.isNotEmpty) {
      onOpenReminderDetails?.call(message);
    }
  }

  Future<String?> _extractMessageFromResponse(
    NotificationResponse response,
  ) async {
    final payload = response.payload;
    if (payload == null) return getPendingReminderMessage();

    try {
      final data = jsonDecode(payload) as Map<String, dynamic>;
      if (data['action'] == notificationPayloadOpenDetails) {
        final message = data['message'] as String?;
        if (message != null && message.isNotEmpty) return message;
      }
    } catch (_) {
      // Fall through to shared preferences.
    }

    return getPendingReminderMessage();
  }
}
