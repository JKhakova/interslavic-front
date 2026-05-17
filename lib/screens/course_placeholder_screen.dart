import 'package:flutter/material.dart';

class CoursePlaceholderScreen extends StatelessWidget {
  const CoursePlaceholderScreen({super.key, required this.courseTitle});

  final String courseTitle;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(courseTitle)),
      body: const SafeArea(
        child: Center(
          child: Text('Пустая страница курса', style: TextStyle(fontSize: 18)),
        ),
      ),
    );
  }
}
