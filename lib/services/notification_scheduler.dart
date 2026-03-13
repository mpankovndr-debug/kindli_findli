import '../l10n/app_localizations.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
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
    final tzInfo = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(tzInfo.identifier));

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
    try {
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
    } catch (e) {
      debugPrint('Notification permission request failed: $e');
      // Continue without notifications — user can enable later from profile
      return false;
    }
  }

  static Future<void> scheduleDaily(AppLocalizations l10n) async {
    final hour = await NotificationPreferencesService.getHour();
    final minute = await NotificationPreferencesService.getMinute();

    // Always cancel existing daily notifications before rescheduling
    for (int i = 0; i <= 6; i++) {
      await _plugin.cancel(i);
    }

    final now = tz.TZDateTime.now(tz.local);
    final messages = NotificationMessages.daily(l10n);

    final subscribed = await NotificationPreferencesService.isSubscribed();
    final poolSize = subscribed ? 60 : 30;
    final startIndex =
        await NotificationPreferencesService.nextMessageIndex(poolSize);

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

      final msgIndex = (startIndex + dayOffset) % poolSize;
      final body = messages[msgIndex];

      await _plugin.zonedSchedule(
        dayOffset,
        '',
        body,
        scheduled,
        NotificationDetails(
          iOS: const DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: false,
            presentSound: true,
          ),
          android: AndroidNotificationDetails(
            'daily_reminders',
            l10n.notifDailyChannelName,
            channelDescription: l10n.notifDailyChannelDesc,
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

  static Future<void> scheduleWeekly(AppLocalizations l10n) async {
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
      l10n.notifWeeklyBody,
      scheduled,
      NotificationDetails(
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: false,
          presentSound: true,
        ),
        android: AndroidNotificationDetails(
          'weekly_reminders',
          l10n.notifWeeklyChannelName,
          channelDescription: l10n.notifWeeklyChannelDesc,
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

  static Future<int> pendingDailyCount() async {
    final pending = await _plugin.pendingNotificationRequests();
    return pending.where((n) => n.id >= 0 && n.id <= 6).length;
  }

  static Future<void> refreshTimezone(AppLocalizations? l10n) async {
    if (l10n == null) return;
    final tzInfo = await FlutterTimezone.getLocalTimezone();
    final newLocation = tz.getLocation(tzInfo.identifier);
    if (newLocation != tz.local) {
      tz.setLocalLocation(newLocation);
      final enabled = await NotificationPreferencesService.isEnabled();
      if (enabled) {
        await rescheduleAll(l10n);
      }
    }
  }

  static Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }

  static Future<void> rescheduleAll(AppLocalizations l10n) async {
    await cancelAll();
    await scheduleDaily(l10n);

    final weeklyEnabled =
        await NotificationPreferencesService.isWeeklyEnabled();
    if (weeklyEnabled) {
      await scheduleWeekly(l10n);
    }
  }
}
