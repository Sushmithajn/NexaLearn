import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

void initializeTimeZones() {
  tz.initializeTimeZones();
}

class ReminderService {
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  ReminderService() {
    _initializeNotifications();
  }

  Future<void> _initializeNotifications() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings iosSettings = DarwinInitializationSettings(); // ✅ Updated

    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await flutterLocalNotificationsPlugin.initialize(settings);
  }

  Future<void> scheduleReminder(DateTime time, String title) async {
    await flutterLocalNotificationsPlugin.zonedSchedule(
      0, // Unique ID for the notification
      title,
      'Reminder for study session',
      tz.TZDateTime.from(time, tz.local), // ✅ Convert to TZDateTime
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'channelId',
          'channelName',
          channelDescription: 'description',
          importance: Importance.max,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(), // ✅ Updated
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle, // ✅ Required
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }
}
