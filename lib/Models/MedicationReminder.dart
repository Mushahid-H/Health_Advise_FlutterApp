import 'package:firebase_auth/firebase_auth.dart';

class MedicationReminder {
  final String medicationName;
  final DateTime reminderTime;
  final int dosage;
  final String notes;
  final String userId;

  MedicationReminder({
    required this.userId,
    required this.medicationName,
    required this.reminderTime,
    required this.dosage,
    required this.notes,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'medicationName': medicationName,
      'reminderTime': reminderTime.toIso8601String(),
      'dosage': dosage,
      'notes': notes,
    };
  }
}
