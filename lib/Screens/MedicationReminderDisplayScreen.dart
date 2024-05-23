import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MedicationReminderDisplayScreen extends StatefulWidget {
  @override
  _MedicationReminderDisplayScreenState createState() =>
      _MedicationReminderDisplayScreenState();
}

class _MedicationReminderDisplayScreenState
    extends State<MedicationReminderDisplayScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final User? currentUser = FirebaseAuth.instance.currentUser;

  Future<void> _deleteReminder(String docId) async {
    try {
      await _firestore.collection('medication_reminders').doc(docId).delete();
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Reminder deleted successfully')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete reminder: $e')));
    }
  }

  Future<void> _updateReminder(
      String docId, Map<String, dynamic> updatedData) async {
    try {
      await _firestore
          .collection('medication_reminders')
          .doc(docId)
          .update(updatedData);
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Reminder updated successfully')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update reminder: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Reminders',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blue,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('medication_reminders')
            .where('userId', isEqualTo: currentUser!.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final reminders = snapshot.data!.docs;

          if (reminders.isEmpty) {
            return const Center(
                child: Text(
              'No medication reminders set.',
              style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
              ),
            ));
          }

          return Container(
            height: MediaQuery.of(context).size.height,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/backgrnd.jpeg'),
                fit: BoxFit.fill,
              ),
            ),
            child: ListView.builder(
              itemCount: reminders.length,
              itemBuilder: (context, index) {
                final reminder =
                    reminders[index].data() as Map<String, dynamic>;
                final medicationName = reminder['medicationName'];
                final dosage = reminder['dosage'];
                final notes = reminder['notes'];
                final reminderTimeString = reminder['reminderTime'];
                final reminderTime = DateTime.parse(reminderTimeString);
                final docId = reminders[index].id;

                return Card(
                  margin: const EdgeInsets.all(8.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  child: ListTile(
                    leading: const Icon(Icons.medication,
                        color: Colors.blue, size: 40.0),
                    title: Text(
                      medicationName ?? 'Unknown Medication',
                      style: const TextStyle(
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Dosage: $dosage',
                          style: TextStyle(fontSize: 16.0),
                        ),
                        Text(
                          'Notes: $notes',
                          style: TextStyle(fontSize: 16.0),
                        ),
                        Text(
                          'Time: ${reminderTime.hour}:${reminderTime.minute.toString().padLeft(2, '0')}',
                          style: TextStyle(fontSize: 16.0),
                        ),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit, color: Colors.green),
                          onPressed: () {
                            // Implement update functionality
                            // For example, show a dialog to edit the reminder
                            _showUpdateDialog(docId, reminder);
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteReminder(docId),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  void _showUpdateDialog(String docId, Map<String, dynamic> reminder) {
    final TextEditingController medicationNameController =
        TextEditingController(text: reminder['medicationName']);
    final TextEditingController dosageController =
        TextEditingController(text: reminder['dosage'].toString());
    final TextEditingController notesController =
        TextEditingController(text: reminder['notes']);
    final TextEditingController reminderTimeController =
        TextEditingController(text: reminder['reminderTime']);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Update Reminder'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: medicationNameController,
                  decoration: InputDecoration(labelText: 'Medication Name'),
                ),
                TextField(
                  controller: dosageController,
                  decoration: InputDecoration(labelText: 'Dosage'),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: notesController,
                  decoration: InputDecoration(labelText: 'Notes'),
                ),
                TextField(
                  controller: reminderTimeController,
                  decoration: InputDecoration(labelText: 'Reminder Time'),
                  keyboardType: TextInputType.datetime,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                final updatedData = {
                  'medicationName': medicationNameController.text,
                  'dosage': int.parse(dosageController.text),
                  'notes': notesController.text,
                  'reminderTime': reminderTimeController.text,
                };
                _updateReminder(docId, updatedData);
                Navigator.of(context).pop();
              },
              child: Text('Update'),
            ),
          ],
        );
      },
    );
  }
}
