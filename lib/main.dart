import 'package:flutter/material.dart';
import 'package:todo_application/create_list.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'To-Do App',
      home: CreateList(),
    );
  }
}
