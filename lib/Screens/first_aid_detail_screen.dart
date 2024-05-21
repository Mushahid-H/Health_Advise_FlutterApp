import 'package:flutter/material.dart';

class FirstAidDetailScreen extends StatelessWidget {
  final String title;
  final String description;

  const FirstAidDetailScreen(
      {Key? key, required this.title, required this.description})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Colors.blue,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            description,
            style: TextStyle(
              fontSize: 18.0,
            ),
            textAlign: TextAlign.justify,
          ),
        ),
      ),
    );
  }
}
