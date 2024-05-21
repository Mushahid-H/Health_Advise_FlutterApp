import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:health_advisor/main.dart';

class FirstAidScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'First Aid Guide',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blue,
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: NetworkImage(
                'https://images.pexels.com/photos/3786215/pexels-photo-3786215.jpeg'),
            fit: BoxFit.fill,
          ),
        ),
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('first_aid_items')
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData) {
              return Center(child: Text('No Data Available'));
            }

            final items = snapshot.data!.docs.map((doc) {
              return FirstAidItem(
                title: doc['title'],
                description: doc['description'],
              );
            }).toList();

            return Padding(
                padding: const EdgeInsets.all(16.0),
                child: ListView(
                  children: items,
                ));
          },
        ),
      ),
    );
  }
}
