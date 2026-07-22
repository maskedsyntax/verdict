import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;
import 'package:verdict/core/services/future_services.dart';

class LocalNotificationScheduler implements NotificationScheduler {
  LocalNotificationScheduler(this._plugin);

  static const _reminderId = 1001;
  static const _reminderHourUtc = 22;

  final FlutterLocalNotificationsPlugin _plugin;

  static Future<LocalNotificationScheduler> init() async {
    tz_data.initializeTimeZones();
    final plugin = FlutterLocalNotificationsPlugin();
    await plugin.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        ),
      ),
    );
    return LocalNotificationScheduler(plugin);
  }

  @override
  Future<void> scheduleDailyReminder() async {
    await _requestPermission();
    await _plugin.zonedSchedule(
      id: _reminderId,
      title: 'Your streak is waiting',
      body: "Today's Verdict is still unsolved — don't lose your streak.",
      scheduledDate: _nextReminderTime(),
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'streak_reminder',
          'Streak reminders',
          channelDescription: 'Reminds you before today\'s puzzle expires.',
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    );
  }

  @override
  Future<void> cancelDailyReminder() => _plugin.cancel(id: _reminderId);

  Future<void> _requestPermission() async {
    await _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();
    await _plugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >()
        ?.requestPermissions(alert: true, badge: true, sound: true);
  }

  tz.TZDateTime _nextReminderTime() {
    final now = tz.TZDateTime.now(tz.UTC);
    var next = tz.TZDateTime(
      tz.UTC,
      now.year,
      now.month,
      now.day,
      _reminderHourUtc,
    );
    if (!next.isAfter(now)) {
      next = next.add(const Duration(days: 1));
    }
    return next;
  }
}
