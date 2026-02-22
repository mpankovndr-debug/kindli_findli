import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import 'notification_messages.dart';
import 'notification_preferences_service.dart';

class NotificationScheduler {
  NotificationScheduler._();

  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    tz.initializeTimeZones();

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _plugin.initialize(settings);
  }

  static Future<bool> requestPermission() async {
    final ios = _plugin.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();
    if (ios != null) {
      final granted = await ios.requestPermissions(
        alert: true,
        badge: false,
        sound: true,
      );
      return granted ?? false;
    }
    return false;
  }

  static Future<void> scheduleDaily() async {
    final hour = await NotificationPreferencesService.getHour();
    final minute = await NotificationPreferencesService.getMinute();

    // Check how many of IDs 0-6 are still pending
    final pending = await _plugin.pendingNotificationRequests();
    final dailyPending =
        pending.where((n) => n.id >= 0 && n.id <= 6).length;

    if (dailyPending >= 3) return;

    // Cancel existing daily notifications before rescheduling
    for (int i = 0; i <= 6; i++) {
      await _plugin.cancel(i);
    }

    final now = tz.TZDateTime.now(tz.local);

    for (int dayOffset = 0; dayOffset < 7; dayOffset++) {
      var scheduled = tz.TZDateTime(
        tz.local,
        now.year,
        now.month,
        now.day,
        hour,
        minute,
      ).add(Duration(days: dayOffset));

      // Skip if the time has already passed today
      if (scheduled.isBefore(now)) {
        if (dayOffset == 0) continue;
      }

      final subscribed = await NotificationPreferencesService.isSubscribed();
      final poolSize = subscribed ? 60 : 30;
      final messageIndex =
          await NotificationPreferencesService.nextMessageIndex(poolSize);
      final body = NotificationMessages.daily[messageIndex];

      await _plugin.zonedSchedule(
        dayOffset,
        '',
        body,
        scheduled,
        const NotificationDetails(
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: false,
            presentSound: true,
          ),
          android: AndroidNotificationDetails(
            'daily_reminders',
            'Daily Reminders',
            channelDescription: 'Gentle daily habit reminders',
            importance: Importance.defaultImportance,
            priority: Priority.defaultPriority,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: null,
      );
    }
  }

  static Future<void> scheduleWeekly() async {
    final now = tz.TZDateTime.now(tz.local);

    // Find the next Sunday at 21:00
    var scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      21,
      0,
    );

    // Advance to next Sunday (weekday 7)
    while (scheduled.weekday != DateTime.sunday ||
        !scheduled.isAfter(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
      scheduled = tz.TZDateTime(
        tz.local,
        scheduled.year,
        scheduled.month,
        scheduled.day,
        21,
        0,
      );
    }

    await _plugin.zonedSchedule(
      100,
      '',
      'Check in with how your week felt. Your habits were there for you.',
      scheduled,
      const NotificationDetails(
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: false,
          presentSound: true,
        ),
        android: AndroidNotificationDetails(
          'weekly_reminders',
          'Weekly Reminders',
          channelDescription: 'Weekly reflection reminders',
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
    );
  }

  static Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }

  static Future<void> rescheduleAll() async {
    await cancelAll();
    await scheduleDaily();

    final weeklyEnabled =
        await NotificationPreferencesService.isWeeklyEnabled();
    if (weeklyEnabled) {
      await scheduleWeekly();
    }
  }
}
