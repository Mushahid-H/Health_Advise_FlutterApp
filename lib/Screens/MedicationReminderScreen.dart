import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:health_advisor/Models/MedicationReminder.dart';
import 'package:health_advisor/main.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class MedicationReminderScreen extends StatefulWidget {
  @override
  _MedicationReminderScreenState createState() =>
      _MedicationReminderScreenState();
}

class _MedicationReminderScreenState extends State<MedicationReminderScreen> {
  final TextEditingController medicationNameController =
      TextEditingController();
  final TextEditingController dosageController = TextEditingController();
  final TextEditingController notesController = TextEditingController();
  DateTime? selectedTime;

  @override
  void initState() {
    super.initState();
    _requestNotificationPermissions();
    tz.initializeTimeZones();
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      final now = DateTime.now();
      setState(() {
        selectedTime =
            DateTime(now.year, now.month, now.day, picked.hour, picked.minute);
      });
    }
  }

  Future<void> saveReminderToFirebase(MedicationReminder reminder) async {
    final firestore = FirebaseFirestore.instance;
    await firestore.collection('medication_reminders').add(reminder.toMap());
    _requestExactAlarmPermission(reminder);
  }

  Future<void> _requestNotificationPermissions() async {
    final permissionStatus = await Permission.notification.request();
    if (permissionStatus.isGranted) {
      print("Notification permissions granted");
    } else {
      print("Notification permissions not granted");
    }
  }

  Future<void> _requestExactAlarmPermission(MedicationReminder reminder) async {
    if (await Permission.scheduleExactAlarm.request().isGranted) {
      _scheduleNotification(reminder);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Exact alarms permission not granted')));
    }
  }

  Future<void> _scheduleNotification(MedicationReminder reminder) async {
    final id = DateTime.now().millisecondsSinceEpoch ~/ 1000;

    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      reminder.reminderTime.hour,
      reminder.reminderTime.minute,
    );

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    debugPrint("tz: ${tz.local.toString()}");
    debugPrint("scheduledDate: $scheduledDate");
    debugPrint("set time: ${reminder.reminderTime.toString()}");

    const androidDetails = AndroidNotificationDetails(
      'medication_reminder',
      'Medication Reminders',
      channelDescription: 'Reminders for taking your medication',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker',
      // sound: RawResourceAndroidNotificationSound('')
    );

    // const iosDetails = IOSNotificationDetails();

    final platformDetails = NotificationDetails(android: androidDetails);

    await flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      'Medication Reminder',
      'Time to take your medication: ${reminder.medicationName}, Dosage: ${reminder.dosage}',
      scheduledDate,
      platformDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  void submitReminder() {
    if (medicationNameController.text.isNotEmpty && selectedTime != null) {
      final reminder = MedicationReminder(
        userId: FirebaseAuth.instance.currentUser!.uid,
        medicationName: medicationNameController.text,
        reminderTime: selectedTime!,
        dosage: int.parse(dosageController.text),
        notes: notesController.text,
      );
      saveReminderToFirebase(reminder);
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Reminder set successfully')));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please fill all fields')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Medication Reminder',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blue,
      ),
      body: Container(
        height: MediaQuery.of(context).size.height,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/backgrnd.jpeg'),
            fit: BoxFit.fill,
          ),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                ElevatedButton(
                    style: ButtonStyle(
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                      backgroundColor:
                          MaterialStateProperty.all<Color>(Colors.blue),
                    ),
                    onPressed: () {
                      Navigator.pushNamed(context, 'reminder-display');
                    },
                    child: const Text(
                      'View Medication Reminders',
                      style: TextStyle(color: Colors.white),
                    )),
                const SizedBox(height: 20),
                TextField(
                  controller: medicationNameController,
                  decoration: const InputDecoration(
                    labelText: 'Medication Name',
                    filled: true,
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: dosageController,
                  decoration: const InputDecoration(
                    labelText: 'Dosage',
                    filled: true,
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(
                  height: 20,
                ),
                TextField(
                  controller: notesController,
                  decoration: const InputDecoration(
                    labelText: 'Notes',
                    filled: true,
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Text(
                      selectedTime == null
                          ? 'No time selected!'
                          : 'Selected time: ${selectedTime!.hour}:${selectedTime!.minute}',
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                    ),
                    Spacer(),
                    ElevatedButton(
                      onPressed: () => _selectTime(context),
                      style: ButtonStyle(
                        shape:
                            MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                        ),
                        backgroundColor:
                            MaterialStateProperty.all<Color>(Colors.blue),
                      ),
                      child: const Text(
                        'Select Time',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 50),
                ElevatedButton(
                  onPressed: () {
                    submitReminder();

                    medicationNameController.clear();
                    dosageController.clear();
                    notesController.clear();
                    setState(() {
                      selectedTime = null;
                    });
                  },
                  style: ButtonStyle(
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                    backgroundColor:
                        MaterialStateProperty.all<Color>(Colors.blue),
                  ),
                  child: const Text(
                    'Set Reminder',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
