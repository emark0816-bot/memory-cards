import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

final _notifications = FlutterLocalNotificationsPlugin();

const _details = NotificationDetails(
  android: AndroidNotificationDetails(
    'daily_reminder',
    'Daily reminder',
    channelDescription: 'Reminds you to add a memory',
    importance: Importance.high,
    priority: Priority.high,
  ),
);

Future<void> initReminders() async {
  tzdata.initializeTimeZones();
  tz.setLocalLocation(tz.getLocation('Europe/Berlin')); // German time
  await _notifications.initialize(
    const InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
    ),
  );
}

Future<bool> requestPermission() async {
  final android = _notifications.resolvePlatformSpecificImplementation<
      AndroidFlutterLocalNotificationsPlugin>();
  return await android?.requestNotificationsPermission() ?? false;
}

Future<void> scheduleDailyReminder(int hour, int minute) async {
  final now = tz.TZDateTime.now(tz.local);
  var next = tz.TZDateTime(
      tz.local, now.year, now.month, now.day, hour, minute);
  if (!next.isAfter(now)) {
    next = tz.TZDateTime(
        tz.local, now.year, now.month, now.day + 1, hour, minute);
  }
  await _notifications.zonedSchedule(
    1,
    'Memory Cards',
    'Add a memory about your day!',
    next,
    _details,
    androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    matchDateTimeComponents: DateTimeComponents.time, // repeat daily
  );
}

Future<void> cancelReminder() => _notifications.cancel(1);

Future<void> showTestNotification() => _notifications.show(
    0, 'Memory Cards', 'This is a test reminder', _details);