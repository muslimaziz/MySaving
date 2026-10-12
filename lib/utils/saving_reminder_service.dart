import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import '../database/database_helper.dart';

class SavingReminderService {
  SavingReminderService._();

  static const _notificationId = 4101;
  static const _enabledKey = 'saving_reminder_enabled';
  static const _hourKey = 'saving_reminder_hour';
  static const _minuteKey = 'saving_reminder_minute';

  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();
  static bool _initialized = false;

  static Future<void> initialize() async {
    if (_initialized) return;

    tz_data.initializeTimeZones();
    final localTimeZone = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(localTimeZone.identifier));

    await _notifications.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('ic_notification'),
        iOS: DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        ),
      ),
    );
    _initialized = true;

    final db = DatabaseHelper.instance;
    final enabled = await db.readSetting(_enabledKey) == 'true';
    if (enabled) {
      final hour = int.tryParse(await db.readSetting(_hourKey) ?? '') ?? 8;
      final minute = int.tryParse(await db.readSetting(_minuteKey) ?? '') ?? 0;
      await _schedule(hour, minute);
    }
  }

  static Future<bool> enable({required int hour, required int minute}) async {
    await initialize();
    final granted = await _requestPermission();
    if (!granted) return false;

    final db = DatabaseHelper.instance;
    await db.saveSetting(_hourKey, hour.toString());
    await db.saveSetting(_minuteKey, minute.toString());
    await db.saveSetting(_enabledKey, 'true');
    await _schedule(hour, minute);
    return true;
  }

  static Future<void> setTime({required int hour, required int minute}) async {
    await initialize();
    final db = DatabaseHelper.instance;
    await db.saveSetting(_hourKey, hour.toString());
    await db.saveSetting(_minuteKey, minute.toString());
    if (await isEnabled()) await _schedule(hour, minute);
  }

  static Future<void> disable() async {
    await initialize();
    await _notifications.cancel(id: _notificationId);
    await DatabaseHelper.instance.saveSetting(_enabledKey, 'false');
  }

  static Future<bool> isEnabled() async =>
      await DatabaseHelper.instance.readSetting(_enabledKey) == 'true';

  static Future<(int, int)> readTime() async {
    final db = DatabaseHelper.instance;
    final hour = int.tryParse(await db.readSetting(_hourKey) ?? '') ?? 8;
    final minute = int.tryParse(await db.readSetting(_minuteKey) ?? '') ?? 0;
    return (hour, minute);
  }

  static Future<bool> _requestPermission() async {
    final androidGranted = await _notifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();
    final iosGranted = await _notifications
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >()
        ?.requestPermissions(alert: true, badge: true, sound: true);

    return androidGranted ?? iosGranted ?? true;
  }

  static Future<void> _schedule(int hour, int minute) async {
    final now = tz.TZDateTime.now(tz.local);
    var next = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );
    if (!next.isAfter(now)) {
      next = next.add(const Duration(days: 1));
    }

    await _notifications.zonedSchedule(
      id: _notificationId,
      title: 'Waktunya menabung!',
      body: 'Sisihkan sedikit untuk mendekatkanmu pada target impianmu.',
      scheduledDate: next,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'saving_reminder',
          'Pengingat menabung',
          channelDescription: 'Pengingat mingguan untuk menabung',
          icon: 'ic_notification',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }
}
