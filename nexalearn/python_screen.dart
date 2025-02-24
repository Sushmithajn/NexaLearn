import 'package:flutter/material.dart';
import 'topic_detail_screen.dart';

class PythonScreen extends StatelessWidget {
  PythonScreen({super.key});

  final List<Map<String, String>> topics = [
    {
      "title": "Variables & Data Types",
      "description": "Learn about variables and different data types in Python.",
      "assignment": "Create a Python script that stores your name, age, and favorite color in variables and prints them."
    },
    {
      "title": "Conditional Statements",
      "description": "Learn how to use if-else statements to control program flow.",
      "assignment": "Write a program that takes user input and checks if the number is even or odd."
    },
    {
      "title": "Loops",
      "description": "Understand how loops work in Python.",
      "assignment": "Write a Python program that prints numbers from 1 to 10 using a loop."
    },
    {
      "title": "Functions",
      "description": "Learn how to define and use functions in Python.",
      "assignment": "Create a function that takes two numbers as input and returns their sum."
    },
  ];

  void navigateToTopic(BuildContext context, Map<String, String> topic) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TopicDetailScreen(topic: topic),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Python Topics")),
      body: ListView.builder(
        itemCount: topics.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(topics[index]["title"]!),
            subtitle: Text(topics[index]["description"]!),
            trailing: const Icon(Icons.arrow_forward),
            onTap: () => navigateToTopic(context, topics[index]),
          );
        },
      ),
    );
  }
}
