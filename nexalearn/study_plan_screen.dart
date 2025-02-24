import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'dart:convert';

class StudyPlanScreen extends StatefulWidget {
  const StudyPlanScreen({super.key});

  @override
  StudyPlanScreenState createState() => StudyPlanScreenState();
}

class StudyPlanScreenState extends State<StudyPlanScreen> {
  final TextEditingController _subjectController = TextEditingController();
  TimeOfDay? _selectedTime;
  List<Map<String, dynamic>> _studyPlans = [];

  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    tz.initializeTimeZones();
    _loadStudyPlans();
    _initializeNotifications();
    _requestPermissions();
  }

  /// Request Notification Permissions for iOS and Android
  void _requestPermissions() {
    flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();

    flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
  }

  /// Initialize local notifications
  Future<void> _initializeNotifications() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    final DarwinInitializationSettings macSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestSoundPermission: true,
      requestBadgePermission: true,
    );

    final LinuxInitializationSettings linuxSettings =
        LinuxInitializationSettings(defaultActionName: 'Open Notification');

    final InitializationSettings settings = InitializationSettings(
      android: androidSettings,
      macOS: macSettings,
      linux: linuxSettings,
    );

    await flutterLocalNotificationsPlugin.initialize(settings);
  }

  /// Schedule a study notification
  Future<void> _scheduleNotification(String subject, TimeOfDay time) async {
    final now = DateTime.now();
    DateTime studyDateTime =
        DateTime(now.year, now.month, now.day, time.hour, time.minute);

    // If the time is in the past, schedule it for the next day
    if (studyDateTime.isBefore(now)) {
      studyDateTime = studyDateTime.add(const Duration(days: 1));
    }

    final tz.TZDateTime scheduledTime =
        tz.TZDateTime.from(studyDateTime, tz.local);

    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'study_reminder',
      'Study Notifications',
      importance: Importance.high,
      priority: Priority.high,
    );

    const DarwinNotificationDetails macDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const LinuxNotificationDetails linuxDetails = LinuxNotificationDetails();

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      macOS: macDetails,
      linux: linuxDetails,
    );

    int notificationId = DateTime.now().millisecondsSinceEpoch.remainder(100000);

    debugPrint("Scheduling Notification: $subject at ${studyDateTime.toLocal()}");

    await flutterLocalNotificationsPlugin.zonedSchedule(
      notificationId,
      "Time to Study: $subject",
      "Start your study session now!",
      scheduledTime,
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  /// Load study plans from SharedPreferences
  Future<void> _loadStudyPlans() async {
    final prefs = await SharedPreferences.getInstance();
    final String? savedPlans = prefs.getString('studyPlans');
    if (savedPlans != null) {
      setState(() {
        _studyPlans = List<Map<String, dynamic>>.from(json.decode(savedPlans));
      });
    }
  }

  /// Save study plans to SharedPreferences
  Future<void> _saveStudyPlans() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('studyPlans', json.encode(_studyPlans));
  }

  /// Add a new study plan
  void _addStudyPlan() {
    if (_subjectController.text.isNotEmpty && _selectedTime != null) {
      setState(() {
        _studyPlans.add({
          "subject": _subjectController.text,
          "time": "${_selectedTime!.hour}:${_selectedTime!.minute.toString().padLeft(2, '0')}",
        });

        // Ensure the time is correctly passed as a TimeOfDay object
        TimeOfDay selectedTime = _selectedTime!;
        _scheduleNotification(_subjectController.text, selectedTime);

        _subjectController.clear();
        _selectedTime = null;
      });
      _saveStudyPlans();
    }
  }

  /// Select study time
  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (pickedTime != null) {
      setState(() {
        _selectedTime = pickedTime;
      });
    }
  }

  /// Remove a study plan
  void _removeStudyPlan(int index) {
    setState(() {
      _studyPlans.removeAt(index);
    });
    _saveStudyPlans();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Study Plan")),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            TextField(
              controller: _subjectController,
              decoration: const InputDecoration(labelText: "Enter Subject"),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                ElevatedButton(
                  onPressed: () => _selectTime(context),
                  child: const Text("Select Time"),
                ),
                const SizedBox(width: 10),
                _selectedTime != null
                    ? Text("Selected Time: ${_selectedTime!.format(context)}")
                    : const Text("No time selected"),
              ],
            ),
            const SizedBox(height: 15),
            ElevatedButton(
              onPressed: _addStudyPlan,
              child: const Text("Add Study Plan"),
            ),
            const SizedBox(height: 15),
            Expanded(
              child: ListView.builder(
                itemCount: _studyPlans.length,
                itemBuilder: (context, index) {
                  final plan = _studyPlans[index];
                  return ListTile(
                    title: Text(plan["subject"]),
                    subtitle: Text("Study Time: ${plan["time"]}"),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _removeStudyPlan(index),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
