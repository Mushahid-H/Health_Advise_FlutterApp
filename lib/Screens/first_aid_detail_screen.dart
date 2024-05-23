import 'package:flutter/material.dart';

class FirstAidDetailScreen extends StatelessWidget {
  final String title;
  final String description;

  const FirstAidDetailScreen(
      {Key? key, required this.title, required this.description})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    var arr = description.split("\\n");
    return Scaffold(
      appBar: AppBar(
        title: Text(
          title,
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blue,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(children: [
            for (var item in arr)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(item, style: const TextStyle(fontSize: 16)),
              ),
          ]),
        ),
      ),
    );
  }
}
